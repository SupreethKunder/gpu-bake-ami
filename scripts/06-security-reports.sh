#!/usr/bin/env bash
set -eux

# ---------------------------
# Create reports directory
# ---------------------------
sudo mkdir -p /var/tmp/security-reports

# ---------------------------
# Install Trivy
# ---------------------------
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo gpg --dearmor -o /usr/share/keyrings/trivy.gpg
echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/trivy.list
sudo apt-get update -y
sudo apt-get install -y trivy

# ---------------------------
# Install latest Lynis
# ---------------------------
LYNIS_LATEST_URL="https://api.github.com/repos/CISOfy/lynis/tarball/3.1.5"
sudo wget -O /tmp/lynis.tar.gz "$LYNIS_LATEST_URL"
sudo mkdir -p /opt/lynis
sudo tar -xzf /tmp/lynis.tar.gz -C /opt/lynis --strip-components=1
sudo ln -sf /opt/lynis/lynis /usr/local/bin/lynis

# ---------------------------
# Run Trivy scans
# ---------------------------
set +e
sudo trivy rootfs / --scanners vuln --severity HIGH,CRITICAL --ignore-unfixed --skip-dirs /proc,/sys,/dev,/run --timeout 15m --format json --output /var/tmp/security-reports/trivy-ami.json
TRIVY_RC_JSON=$?
sudo trivy rootfs / --scanners vuln --severity HIGH,CRITICAL --ignore-unfixed --skip-dirs /proc,/sys,/dev,/run --timeout 15m --format sarif --output /var/tmp/security-reports/trivy-ami.sarif
TRIVY_RC_SARIF=$?
TRIVY_RC=$(( TRIVY_RC_JSON > TRIVY_RC_SARIF ? TRIVY_RC_JSON : TRIVY_RC_SARIF ))

# ---------------------------
# Run Lynis scan
# ---------------------------
sudo lynis audit system --quiet --logfile /var/tmp/security-reports/lynis.log
LYNIS_RC=$?

set -e
if [ "$TRIVY_RC" -ne 0 ]; then
    echo "Trivy found HIGH/CRITICAL vulnerabilities." >&2
    exit 1
fi

if [ "$LYNIS_RC" -ne 0 ]; then
    echo "Lynis audit found issues." >&2
fi

echo "Security scans completed. Reports saved to /var/tmp/security-reports/"
