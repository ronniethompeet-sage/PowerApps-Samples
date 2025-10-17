# 🎊 COMPLETE GUIDE: Code Interpreter Control

## From Local Demo to Power Apps Production

---

## 📖 Table of Contents

1. **[What You Have Now](#what-you-have-now)** - Current local demo
2. **[Getting it into Power Apps](#getting-it-into-power-apps)** - Step-by-step process
3. **[Quick Commands](#quick-commands)** - Copy-paste commands
4. **[Documentation Index](#documentation-index)** - All guides available
5. **[Common Questions](#common-questions)** - FAQ

---

## 🎯 What You Have Now

### ✅ Working Local Demo

**Location:** `CodeInterpreterControl/`

**Files:**
```
✅ test-harness.html          - Interactive browser demo
✅ Start-TestHarness.ps1      - Launcher script
✅ TypeScript source code     - Actual PCF control
✅ package.json               - Dependencies (mammoth, xlsx)
✅ Documentation              - Multiple guides
```

**Current Status:**
- 🌐 Running on: http://localhost:8082
- 📊 Shows: Interactive charts and document generation
- 🎨 Demonstrates: All control capabilities
- ⚠️ **BUT:** Not yet in Power Apps (local only)

---

## 🚀 Getting it into Power Apps

### The Process (5 Main Steps)

```
┌─────────────────────────────────────────────────────────┐
│ STEP 1: BUILD THE CONTROL                              │
│ Time: 5-10 minutes                                      │
│ Command: .\Build-ForPowerApps.ps1                      │
│ Output: CodeInterpreterControl.zip                     │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│ STEP 2: IMPORT TO POWER APPS                           │
│ Time: 2-5 minutes                                       │
│ Action: Upload ZIP to make.powerapps.com               │
│ Result: Control available in your environment          │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│ STEP 3: CREATE AI PROMPTS                              │
│ Time: 10-15 minutes                                     │
│ Action: Configure Code Interpreter prompts             │
│ Result: AI models that generate docs/charts            │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│ STEP 4: ADD TO APP FORM                                │
│ Time: 5-10 minutes                                      │
│ Action: Drag control onto model-driven app form        │
│ Result: Control appears in your app                    │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│ STEP 5: TEST & DEPLOY                                  │
│ Time: 15-30 minutes                                     │
│ Action: Test with real data, train users               │
│ Result: Production-ready AI-powered app! 🎉            │
└─────────────────────────────────────────────────────────┘
```

---

## 🔨 STEP 1: Build the Control (Detailed)

### Prerequisites

Before building, ensure you have:

1. **Node.js** (check: `node --version`)
   - Download: https://nodejs.org/
   - Required: v14 or later

2. **Power Platform CLI** (check: `pac --version`)
   - Install: `winget install Microsoft.PowerPlatformCLI`
   - Or: Download from Microsoft

3. **Visual Studio Build Tools** (optional but recommended)
   - Download: https://visualstudio.microsoft.com/downloads/
   - Select: ".NET desktop build tools" workload

### Build Commands

#### Option A: Automated Build (Recommended)

```powershell
# Navigate to control folder
cd "PowerApps-Samples\component-framework\CodeInterpreterControl"

# Run automated build script
.\Build-ForPowerApps.ps1

# With custom publisher
.\Build-ForPowerApps.ps1 -PublisherName "YourCompany" -PublisherPrefix "yourco"

# Clean build (removes previous builds first)
.\Build-ForPowerApps.ps1 -CleanFirst
```

**What it does:**
1. ✅ Installs npm dependencies
2. ✅ Compiles TypeScript to JavaScript
3. ✅ Creates solution structure
4. ✅ Adds control reference
5. ✅ Packages as ZIP file

**Output:**
```
📦 solutions/CodeInterpreterControl.zip
```

#### Option B: Manual Build

```powershell
# 1. Install dependencies
npm install

# 2. Build the control
npm run build

# 3. Create solution folder
mkdir solutions
cd solutions
pac solution init --publisher-name "YourCompany" --publisher-prefix "yourco"

# 4. Add control reference
pac solution add-reference --path ".."

# 5. Build solution package
msbuild /t:build /restore /p:configuration=Release

# Or use PAC CLI
pac solution pack --zipfile CodeInterpreterControl.zip
```

### Verify Build Success

```powershell
# Check if ZIP exists
Test-Path "solutions\CodeInterpreterControl.zip"

# Should return: True

# Check file size (should be 500KB - 2MB)
(Get-Item "solutions\CodeInterpreterControl.zip").Length / 1MB
```

---

## ☁️ STEP 2: Import to Power Apps

### Using Power Apps Portal (Easiest)

1. **Navigate to Power Apps**
   - Go to: https://make.powerapps.com
   - Select your environment (top-right dropdown)
   - **Important:** Choose the correct environment!

2. **Import Solution**
   - Click **Solutions** in left navigation
   - Click **Import solution** button (top toolbar)
   - Click **Browse**
   - Select `CodeInterpreterControl.zip`
   - Click **Next**

3. **Configure Import**
   - Review solution details
   - Select publisher (or use existing)
   - Click **Import**

4. **Wait for Completion**
   - Import takes 2-5 minutes
   - Don't close the browser
   - Watch for "Success" message

5. **Verify Import**
   - Go to **Solutions**
   - Find "CodeInterpreterControl" solution
   - Click to open it
   - Expand **Custom Controls** or **Controls**
   - You should see **CodeInterpreterControl** listed ✅

### Using PAC CLI (Advanced)

```powershell
# 1. Authenticate to your environment
pac auth create --url https://yourorg.crm.dynamics.com

# Example:
# pac auth create --url https://contoso.crm.dynamics.com

# 2. Import the solution
pac solution import --path "solutions\CodeInterpreterControl.zip"

# 3. Wait for completion message
# Should see: "Solution imported successfully"

# 4. Verify
pac solution list
# Look for "CodeInterpreterControl" in the list
```

---

## 🤖 STEP 3: Create AI Code Interpreter Prompts

This is **critical** - the control needs AI prompts to work!

### Create Document Generation Prompt

1. **Go to AI Hub**
   - Navigate to: https://make.powerapps.com
   - Click **AI hub** in left navigation
   - Click **Prompts**

2. **Create New Prompt**
   - Click **+ New prompt**
   - Name: "Sales Document Generator"

3. **Configure Prompt**

   **Basic Settings:**
   ```
   Name: Sales Document Generator
   Description: Generates professional sales documents from record data
   ```

   **Input Schema:**
   ```json
   {
     "RecordId": {
       "type": "string",
       "description": "The GUID of the record to generate document for"
     }
   }
   ```

   **Prompt Text:**
   ```
   You are a professional document generator. Generate a comprehensive sales 
   proposal document for the record with ID: {{RecordId}}
   
   The document should include:
   - Executive Summary
   - Key metrics and data from the record
   - Professional recommendations
   - Clear formatting and structure
   
   Return the result as a PDF document with professional formatting.
   ```

   **Code Interpreter Setting:**
   - Toggle **Code Interpreter** to **ON** ✅
   - This is REQUIRED for file generation!

   **Output Type:**
   - Select: **File**
   - Format: PDF (or Word, Excel, PowerPoint)

4. **Test the Prompt**
   - Click **Test**
   - Enter sample input:
     ```json
     {"RecordId": "test-123"}
     ```
   - Verify it generates a document
   - Check output format is correct

5. **Save and Publish**
   - Click **Save**
   - Note the Model ID (GUID) - **YOU NEED THIS!**

6. **Get Model ID**
   - Look at browser URL:
     ```
     ...promptid=b412c9a3-1b4f-45c4-956d-33bd4412be33
     ```
   - Copy the GUID: `b412c9a3-1b4f-45c4-956d-33bd4412be33`
   - **Save this!** You'll configure the control with this ID

### Create Chart Generation Prompt

Follow same steps but with different configuration:

```
Name: Interactive Chart Generator
Description: Creates interactive visualizations from record data

Input Schema:
{
  "RecordId": {
    "type": "string",
    "description": "Record ID to visualize"
  }
}

Prompt Text:
Create an interactive HTML chart visualizing key metrics from record: {{RecordId}}

Requirements:
- Use Chart.js or D3.js for visualization
- Include interactive tooltips
- Make it visually appealing with colors
- Return as HTML with inline JavaScript
- Ensure it's responsive

Output Type: Text (HTML)
Code Interpreter: ON ✅
```

**Save the Model ID for this one too!**

---

## 📱 STEP 4: Add Control to Model-Driven App

### Create/Edit Model-Driven App

1. **Open App Designer**
   - Go to https://make.powerapps.com
   - Click **Apps**
   - **Option A:** Click **+ New app** → **Model-driven**
   - **Option B:** Select existing app → Click **Edit**

2. **Select Table & Form**
   - Choose a table (e.g., Account, Contact, Custom table)
   - Click **Forms** under that table
   - Click **Main form** to edit

### Add the Control to Form

3. **Add Section for Control**
   - In form designer, click where you want the control
   - Or: Click **Components** → **Section**
   - Name the section: "AI Documents & Charts"
   - Set layout: 1 column
   - Set minimum height: 400px

4. **Insert the PCF Control**
   - Click inside the new section
   - Click **Component** in left panel
   - Scroll to bottom → **Get more components**
   - In search box, type: "Code Interpreter"
   - Select **Code Interpreter Control**
   - Click **Add**

5. **Configure Control Properties**

   Select the control, then in properties panel (right side):

   **Model ID Property:**
   ```
   Property: modelId
   Type: Static Value
   Value: b412c9a3-1b4f-45c4-956d-33bd4412be33
   
   (Paste your AI prompt GUID here)
   ```

   **Entity ID Property:**
   ```
   Property: entityId
   Type: Bind to field
   Field: [Select your table's primary ID field]
   
   Example: accountid (for Account table)
           contactid (for Contact table)
           your_custom_table_id (for custom tables)
   ```

   **Optional - Height:**
   ```
   Property: height
   Value: 500
   ```

6. **Save and Publish**
   - Click **Save** (top-right)
   - Click **Publish** (top-right)
   - Wait for "Published successfully" message

7. **Test in App**
   - Click **Play** button (top-right)
   - Or go to Apps list and open the app
   - Navigate to a record
   - **You should see the control!** 🎉

---

## ✅ STEP 5: Test & Validate

### Testing Checklist

**Initial Load:**
- [ ] Control appears on the form
- [ ] No errors in browser console (F12)
- [ ] Loading spinner shows briefly
- [ ] Result displays within 5-15 seconds

**Document Generation:**
- [ ] PDF preview appears inline
- [ ] Download button works
- [ ] Word documents show preview
- [ ] Excel tables display correctly

**Chart Generation:**
- [ ] HTML chart renders
- [ ] Interactive features work
- [ ] Colors and styling are correct
- [ ] Tooltips appear on hover

**Error Handling:**
- [ ] Invalid Model ID shows error message
- [ ] Network errors are handled gracefully
- [ ] Timeout scenarios show retry option

### Test with Real Data

1. Open several different records
2. Verify control works for each
3. Check data accuracy in generated outputs
4. Test edge cases (empty data, large data, etc.)

### User Acceptance Testing

1. Have actual users test the control
2. Gather feedback on usability
3. Identify any issues or confusion
4. Refine prompts if needed

---

## 📋 Quick Commands Reference

### Build & Package

```powershell
# Automated build (recommended)
.\Build-ForPowerApps.ps1

# Custom publisher
.\Build-ForPowerApps.ps1 -PublisherName "YourCompany" -PublisherPrefix "yourco"

# Clean build
.\Build-ForPowerApps.ps1 -CleanFirst
```

### Import to Power Apps

```powershell
# Authenticate
pac auth create --url https://yourorg.crm.dynamics.com

# Import
pac solution import --path "solutions\CodeInterpreterControl.zip"

# Verify
pac solution list
```

### Query AI Models

```powershell
# List all AI models (get Model IDs)
pac data list --entity-name msdyn_aimodel

# Or use Web API
$url = "https://yourorg.crm.dynamics.com/api/data/v9.2/msdyn_aimodels"
```

---

## 📚 Documentation Index

Your `CodeInterpreterControl` folder now contains these guides:

| File | Purpose | When to Use |
|------|---------|-------------|
| **THIS FILE** | Complete overview | Read first |
| `DEPLOY-TO-POWERAPPS.md` | Detailed deployment steps | During deployment |
| `DEPLOYMENT-FLOW.md` | Visual flow diagram | Quick reference |
| `Build-ForPowerApps.ps1` | Automated build script | Run to build |
| `TEST-HARNESS-README.md` | Local demo guide | Testing locally |
| `QUICK-START.md` | Quick reference | Fast answers |
| `SUCCESS.md` | Demo summary | Demo overview |
| `test-harness.html` | Interactive demo | Browser testing |
| `Start-TestHarness.ps1` | Demo launcher | Run demo |

---

## ❓ Common Questions

### Q: Do I need to stop the local demo server?

**A:** No! The local demo and Power Apps deployment are independent. You can keep the demo running while you deploy to Power Apps.

### Q: How much does this cost?

**A:** 
- Power Apps Premium license: ~$20/user/month
- AI Builder capacity: Included (500-1000 credits)
- Code Interpreter calls: ~5-10 credits per execution
- Typical usage: 350 credits/user/month (within included allocation)

### Q: Can I use this in Canvas Apps?

**A:** PCF controls have limited support in Canvas Apps. **Model-Driven Apps are strongly recommended** for this control.

### Q: What if my AI prompt fails?

**A:** 
1. Test the prompt directly in AI Hub
2. Check Model ID is correct
3. Verify Code Interpreter is enabled
4. Ensure input schema has "RecordId" (case-sensitive)
5. Check AI Builder capacity is available

### Q: Can users see the control without Premium license?

**A:** No. Users need:
- Power Apps Premium license
- AI Builder license (usually included)
- Appropriate security role

### Q: How long does AI processing take?

**A:** Typically 5-15 seconds. Complex documents may take up to 30 seconds.

### Q: Can I customize the control appearance?

**A:** Yes! Edit the TypeScript source code, rebuild, and redeploy. The control supports custom CSS.

### Q: What happens if network fails during AI call?

**A:** The control shows an error message with retry option. Implement proper error handling in your prompts.

### Q: Can I generate multiple documents at once?

**A:** Yes, but it requires custom prompt logic. Each control instance handles one prompt execution.

### Q: How do I update the control after changes?

**A:** 
1. Make code changes
2. Run `.\Build-ForPowerApps.ps1`
3. Import the new ZIP (as upgrade)
4. Publish forms again

---

## 🎯 Success Criteria

You'll know it's working when:

- ✅ Control appears in Power Apps form
- ✅ Loading spinner shows when opening records
- ✅ AI generates documents/charts successfully
- ✅ Results display within 15 seconds
- ✅ Users can download generated files
- ✅ No errors in browser console
- ✅ Multiple users can access it
- ✅ Performance is acceptable

---

## 🚀 Next Steps After Deployment

### Week 1: Initial Rollout
- Deploy to test environment
- Train power users
- Gather initial feedback
- Monitor AI Builder usage

### Week 2-4: Refinement
- Adjust AI prompts based on feedback
- Add more prompt variations
- Create user documentation
- Monitor performance metrics

### Month 2+: Expansion
- Add to more forms
- Create additional prompts
- Integrate with workflows
- Scale to more users

---

## 📞 Getting Help

### Issues with Building/Packaging:
- Check: Build error messages
- Review: `Build-ForPowerApps.ps1` output
- Verify: Prerequisites installed
- Try: Clean build with `-CleanFirst`

### Issues with Power Apps:
- Check: Solution import logs
- Verify: Environment permissions
- Review: Browser console (F12)
- Test: In different environment

### Issues with AI Prompts:
- Test: Prompt directly in AI Hub
- Check: Code Interpreter is enabled
- Verify: Input/output schema
- Review: AI Builder capacity

### Community Resources:
- Power Apps Community: https://powerusers.microsoft.com/
- Microsoft Learn: https://learn.microsoft.com/power-apps/
- GitHub Samples: https://github.com/microsoft/PowerApps-Samples

---

## 🎊 Congratulations!

You now have:
- ✅ Working local demo
- ✅ Complete build process
- ✅ Deployment documentation
- ✅ Production-ready PCF control
- ✅ AI-powered capabilities

**You're ready to transform Power Apps with AI! 🚀**

### Share Your Success!
- Show stakeholders the demo
- Deploy to production
- Train users
- Measure business impact

**Happy Building! 🎉**
