#!/usr/bin/env bash
# bootstrap-vps.sh — One-shot provisioning for a fresh Hetzner CX21 (Ubuntu 22.04).
# Run as root ONCE. NOT called by GitHub Actions.
set -euo pipefail

if [ "$(id -u)" != "0" ]; then
  echo "ERROR: This script must be run as root (sudo bash bootstrap-vps.sh)." >&2
  exit 1
fi

echo "[bootstrap] Updating package lists..."
apt-get update
apt-get install -y ca-certificates curl gnupg

echo "[bootstrap] Installing Docker via official convenience script..."
curl -fsSL https://get.docker.com | sh

echo "[bootstrap] Installing docker-compose-plugin..."
apt-get install -y docker-compose-plugin

echo "[bootstrap] Creating 'deploy' user..."
if ! id deploy &>/dev/null; then
  useradd --shell /bin/bash --create-home deploy
fi
usermod -aG docker deploy

echo "[bootstrap] Creating /srv/rbr owned by deploy..."
mkdir -p /srv/rbr
chown deploy:deploy /srv/rbr

echo ""
echo "[bootstrap] Provisioning complete. Next steps (run as yourself, not root):"
echo ""
echo "  1. Add your deploy SSH public key:"
echo "     mkdir -p /home/deploy/.ssh"
echo "     echo 'YOUR_ED25519_PUBLIC_KEY' >> /home/deploy/.ssh/authorized_keys"
echo "     chown -R deploy:deploy /home/deploy/.ssh"
echo "     chmod 700 /home/deploy/.ssh && chmod 600 /home/deploy/.ssh/authorized_keys"
echo ""
echo "  2. Copy infra/ files to /srv/rbr/ on the VPS:"
echo "     scp infra/docker-compose.tst.yml infra/Caddyfile infra/Dockerfile.pocketbase deploy@<vps-ip>:/srv/rbr/"
echo "     scp scripts/deploy-tst.sh deploy@<vps-ip>:/home/deploy/"
echo "     chmod +x /home/deploy/deploy-tst.sh"
echo ""
echo "  3. Create /srv/rbr/.env.tst with real secrets (based on infra/.env.tst.example):"
echo "     nano /srv/rbr/.env.tst"
echo ""
echo "  4. Run the first deploy:"
echo "     sudo -u deploy bash /home/deploy/deploy-tst.sh tst"
echo ""
echo "  Caddy will obtain a Let's Encrypt certificate automatically once DNS resolves."
