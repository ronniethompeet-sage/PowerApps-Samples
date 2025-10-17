# 🚀 Deploy Code Interpreter Control to Power Apps

## Complete Step-by-Step Guide

This guide walks you through deploying the Code Interpreter PCF control into Power Apps so users can leverage AI-powered document generation and data visualization in real applications.

---

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Build the PCF Control](#build-the-pcf-control)
3. [Create Solution Package](#create-solution-package)
4. [Import to Power Apps](#import-to-power-apps)
5. [Configure AI Code Interpreter Prompts](#configure-ai-code-interpreter-prompts)
6. [Add Control to Canvas App](#add-control-to-canvas-app)
7. [Add Control to Model-Driven App](#add-control-to-model-driven-app)
8. [Testing & Validation](#testing--validation)
9. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### ✅ Required Tools

1. **Power Platform CLI (PAC CLI)**
   ```powershell
   # Install via winget
   winget install Microsoft.PowerPlatformCLI
   
   # Or via PowerShell
   Install-Module -Name Microsoft.PowerApps.CLI.Core -Scope CurrentUser
   
   # Verify installation
   pac --version
   ```

2. **Node.js (v14 or later)**
   ```powershell
   # Check if installed
   node --version
   npm --version
   
   # Download from: https://nodejs.org/
   ```

3. **Visual Studio Build Tools** (for msbuild)
   ```powershell
   # Download from:
   # https://visualstudio.microsoft.com/downloads/
   # Select: "Build Tools for Visual Studio 2022"
   # Install: .NET desktop build tools workload
   ```

### ✅ Required Permissions

- **Power Apps Environment Access:** System Administrator or System Customizer role
- **AI Builder Access:** Environment must have AI Builder enabled
- **Solution Management:** Permission to import/export solutions

### ✅ Environment Requirements

- **Power Apps Environment:** Premium license (Code Interpreter requires AI Builder)
- **Dataverse Enabled:** Required for model-driven apps
- **AI Builder Capacity:** Code Interpreter consumes AI Builder credits

---

## 🔨 Build the PCF Control

### Step 1: Navigate to Control Directory

```powershell
cd "PowerApps-Samples\component-framework\CodeInterpreterControl"
```

### Step 2: Install Dependencies

```powershell
# Install all npm packages
npm install

# This will install:
# - PCF build tools
# - mammoth (Word preview)
# - xlsx (Excel handling)
# - TypeScript compiler
# - ESLint and other dev tools
```

**Expected Output:**
```
added 150 packages in 45s
✅ Dependencies installed successfully
```

### Step 3: Build the Control

```powershell
# Build the PCF control
npm run build

# This compiles TypeScript to JavaScript
# and creates the control bundle
```

**Expected Output:**
```
[12:34:56 PM] [build]  Initializing...
[12:34:57 PM] [build]  Validating manifest...
[12:34:57 PM] [build]  Generating manifest types...
[12:34:58 PM] [build]  Compiling and bundling control...
[12:35:00 PM] [build]  Generating build outputs...
[12:35:01 PM] [build]  Succeeded
✅ Build completed successfully
```

### Step 4: Verify Build Output

```powershell
# Check the output folder
ls .\out\controls\

# You should see:
# - CodeInterpreterControl.js
# - CodeInterpreterControl.css (if any)
# - bundle.js
```

---

## 📦 Create Solution Package

### Step 1: Initialize Solution

```powershell
# Create a new solution folder (if not exists)
mkdir solutions -ErrorAction SilentlyContinue
cd solutions

# Initialize new solution
pac solution init --publisher-name "YourCompany" --publisher-prefix "yourprefix"

# Example:
pac solution init --publisher-name "ContosoSoft" --publisher-prefix "contoso"
```

**What This Does:**
- Creates solution structure
- Generates `src` folder
- Creates solution XML files

### Step 2: Add PCF Control Reference

```powershell
# Add the control to the solution
pac solution add-reference --path ".."

# The ".." points to the parent folder containing the .pcfproj file
```

**Expected Output:**
```
✅ Reference added successfully
Project reference added to solution.
```

### Step 3: Build the Solution Package

```powershell
# Build the solution using msbuild
msbuild /t:build /restore /p:configuration=Release

# Or use PAC CLI
pac solution pack --zipfile CodeInterpreterControl.zip
```

**Expected Output:**
```
Build succeeded.
    0 Warning(s)
    0 Error(s)

✅ Solution package created: CodeInterpreterControl.zip
```

### Step 4: Locate Your Solution Package

```powershell
# The ZIP file will be in:
# solutions\bin\Release\CodeInterpreterControl.zip

# Or in current directory if using pac solution pack
ls *.zip
```

---

## 📥 Import to Power Apps

### Method 1: Using Power Apps Portal (Recommended)

#### Step 1: Open Power Apps
1. Navigate to https://make.powerapps.com
2. Select your environment (top-right corner)
3. Ensure it's the correct environment with AI Builder

#### Step 2: Navigate to Solutions
1. Click **Solutions** in left navigation
2. Click **Import solution** at the top

   ![Import Solution Button](https://learn.microsoft.com/power-apps/maker/data-platform/media/import-solution/import-solution-button.png)

#### Step 3: Import the Package
1. Click **Browse**
2. Select `CodeInterpreterControl.zip`
3. Click **Next**
4. Review details
5. Click **Import**

   **Wait Time:** 2-5 minutes depending on solution size

#### Step 4: Verify Import
1. Go to **Solutions**
2. Find your solution (e.g., "CodeInterpreterControl")
3. Open it
4. Expand **Controls**
5. You should see **CodeInterpreterControl**

### Method 2: Using PAC CLI

```powershell
# Authenticate to your environment
pac auth create --url https://yourorg.crm.dynamics.com

# Import the solution
pac solution import --path "solutions\bin\Release\CodeInterpreterControl.zip"

# Wait for completion
# Check status
pac solution list
```

---

## 🤖 Configure AI Code Interpreter Prompts

Before the control works, you need to create Code Interpreter-enabled AI prompts.

### Step 1: Navigate to AI Hub

1. Go to https://make.powerapps.com
2. Click **AI hub** in left navigation
3. Click **Prompts**

### Step 2: Create Document Generation Prompt

#### Option A: Import Sample Prompts (Easy)

If you imported the sample solution (`CodeInterpreterSample_1_0_0_0_managed.zip`), you already have three sample prompts:

1. **Create sample data for the example table**
2. **Example Sales Proposal document**
3. **Example Interactive Row Summary Chart**

Skip to [Get Model IDs](#get-model-ids)

#### Option B: Create Your Own Prompt (Custom)

1. Click **+ New prompt**
2. Name it: "Generate Sales Document"
3. Add configuration:
   ```
   Prompt Type: Code Interpreter
   
   Input Schema:
   {
     "RecordId": {
       "type": "string",
       "description": "The ID of the record to generate document for"
     }
   }
   
   Prompt Text:
   Generate a professional sales proposal document for the record with ID: {RecordId}
   
   Include:
   - Executive summary
   - Key metrics from the record
   - Recommendations
   - Professional formatting
   
   Return as a PDF document.
   
   Output: File (PDF)
   ```

4. **Enable Code Interpreter:**
   - Toggle **Code Interpreter** to ON
   - This allows the AI to generate files

5. Click **Test** to verify it works
6. Click **Save**

### Step 3: Create Chart Generation Prompt

1. Click **+ New prompt**
2. Name it: "Generate Interactive Chart"
3. Add configuration:
   ```
   Prompt Type: Code Interpreter
   
   Input Schema:
   {
     "RecordId": {
       "type": "string",
       "description": "The ID of the record to visualize"
     }
   }
   
   Prompt Text:
   Create an interactive HTML chart visualizing data from record: {RecordId}
   
   Requirements:
   - Use Chart.js or similar JavaScript library
   - Make it visually appealing
   - Include legend and labels
   - Return as HTML with inline JavaScript
   
   Output: Text (HTML)
   ```

4. **Enable Code Interpreter:** Toggle ON
5. Test and Save

### Step 4: Get Model IDs

You need the AI Model GUIDs to configure the control.

#### Option A: From UI
1. Open your prompt in AI Hub
2. Look at the URL:
   ```
   https://make.powerapps.com/...&promptid=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
   ```
3. Copy the GUID (the `promptid` parameter)

#### Option B: Using Power Platform CLI

```powershell
# List all AI models
pac data list --entity-name msdyn_aimodel

# Or query specific model
pac data read --entity-name msdyn_aimodel --id "model-name"
```

#### Option C: Using Dataverse API (Advanced)

```powershell
# Query AI Models table
$url = "https://yourorg.crm.dynamics.com/api/data/v9.2/msdyn_aimodels?`$select=msdyn_aimodelid,msdyn_name"

# Use Postman or PowerShell to call this endpoint
# You'll need proper authentication
```

**Save These GUIDs!** You'll need them to configure the control.

Example:
```
Document Generation Model ID: b412c9a3-1b4f-45c4-956d-33bd4412be33
Chart Generation Model ID:    6ed18606-78da-4903-a868-73c7b462b336
```

---

## 🎨 Add Control to Canvas App

Canvas Apps have limited PCF support. Code Interpreter Control works best in **Model-Driven Apps**.

However, if you want to use it in Canvas:

### Step 1: Create or Open Canvas App

1. Go to https://make.powerapps.com
2. Click **Apps** → **+ New app** → **Canvas**
3. Choose **Tablet** or **Phone** layout

### Step 2: Add Component

1. Click **Insert** tab
2. Click **Get more components**
3. Search for "Code Interpreter"
4. Select **CodeInterpreterControl**
5. Click **Import**

### Step 3: Add Control to Screen

1. Drag **CodeInterpreterControl** from Components
2. Place it on your screen

### Step 4: Configure Properties

Select the control and set properties:

```javascript
// Model ID property
"b412c9a3-1b4f-45c4-956d-33bd4412be33"

// Entity ID property (bind to a variable or data source)
varSelectedRecordId

// Or from gallery:
Gallery1.Selected.ID
```

### Step 5: Test

1. Click **Play** (F5)
2. Ensure a record is selected
3. Control should execute the AI prompt
4. View the output

**Note:** Canvas App support is limited. Model-Driven Apps are recommended.

---

## 🏢 Add Control to Model-Driven App

This is the **recommended approach** for Code Interpreter Control.

### Step 1: Create Custom Table (Optional)

If you don't have a table yet:

1. Go to **Dataverse** → **Tables**
2. Click **+ New table**
3. Name it: "Sales Record" or use existing table
4. Add columns as needed
5. Save and publish

### Step 2: Create or Open Model-Driven App

1. Go to https://make.powerapps.com
2. Click **Apps**
3. **Option A:** Create new
   - Click **+ New app** → **Model-driven**
   - Name it: "AI Document Generator"
   - Click **Create**

4. **Option B:** Edit existing
   - Find your app
   - Click **Edit** (pencil icon)

### Step 3: Open Form Editor

1. In the app designer, expand your table
2. Click **Forms**
3. Select the **Main form** (e.g., "Information")
4. Click **Edit form**

### Step 4: Add Control Section

1. In the form designer:
   - Click where you want the control
   - Or add a new **Section**:
     - Click **Components** → **Section**
     - Name it: "AI Visualizations" or "Document Generator"

2. Configure the section:
   - **Layout:** 1 column
   - **Width:** Full width
   - **Height:** At least 400px

### Step 5: Add the PCF Control

1. Click inside the section
2. Click **Component** in the left panel
3. At the bottom, click **Get more components**
4. Search for "Code Interpreter Control"
5. Select it
6. Click **Add**

### Step 6: Configure Control Properties

1. Select the control in the form
2. Properties panel opens on the right

3. **Set Model ID:**
   ```
   Property: modelId
   Value: b412c9a3-1b4f-45c4-956d-33bd4412be33
   
   (Paste the GUID from your AI prompt)
   ```

4. **Set Entity ID:**
   ```
   Property: entityId
   Binding: Bind to table column
   Column: Choose the primary ID column (e.g., "Example (GUID)")
   
   Or use the record's ID directly
   ```

5. **Optional: Set Height**
   ```
   Property: height
   Value: 500 (pixels)
   ```

### Step 7: Save and Publish

1. Click **Save** (top-right)
2. Click **Publish** (top-right)
3. Wait for publishing to complete (~30 seconds)

### Step 8: Open the App

1. Click **Play** (top-right)
2. Or go back to Apps list and launch the app
3. Open a record
4. **You should see the control!**

---

## 🎯 Configure Different Scenarios

### Scenario 1: Document Generation (PDF/Word/Excel)

**Use Case:** Generate sales proposals, reports, invoices

**Configuration:**
```
Model ID: <Your Document Generation Prompt GUID>
Entity ID: Bound to current record ID

Prompt Setup:
- Input: RecordId (string)
- Output: File (PDF, DOCX, XLSX, or PPTX)
- Code Interpreter: Enabled
```

**What Users See:**
1. Control shows loading spinner
2. AI generates the document
3. Preview appears (for PDF/Word/Excel)
4. Download button available

### Scenario 2: Interactive Charts

**Use Case:** Visualize record data, comparisons, trends

**Configuration:**
```
Model ID: <Your Chart Generation Prompt GUID>
Entity ID: Bound to current record ID

Prompt Setup:
- Input: RecordId (string)
- Output: Text (HTML with JavaScript)
- Code Interpreter: Enabled
```

**What Users See:**
1. Control executes prompt
2. AI generates HTML/JS chart
3. Interactive chart renders in control
4. Users can hover/interact with chart

### Scenario 3: Multi-Record Comparison

**Use Case:** Compare multiple records side-by-side

**Configuration:**
```
Model ID: <Comparison Chart Prompt GUID>
Entity ID: Parent record or filter criteria

Prompt Setup:
- Input: RecordId or filter
- Logic: Query related records
- Output: Comparison HTML visualization
```

---

## ✅ Testing & Validation

### Test Checklist

1. **Basic Functionality**
   - [ ] Control loads in the form
   - [ ] No console errors (F12 DevTools)
   - [ ] Spinner appears when loading
   - [ ] Model ID is correct

2. **AI Integration**
   - [ ] Prompt executes successfully
   - [ ] Response is received
   - [ ] Output is parsed correctly
   - [ ] Error handling works

3. **Document Preview**
   - [ ] PDF displays inline
   - [ ] Word documents preview correctly
   - [ ] Excel tables render properly
   - [ ] PowerPoint shows download option

4. **Chart Rendering**
   - [ ] HTML charts display
   - [ ] JavaScript executes
   - [ ] Charts are interactive
   - [ ] Styling is correct

5. **User Experience**
   - [ ] Loading states are clear
   - [ ] Errors show helpful messages
   - [ ] Download buttons work
   - [ ] Performance is acceptable

### Testing Steps

#### Test Document Generation:

1. Open a record in your model-driven app
2. Observe the control area
3. **Expected:** Loading spinner appears
4. **Wait:** 5-15 seconds for AI processing
5. **Expected:** Document preview or download button appears
6. Click download (if applicable)
7. **Expected:** File downloads successfully

#### Test Chart Generation:

1. Open a record with numeric data
2. Observe the control area
3. **Expected:** Loading spinner appears
4. **Wait:** 5-15 seconds for AI processing
5. **Expected:** Interactive chart appears
6. Hover over chart elements
7. **Expected:** Tooltips/interactions work

### Common Test Scenarios

```
Scenario 1: First Load
✅ Control initializes
✅ Calls AI prompt
✅ Displays result

Scenario 2: Record Change
✅ Control detects record change
✅ Re-executes prompt
✅ Updates display

Scenario 3: Error Handling
✅ Invalid Model ID → Shows error message
✅ Network failure → Shows retry option
✅ Invalid output → Shows friendly error
```

---

## 🐛 Troubleshooting

### Issue 1: Control Not Appearing

**Symptoms:**
- Form loads but control area is blank
- No errors in console

**Solutions:**
1. **Verify import:**
   ```powershell
   # Check if solution imported
   pac solution list
   ```

2. **Check form configuration:**
   - Open form in designer
   - Verify control is added
   - Check if section is visible
   - Publish the form again

3. **Clear browser cache:**
   ```javascript
   // Press Ctrl+Shift+Delete
   // Clear cached images and files
   // Close and reopen browser
   ```

### Issue 2: "Invalid Model ID" Error

**Symptoms:**
- Control shows error message
- "Model not found" or similar

**Solutions:**
1. **Verify Model ID:**
   ```powershell
   # Query AI models
   pac data list --entity-name msdyn_aimodel
   
   # Check the GUID is correct
   ```

2. **Check permissions:**
   - User needs AI Builder access
   - Prompt must be shared with users
   - Environment must have AI Builder

3. **Verify prompt configuration:**
   - Prompt must have Code Interpreter enabled
   - Input schema must include "RecordId"
   - Prompt must be published

### Issue 3: AI Prompt Fails

**Symptoms:**
- Control shows "Error processing request"
- Response is empty or invalid

**Solutions:**
1. **Test prompt directly:**
   - Go to AI Hub → Prompts
   - Open your prompt
   - Click **Test**
   - Use sample input: `{"RecordId": "test-123"}`
   - Verify it returns expected output

2. **Check prompt configuration:**
   ```
   ✅ Code Interpreter: Enabled
   ✅ Input: Has "RecordId" parameter (case-sensitive!)
   ✅ Output: Returns File OR Text
   ✅ Status: Published
   ```

3. **Review AI Builder capacity:**
   - Go to Power Platform admin center
   - Check AI Builder credits
   - Ensure environment has available capacity

### Issue 4: Document Preview Not Working

**Symptoms:**
- Download button appears but no preview
- "Unable to preview" message

**Solutions:**
1. **Check file format:**
   - PDF: Should preview inline
   - Word (.docx): Uses mammoth library
   - Excel (.xlsx): Uses xlsx library
   - PowerPoint (.pptx): Download only

2. **Verify dependencies:**
   ```powershell
   # Check if libraries are bundled
   cd CodeInterpreterControl
   npm list mammoth xlsx
   
   # Should show:
   # ├── mammoth@1.9.1
   # └── xlsx@0.18.5
   ```

3. **Check console for errors:**
   - Press F12
   - Look for JavaScript errors
   - Common issues:
     - CORS errors
     - Library loading failures
     - Invalid base64 content

### Issue 5: Performance Problems

**Symptoms:**
- Control takes too long to load
- App becomes slow or unresponsive

**Solutions:**
1. **Optimize AI prompt:**
   - Reduce output size
   - Limit data processing
   - Use efficient queries

2. **Add loading indicators:**
   - Ensure spinner is visible
   - Set appropriate timeout
   - Show progress messages

3. **Cache results:**
   - Consider caching AI responses
   - Implement client-side caching
   - Reduce API calls

### Issue 6: Permission Errors

**Symptoms:**
- "Access denied" or "Unauthorized"
- Control loads but prompt fails

**Solutions:**
1. **Check user permissions:**
   - User needs AI Builder license
   - Security role must include AI Builder privileges
   - Prompt must be shared with user

2. **Verify environment:**
   - Environment must be premium
   - AI Builder must be enabled
   - User must have access to environment

3. **Check Dataverse permissions:**
   - User can read records
   - User can execute prompts
   - User can access msdyn_aimodel table

---

## 📊 Monitoring & Analytics

### Monitor AI Builder Usage

1. Go to **Power Platform Admin Center**
2. Select your environment
3. Click **Analytics** → **AI Builder**
4. View:
   - Prompt execution count
   - Success/failure rates
   - Average execution time
   - Credit consumption

### Monitor PCF Control Performance

```javascript
// Add to control code for monitoring
console.time('AIPromptExecution');
// ... execute prompt ...
console.timeEnd('AIPromptExecution');

// Expected: 5-15 seconds for most prompts
```

---

## 🎓 Best Practices

### 1. Prompt Design
- ✅ Keep prompts focused and specific
- ✅ Provide clear instructions to AI
- ✅ Use consistent input/output schemas
- ✅ Test with various record types

### 2. Error Handling
- ✅ Always show user-friendly error messages
- ✅ Provide retry options
- ✅ Log errors for troubleshooting
- ✅ Handle timeout scenarios

### 3. Performance
- ✅ Use loading indicators
- ✅ Set realistic timeouts (30-60 seconds)
- ✅ Optimize prompt instructions
- ✅ Consider caching for repeated requests

### 4. User Experience
- ✅ Provide clear instructions
- ✅ Show progress updates
- ✅ Enable download options
- ✅ Make previews accessible

### 5. Security
- ✅ Validate input data
- ✅ Sanitize AI responses
- ✅ Implement proper access controls
- ✅ Monitor for abuse

---

## 📚 Additional Resources

- [PCF Control Documentation](https://learn.microsoft.com/power-apps/developer/component-framework/overview)
- [Code Interpreter for Prompts](https://learn.microsoft.com/microsoft-copilot-studio/code-interpreter-for-prompts)
- [AI Builder in Power Apps](https://learn.microsoft.com/ai-builder/overview)
- [Power Platform CLI](https://learn.microsoft.com/power-platform/developer/cli/introduction)
- [Model-Driven App Forms](https://learn.microsoft.com/power-apps/maker/model-driven-apps/form-designer-overview)

---

## 🎉 Success!

Once deployed, users can:
- 📄 Generate professional documents with AI
- 📊 Create interactive visualizations
- 🤖 Leverage Code Interpreter capabilities
- ✨ Enhance productivity with automation

**Your PCF control is now in production! 🚀**
