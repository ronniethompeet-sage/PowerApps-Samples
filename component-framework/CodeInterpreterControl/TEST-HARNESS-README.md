# 🤖 Code Interpreter Control - Interactive Test Harness

An interactive web-based testing environment for the PCF Code Interpreter Control that demonstrates AI-powered document generation and data visualization capabilities.

## 🎯 What This Does

This test harness provides a **visual demonstration** of the Code Interpreter PCF control without requiring:
- Power Apps environment
- Dataverse connection
- Actual AI model deployment
- Complex authentication

Instead, it simulates the control's behavior with pre-configured examples that show exactly how the control works in production.

## 🚀 Quick Start

### Option 1: PowerShell Launcher (Recommended)

```powershell
# Navigate to the CodeInterpreterControl folder
cd "PowerApps-Samples\component-framework\CodeInterpreterControl"

# Run the launcher script
.\Start-TestHarness.ps1

# Or specify a custom port
.\Start-TestHarness.ps1 -Port 8082

# Run without auto-opening browser
.\Start-TestHarness.ps1 -OpenBrowser:$false
```

The script will:
1. ✅ Detect available HTTP server (Python, Node.js, or fallback)
2. 🌐 Start local web server on port 8082 (or your specified port)
3. 🚀 Automatically open browser to test harness
4. 📊 Ready to demonstrate PCF control capabilities

### Option 2: Direct File Open

Simply double-click `test-harness.html` to open in your default browser. Note that some features may be limited without a local server.

## 📋 Features Demonstrated

### 1. Interactive Chart Generation 📊

The control can execute AI prompts that generate dynamic visualizations:

- **Bar Charts** - Sales performance, quarterly comparisons
- **Line Charts** - Trend analysis, growth metrics
- **Pie Charts** - Market share, distribution data
- **Comparison Charts** - Multi-record credit limit analysis

**What You See:**
- Real-time chart generation
- Multiple chart types
- Interactive configuration options
- Model ID and Record ID binding

**Production Behavior:**
The control sends a request to an AI Code Interpreter-enabled prompt, which returns HTML/JavaScript visualization code that gets rendered in the control container.

### 2. Document Preview & Download 📄

The control can display and download AI-generated documents:

- **PDF Documents** - Inline preview with download option
- **Word Documents (.docx)** - Preview using mammoth library
- **Excel Spreadsheets (.xlsx)** - Table preview using xlsx library
- **PowerPoint (.pptx)** - Slide preview with download

**What You See:**
- Formatted document previews
- Download buttons
- Multiple document formats
- Professional layouts

**Production Behavior:**
The AI prompt generates a document (PDF, Word, Excel, or PowerPoint), returns it as base64-encoded content, and the control either previews it inline or provides a download link.

## 🎨 Interactive Demo Sections

### Demo Card 1: Interactive Chart Demo

**Configuration Options:**
- **Model ID:** GUID of the AI prompt (Code Interpreter enabled)
- **Record ID:** Entity record GUID to pass to the prompt
- **Chart Type:** Select visualization style

**Actions:**
- **Load Chart:** Triggers AI prompt execution simulation
- **Clear:** Resets the display

**Status Indicator:** Shows Ready / Loading / Error states

### Demo Card 2: Document Preview Demo

**Configuration Options:**
- **Model ID:** GUID of document generation AI prompt
- **Record ID:** Entity record GUID for document data
- **Document Type:** PDF, Word, Excel, or PowerPoint

**Actions:**
- **Generate Document:** Simulates AI document creation
- **Clear:** Resets the display

**Download Feature:** Each document type shows appropriate download behavior

## 🔧 Technical Implementation

### Dependencies

The actual PCF control uses:

```json
{
  "mammoth": "^1.9.1",  // Word document preview
  "xlsx": "^0.18.5"     // Excel spreadsheet handling
}
```

### Control Inputs

The PCF control requires two inputs:

```typescript
modelId: string   // GUID of the AI model (Code Interpreter enabled)
entityId: string  // GUID of the record to pass to the prompt
```

### API Integration

In production, the control:

1. Validates inputs (Model ID and Record ID)
2. Calls Dataverse prediction API: `/api/data/v9.2/predictions`
3. Receives response with either:
   - Text/HTML output (for visualizations)
   - File output with base64 content (for documents)
4. Renders appropriate preview or download option

### Example Production Code

```typescript
// The control calls the AI model
const response = await retrievePromptResponse({
  baseUrl: context.page.getClientUrl(),
  modelId: "6ed18606-78da-4903-a868-73c7b462b336",
  requestInputs: { RecordId: "sample-record-001" }
});

// Handle different output types
if (response.files?.[0]) {
  // Preview/download file
  renderFilePreview(response.files[0]);
} else if (response.text) {
  // Render HTML/JavaScript visualization
  renderVisualization(response.text);
}
```

## 📖 How to Use the Test Harness

### Testing Chart Generation

1. **Navigate to "Interactive Chart Demo" card**
2. **Configure the settings:**
   - Model ID: Pre-filled with example GUID
   - Record ID: Enter sample record identifier
   - Chart Type: Select desired visualization
3. **Click "Load Chart"**
4. **Observe:** Chart renders with simulated data
5. **Try different chart types** to see variations

### Testing Document Generation

1. **Navigate to "Document Preview Demo" card**
2. **Configure the settings:**
   - Model ID: Pre-filled with example GUID
   - Record ID: Enter sample record identifier
   - Document Type: Select PDF, Word, Excel, or PowerPoint
3. **Click "Generate Document"**
4. **Observe:** Document preview with download button
5. **Try different document types** to see format handling

## 🎯 What This Demonstrates

### For Developers

- PCF control architecture and lifecycle
- AI integration patterns
- File handling and preview capabilities
- Error handling and validation
- User interface design for PCF controls

### For Business Users

- AI-powered document generation capabilities
- Dynamic visualization creation
- Multi-format support
- Real-time data processing
- Professional output quality

## 🔄 Differences from Production

| Feature | Test Harness | Production Control |
|---------|-------------|-------------------|
| **AI Integration** | Simulated with pre-generated content | Real AI Code Interpreter API calls |
| **Authentication** | None required | Dataverse authentication required |
| **Data Source** | Static sample data | Live Dataverse records |
| **Response Time** | Instant (simulated delay) | Varies based on AI processing |
| **Error Handling** | Simulated errors | Real API errors and validation |
| **File Generation** | Pre-formatted samples | AI-generated actual files |

## 🚀 Next Steps

### To Deploy This Control in Production

1. **Build the PCF component:**
   ```bash
   npm install
   npm run build
   pac solution init --publisher-name ContosoSoft --publisher-prefix contoso
   pac solution add-reference --path .
   msbuild /t:build /restore
   ```

2. **Import to Power Apps:**
   - Navigate to solutions in Power Apps
   - Import the generated solution ZIP
   - Add to a model-driven app form

3. **Configure AI Prompts:**
   - Create Code Interpreter-enabled prompts in AI Hub
   - Note the AI Model GUIDs
   - Configure control properties with those GUIDs

4. **Test in Model-Driven App:**
   - Open form with the control
   - Verify AI prompt execution
   - Test different scenarios

### To Customize This Test Harness

Edit `test-harness.html`:

- **Add new chart types:** Modify `generateSampleChart()` function
- **Add document formats:** Update `generateSampleDocument()` function
- **Change styling:** Edit the `<style>` section
- **Add real API calls:** Replace simulation with actual fetch calls

## 📚 Additional Resources

- [Power Apps Component Framework Documentation](https://learn.microsoft.com/power-apps/developer/component-framework/overview)
- [Code Interpreter for Prompts](https://learn.microsoft.com/microsoft-copilot-studio/code-interpreter-for-prompts)
- [AI Builder in Power Apps](https://learn.microsoft.com/ai-builder/overview)
- [PCF Control Samples Repository](https://github.com/microsoft/PowerApps-Samples)

## 💡 Tips & Tricks

### Performance Testing
- Use browser DevTools (F12) to monitor network and rendering
- Check console for any JavaScript errors
- Observe loading states and transitions

### Customization Ideas
- Add authentication simulation
- Implement error injection for testing
- Create different data scenarios
- Add more visualization types

### Sharing the Demo
- The test harness is self-contained (single HTML file)
- Can be hosted on any static web server
- No backend required
- Easy to share with stakeholders

## 🤝 Support & Feedback

For issues or questions about:
- **The test harness:** Check the code comments in `test-harness.html`
- **The PCF control:** Refer to the main `README.md` in this folder
- **Power Apps PCF:** Visit Microsoft Learn documentation
- **AI Builder:** Check AI Builder documentation

## 🎉 Success!

You now have a fully functional interactive test environment for demonstrating the Code Interpreter PCF control capabilities without needing a full Power Apps environment!

**Happy Testing! 🚀**
