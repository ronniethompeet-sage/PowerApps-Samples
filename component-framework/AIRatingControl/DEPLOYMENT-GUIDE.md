# AI Rating Control - PCF Custom Component

A Power Apps Component Framework (PCF) control that integrates with the built-in AI Builder "AI Rating" model for sentiment analysis with fully customizable text boxes.

## 🎯 Features

- **Custom Input Text Box**: Fully styled text area for user input
- **AI Rating Integration**: Uses the built-in AI Builder AI Rating model for sentiment analysis
- **Custom Output Text Box**: Displays AI analysis results with configurable styling
- **15 Configurable Properties**: Complete control over colors, fonts, borders, and text
- **Fluent Design**: Professional Microsoft Fluent UI styling
- **Real-time Analysis**: Interactive "Analyze" button with loading states
- **Dataverse WebAPI**: Direct integration with Dataverse for AI model queries

## 📋 Prerequisites

- **Power Apps Premium License** (for PCF controls and AI Builder)
- **PAC CLI** - Power Platform CLI tools
- **Node.js LTS** (v18 or higher)
- **VS Code** (recommended)
- **AI Builder** access in your environment
- **AI Rating Model** configured in AI Builder

## 🚀 Quick Start

### 1. Build the Control

```powershell
cd AIRatingControl
npm run build
```

### 2. Test Locally

```powershell
npm run start:watch
```

This opens the test harness at `http://localhost:8181` where you can:
- Enter text in the input box
- Click "Analyze with AI Rating"
- See sentiment analysis results
- Test all custom styling properties

### 3. Create Solution

```powershell
cd ..
pac solution init --publisher-name Contoso --publisher-prefix con
```

### 4. Add Control to Solution

```powershell
pac solution add-reference --path .\AIRatingControl
```

### 5. Build Solution

```powershell
msbuild /t:build /restore
```

### 6. Deploy to Dataverse

```powershell
pac solution import --path bin\Debug\AIRatingSolution.zip
```

## 🎨 Configurable Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `inputText` | String | "" | Bound field for input text |
| `inputBackgroundColor` | String | #ffffff | Input box background color |
| `inputTextColor` | String | #323130 | Input text color |
| `inputBorderColor` | String | #8a8886 | Input border color |
| `inputFontSize` | Number | 14 | Input font size (px) |
| `inputPlaceholder` | String | "Enter text..." | Input placeholder text |
| `outputBackgroundColor` | String | #f3f2f1 | Output box background color |
| `outputTextColor` | String | #323130 | Output text color |
| `outputBorderColor` | String | #0078d4 | Output border color |
| `outputFontSize` | Number | 14 | Output font size (px) |
| `buttonBackgroundColor` | String | #0078d4 | Button background color |
| `buttonTextColor` | String | #ffffff | Button text color |
| `buttonText` | String | "Analyze..." | Button label text |
| `textBoxHeight` | Number | 200 | Height of text boxes (px) |
| `aiResult` | String | null | JSON output of AI analysis |

## 📁 Project Structure

```
AIRatingControl/
├── AIRatingControl/
│   ├── ControlManifest.Input.xml    # Control manifest with all properties
│   ├── index.ts                      # TypeScript implementation
│   ├── css/
│   │   └── AIRatingControl.css      # Fluent Design styling
│   ├── strings/
│   │   └── AIRatingControl.1033.resx # Localization strings
│   └── generated/
│       └── ManifestTypes.d.ts       # Auto-generated types
├── package.json                      # npm dependencies
└── README.md                         # This file
```

## 🔧 Implementation Details

### TypeScript Architecture

The control implements the standard PCF lifecycle:

```typescript
export class AIRatingControl implements ComponentFramework.StandardControl<IInputs, IOutputs> {
    // Lifecycle methods
    public init()          // Initialize UI and event handlers
    public updateView()    // Handle property changes
    public getOutputs()    // Return bound values
    public destroy()       // Cleanup
    
    // Custom methods
    private createUI()                  // Build DOM elements
    private applyCustomStyling()        // Apply property-based styling
    private callAIRatingModel()         // Query AI Builder model
    private analyzeSentiment()          // Fallback sentiment analysis
    private formatAIResult()            // Format display output
}
```

### AI Rating Integration

The control uses Dataverse WebAPI to query the AI Rating model:

```typescript
// 1. Find the AI Rating model
const modelQuery = "msdyn_aimodels?$filter=msdyn_name eq 'AI Rating'";
const modelResponse = await this._context.webAPI.retrieveMultipleRecords("msdyn_aimodel", modelQuery);

// 2. Call the prediction API
const modelId = modelResponse.entities[0].msdyn_aimodelid;
// ... prediction call implementation
```

### Custom Styling System

All styling is driven by component properties:

```typescript
private applyCustomStyling(): void {
    this._inputTextArea.style.backgroundColor = 
        this._context.parameters.inputBackgroundColor?.raw || "#ffffff";
    this._inputTextArea.style.color = 
        this._context.parameters.inputTextColor?.raw || "#323130";
    // ... more styling
}
```

## 🧪 Testing

### Local Test Harness

```powershell
npm run start:watch
```

Test the control with:
1. Different text inputs (positive, negative, neutral)
2. Various styling combinations
3. Error handling scenarios
4. Loading states

### Unit Tests

```powershell
npm test
```

### Integration Testing

After deployment, test in:
- Model-driven apps
- Canvas apps (custom controls)
- Power Pages

## 📦 Deployment

### Option 1: Manual Import

1. Build the solution
2. Navigate to Power Apps maker portal
3. Solutions → Import
4. Select the `.zip` file
5. Import and publish

### Option 2: PAC CLI

```powershell
pac auth create --environment {env-id}
pac solution import --path bin\Debug\AIRatingSolution.zip
```

### Option 3: Azure DevOps Pipeline

```yaml
- task: PowerPlatformToolInstaller@2
- task: PowerPlatformImportSolution@2
  inputs:
    authenticationType: 'PowerPlatformSPN'
    PowerPlatformSPN: $(ServiceConnection)
    SolutionInputFile: '$(Build.ArtifactStagingDirectory)\AIRatingSolution.zip'
```

## 🎯 Usage in Apps

### In Model-Driven Apps

1. Open form editor
2. Select a text field
3. Components → Add component
4. Select "AI Rating Control"
5. Configure styling properties
6. Save and publish

### In Canvas Apps

1. Insert → Custom → Import component
2. Code components tab
3. Import the control
4. Add to screen
5. Bind to data source
6. Configure properties in Properties pane

## 🔍 Troubleshooting

### Build Errors

**Issue**: ESLint errors about `any` type
```typescript
// ❌ Wrong
catch (error: any)

// ✅ Correct
catch (error: unknown) {
    const errorMessage = error instanceof Error ? error.message : "Unknown error";
}
```

**Issue**: Missing manifest types
```powershell
npm run refreshTypes
```

### Runtime Errors

**Issue**: "AI Rating model not found"
- Verify AI Builder is enabled in the environment
- Check that AI Rating model exists in AI Builder
- Ensure proper permissions to `msdyn_aimodel` entity

**Issue**: WebAPI permission denied
- Add security role with read permissions to `msdyn_aimodel`
- Check Dataverse WebAPI is enabled

### Styling Issues

**Issue**: Colors not applying
- Ensure hex format includes `#` (e.g., `#0078d4`)
- Check browser console for CSS errors
- Verify property values are properly bound

## 📚 Additional Resources

- [PCF Documentation](https://learn.microsoft.com/power-apps/developer/component-framework/)
- [AI Builder AI Rating](https://learn.microsoft.com/ai-builder/prebuilt-sentiment-analysis)
- [PAC CLI Reference](https://learn.microsoft.com/power-platform/developer/cli/reference/pcf)
- [Dataverse WebAPI](https://learn.microsoft.com/power-apps/developer/data-platform/webapi/overview)

## 📝 License

This project follows Microsoft's Power Apps sample license.

## 🤝 Contributing

Contributions welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📧 Support

For issues and questions:
- Power Platform Community: https://powerusers.microsoft.com
- GitHub Issues: Create an issue in this repository

---

**Built with ❤️ using Power Apps Component Framework**
