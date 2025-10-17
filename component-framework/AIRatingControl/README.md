# AI Rating PCF Control

A custom Power Apps Component Framework (PCF) control that integrates with the built-in **AI Rating** AI Builder model to analyze and rate text input with a modern, styled interface.

## Overview

This PCF control provides:
- **Custom styled text input component** with configurable properties (colors, fonts, borders)
- **Direct integration with AI Rating model** (built-in AI Builder model)
- **Custom output text box** for displaying AI ratings and analysis
- **Real-time result display** with formatted output
- **Configurable appearance** and behavior through manifest properties
- **No Canvas App required** - deploy directly to model-driven or canvas apps as a reusable component

## Architecture

```
┌─────────────────────────────────────────────┐
│     AI Rating PCF Control                   │
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │  Custom Text Input Component        │   │
│  │  - Configurable colors              │   │
│  │  - Custom fonts & sizes             │   │
│  │  - Border styles                    │   │
│  │  - Placeholder text                 │   │
│  └─────────────────────────────────────┘   │
│                                             │
│  ┌─────────────────┐                       │
│  │  Analyze Button │ ──> AI Rating Model   │
│  └─────────────────┘      (AI Builder)     │
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │  Custom Results Text Box            │   │
│  │  - Formatted AI rating display      │   │
│  │  - Custom styling                   │   │
│  │  - Read-only output                 │   │
│  └─────────────────────────────────────┘   │
│                                             │
└─────────────────────────────────────────────┘
```

## Prerequisites

- **Power Apps CLI** (PAC CLI) installed
- **Node.js** (v16 or later)
- **TypeScript** knowledge
- **Visual Studio Code** (recommended)
- **Power Apps environment** with AI Builder enabled

## Quick Start

### Step 1: Create PCF Control Project

```bash
# Create new folder for the control
mkdir AIRatingControl
cd AIRatingControl

# Initialize PCF control
pac pcf init --namespace Contoso --name AIRatingControl --template field --run-npm-install
```

### Step 2: Project Structure

After initialization, you'll have:

```
AIRatingControl/
├── AIRatingControl/
│   ├── ControlManifest.Input.xml    # Control metadata and properties
│   ├── index.ts                     # Main control logic
│   ├── css/
│   │   └── AIRatingControl.css     # Custom styles
│   └── generated/
├── package.json
└── tsconfig.json
```

### Step 3: Define Control Manifest

Edit `ControlManifest.Input.xml`:

```xml
<?xml version="1.0" encoding="utf-8" ?>
<manifest>
  <control namespace="Contoso" constructor="AIRatingControl" version="1.0.0" 
           display-name-key="AIRating_Display_Key" 
           description-key="AIRating_Desc_Key" 
           control-type="standard">
    
    <!-- Input text property -->
    <property name="inputText" display-name-key="InputText_Display_Key" 
              description-key="InputText_Desc_Key" of-type="SingleLine.Text" 
              usage="bound" required="true" />
    
    <!-- Custom Input Text Box Styling -->
    <property name="inputBackgroundColor" display-name-key="InputBgColor_Display_Key" 
              description-key="InputBgColor_Desc_Key" of-type="SingleLine.Text" 
              usage="input" default-value="#ffffff" />
    
    <property name="inputTextColor" display-name-key="InputTextColor_Display_Key" 
              description-key="InputTextColor_Desc_Key" of-type="SingleLine.Text" 
              usage="input" default-value="#323130" />
    
    <property name="inputBorderColor" display-name-key="InputBorderColor_Display_Key" 
              description-key="InputBorderColor_Desc_Key" of-type="SingleLine.Text" 
              usage="input" default-value="#8a8886" />
    
    <property name="inputFontSize" display-name-key="InputFontSize_Display_Key" 
              description-key="InputFontSize_Desc_Key" of-type="Whole.None" 
              usage="input" default-value="14" />
    
    <property name="inputPlaceholder" display-name-key="InputPlaceholder_Display_Key" 
              description-key="InputPlaceholder_Desc_Key" of-type="SingleLine.Text" 
              usage="input" default-value="Enter text to analyze..." />
    
    <!-- Custom Output Text Box Styling -->
    <property name="outputBackgroundColor" display-name-key="OutputBgColor_Display_Key" 
              description-key="OutputBgColor_Desc_Key" of-type="SingleLine.Text" 
              usage="input" default-value="#f3f2f1" />
    
    <property name="outputTextColor" display-name-key="OutputTextColor_Display_Key" 
              description-key="OutputTextColor_Desc_Key" of-type="SingleLine.Text" 
              usage="input" default-value="#323130" />
    
    <property name="outputBorderColor" display-name-key="OutputBorderColor_Display_Key" 
              description-key="OutputBorderColor_Desc_Key" of-type="SingleLine.Text" 
              usage="input" default-value="#0078d4" />
    
    <property name="outputFontSize" display-name-key="OutputFontSize_Display_Key" 
              description-key="OutputFontSize_Desc_Key" of-type="Whole.None" 
              usage="input" default-value="14" />
    
    <!-- Button Styling -->
    <property name="buttonBackgroundColor" display-name-key="ButtonBgColor_Display_Key" 
              description-key="ButtonBgColor_Desc_Key" of-type="SingleLine.Text" 
              usage="input" default-value="#0078d4" />
    
    <property name="buttonTextColor" display-name-key="ButtonTextColor_Display_Key" 
              description-key="ButtonTextColor_Desc_Key" of-type="SingleLine.Text" 
              usage="input" default-value="#ffffff" />
    
    <property name="textBoxHeight" display-name-key="Height_Display_Key" 
              description-key="Height_Desc_Key" of-type="Whole.None" 
              usage="input" default-value="200" />
    
    <property name="buttonText" display-name-key="ButtonText_Display_Key" 
              description-key="ButtonText_Desc_Key" of-type="SingleLine.Text" 
              usage="input" default-value="Analyze with AI Rating" />
    
    <!-- Output property for AI result -->
    <property name="aiResult" display-name-key="AIResult_Display_Key" 
              description-key="AIResult_Desc_Key" of-type="Multiple" 
              usage="output" />
    
    <!-- Resources -->
    <resources>
      <code path="index.ts" order="1"/>
      <css path="css/AIRatingControl.css" order="1" />
      <resx path="strings/AIRatingControl.1033.resx" version="1.0.0" />
    </resources>
    
    <!-- Feature usage -->
    <feature-usage>
      <uses-feature name="WebAPI" required="true" />
    </feature-usage>
  </control>
</manifest>
```

### Step 4: Implement Control Logic

Edit `index.ts`:

```typescript
import { IInputs, IOutputs } from "./generated/ManifestTypes";

export class AIRatingControl implements ComponentFramework.StandardControl<IInputs, IOutputs> {
    
    private _container: HTMLDivElement;
    private _context: ComponentFramework.Context<IInputs>;
    private _notifyOutputChanged: () => void;
    
    // UI Elements
    private _textInput: HTMLTextAreaElement;
    private _analyzeButton: HTMLButtonElement;
    private _resultDisplay: HTMLDivElement;
    private _loadingIndicator: HTMLDivElement;
    
    // State
    private _aiResult: string | null = null;
    private _isLoading: boolean = false;

    /**
     * Empty constructor
     */
    constructor() { }

    /**
     * Used to initialize the control instance. Controls can kick off remote server calls and other initialization actions here.
     * @param context The entire property bag available to control via Context Object
     * @param notifyOutputChanged A callback method to alert the framework that the control has new outputs ready to be retrieved asynchronously
     * @param state A piece of data that persists in one session for a single user
     * @param container If a control is marked control-type='standard', it will receive an empty div element within which it can render its content
     */
    public init(
        context: ComponentFramework.Context<IInputs>,
        notifyOutputChanged: () => void,
        state: ComponentFramework.Dictionary,
        container: HTMLDivElement
    ): void {
        this._context = context;
        this._notifyOutputChanged = notifyOutputChanged;
        this._container = container;

        // Create main container
        const mainContainer = document.createElement("div");
        mainContainer.className = "ai-rating-container";

        // Create instruction label
        const instructionLabel = document.createElement("label");
        instructionLabel.className = "ai-rating-label";
        instructionLabel.textContent = "Enter text to analyze:";
        mainContainer.appendChild(instructionLabel);

        // Create custom text input with configurable styling
        this._textInput = document.createElement("textarea");
        this._textInput.className = "ai-rating-input";
        this._textInput.rows = 6;
        
        // Apply custom input text box styling
        const placeholder = context.parameters.inputPlaceholder.raw || "Type or paste text here...";
        this._textInput.placeholder = placeholder;
        
        const height = context.parameters.textBoxHeight.raw;
        if (height) {
            this._textInput.style.height = `${height}px`;
        }
        
        const inputBgColor = context.parameters.inputBackgroundColor.raw;
        if (inputBgColor) {
            this._textInput.style.backgroundColor = inputBgColor;
        }
        
        const inputTextColor = context.parameters.inputTextColor.raw;
        if (inputTextColor) {
            this._textInput.style.color = inputTextColor;
        }
        
        const inputBorderColor = context.parameters.inputBorderColor.raw;
        if (inputBorderColor) {
            this._textInput.style.borderColor = inputBorderColor;
        }
        
        const inputFontSize = context.parameters.inputFontSize.raw;
        if (inputFontSize) {
            this._textInput.style.fontSize = `${inputFontSize}px`;
        }
        
        mainContainer.appendChild(this._textInput);

        // Create analyze button with custom styling
        this._analyzeButton = document.createElement("button");
        this._analyzeButton.className = "ai-rating-button";
        this._analyzeButton.textContent = context.parameters.buttonText.raw || "Analyze with AI Rating";
        this._analyzeButton.onclick = this.onAnalyzeClick.bind(this);
        
        // Apply custom button styling
        const buttonBgColor = context.parameters.buttonBackgroundColor.raw;
        if (buttonBgColor) {
            this._analyzeButton.style.backgroundColor = buttonBgColor;
        }
        
        const buttonTextColor = context.parameters.buttonTextColor.raw;
        if (buttonTextColor) {
            this._analyzeButton.style.color = buttonTextColor;
        }
        
        mainContainer.appendChild(this._analyzeButton);

        // Create loading indicator
        this._loadingIndicator = document.createElement("div");
        this._loadingIndicator.className = "ai-rating-loading";
        this._loadingIndicator.textContent = "Analyzing...";
        this._loadingIndicator.style.display = "none";
        mainContainer.appendChild(this._loadingIndicator);

        // Create custom result display with styling
        const resultLabel = document.createElement("label");
        resultLabel.className = "ai-rating-label";
        resultLabel.textContent = "AI Rating Results:";
        resultLabel.style.marginTop = "20px";
        mainContainer.appendChild(resultLabel);

        this._resultDisplay = document.createElement("div");
        this._resultDisplay.className = "ai-rating-result";
        this._resultDisplay.textContent = "Results will appear here...";
        
        // Apply custom output text box styling
        const outputBgColor = context.parameters.outputBackgroundColor.raw;
        if (outputBgColor) {
            this._resultDisplay.style.backgroundColor = outputBgColor;
        }
        
        const outputTextColor = context.parameters.outputTextColor.raw;
        if (outputTextColor) {
            this._resultDisplay.style.color = outputTextColor;
        }
        
        const outputBorderColor = context.parameters.outputBorderColor.raw;
        if (outputBorderColor) {
            this._resultDisplay.style.borderLeftColor = outputBorderColor;
        }
        
        const outputFontSize = context.parameters.outputFontSize.raw;
        if (outputFontSize) {
            this._resultDisplay.style.fontSize = `${outputFontSize}px`;
        }
        
        mainContainer.appendChild(this._resultDisplay);

        // Add to container
        this._container.appendChild(mainContainer);
    }

    /**
     * Handle analyze button click
     */
    private async onAnalyzeClick(): Promise<void> {
        const inputText = this._textInput.value.trim();
        
        if (!inputText) {
            this._resultDisplay.textContent = "Please enter some text to analyze.";
            this._resultDisplay.className = "ai-rating-result error";
            return;
        }

        // Show loading state
        this._isLoading = true;
        this._loadingIndicator.style.display = "block";
        this._analyzeButton.disabled = true;
        this._resultDisplay.textContent = "";

        try {
            // Call the built-in AI Rating model
            const result = await this.callAIBuilderAPI(inputText);
            
            this._aiResult = result;
            this._resultDisplay.textContent = result;
            this._resultDisplay.className = "ai-rating-result success";
            
            // Notify framework of output change
            this._notifyOutputChanged();
            
        } catch (error) {
            this._resultDisplay.textContent = `Error: ${error}`;
            this._resultDisplay.className = "ai-rating-result error";
        } finally {
            // Hide loading state
            this._isLoading = false;
            this._loadingIndicator.style.display = "none";
            this._analyzeButton.disabled = false;
        }
    }

    /**
     * Call AI Rating model via AI Builder
     */
    private async callAIBuilderAPI(inputText: string): Promise<string> {
        // Use the built-in AI Rating model from AI Builder
        // This model analyzes text sentiment and provides ratings
        
        try {
            // Call AI Rating model using the standard AI Builder connector pattern
            // In PCF, we use the WebAPI to execute the prediction
            
            const entityName = "msdyn_aimodel";
            const modelQuery = `?$filter=msdyn_uniquename eq 'AIRating'`;
            
            // Get the AI Rating model
            const modelsResponse = await this._context.webAPI.retrieveMultipleRecords(
                entityName,
                modelQuery
            );
            
            if (!modelsResponse.entities || modelsResponse.entities.length === 0) {
                throw new Error("AI Rating model not found. Ensure AI Builder is enabled.");
            }
            
            const modelId = modelsResponse.entities[0].msdyn_aimodelid;
            
            // Prepare the prediction request
            const predictionRequest = {
                "msdyn_textfield": inputText
            };
            
            // Execute the prediction using the AI Builder action
            const result = await this._context.webAPI.execute({
                getMetadata: () => ({
                    boundParameter: null,
                    parameterTypes: {},
                    operationType: 1, // Action
                    operationName: "msdyn_PredictByAIModel"
                }),
                msdyn_aimodelid: modelId,
                msdyn_inputdata: JSON.stringify(predictionRequest)
            });
            
            // Parse and format the response
            const prediction = JSON.parse(result.msdyn_outputdata);
            
            // Format the output nicely
            const rating = prediction.msdyn_rating || "N/A";
            const sentiment = prediction.msdyn_sentimen || prediction.Sentiment || "N/A";
            const confidence = prediction.msdyn_confidence || prediction.ConfidenceScore || "N/A";
            
            return `Rating: ${rating}\nSentiment: ${sentiment}\nConfidence: ${confidence}`;
            
        } catch (error) {
            console.error("AI Rating model error:", error);
            throw new Error(`Failed to analyze text: ${error}`);
        }
    }

    /**
     * Called when any value in the property bag has changed
     */
    public updateView(context: ComponentFramework.Context<IInputs>): void {
        this._context = context;
        
        // Update button text if changed
        if (context.parameters.buttonText.raw) {
            this._analyzeButton.textContent = context.parameters.buttonText.raw;
        }
        
        // Update input text box styling if changed
        if (context.parameters.inputBackgroundColor.raw) {
            this._textInput.style.backgroundColor = context.parameters.inputBackgroundColor.raw;
        }
        
        if (context.parameters.inputTextColor.raw) {
            this._textInput.style.color = context.parameters.inputTextColor.raw;
        }
        
        if (context.parameters.inputBorderColor.raw) {
            this._textInput.style.borderColor = context.parameters.inputBorderColor.raw;
        }
        
        if (context.parameters.inputFontSize.raw) {
            this._textInput.style.fontSize = `${context.parameters.inputFontSize.raw}px`;
        }
        
        if (context.parameters.inputPlaceholder.raw) {
            this._textInput.placeholder = context.parameters.inputPlaceholder.raw;
        }
        
        // Update button styling if changed
        if (context.parameters.buttonBackgroundColor.raw) {
            this._analyzeButton.style.backgroundColor = context.parameters.buttonBackgroundColor.raw;
        }
        
        if (context.parameters.buttonTextColor.raw) {
            this._analyzeButton.style.color = context.parameters.buttonTextColor.raw;
        }
        
        // Update output text box styling if changed
        if (context.parameters.outputBackgroundColor.raw) {
            this._resultDisplay.style.backgroundColor = context.parameters.outputBackgroundColor.raw;
        }
        
        if (context.parameters.outputTextColor.raw) {
            this._resultDisplay.style.color = context.parameters.outputTextColor.raw;
        }
        
        if (context.parameters.outputBorderColor.raw) {
            this._resultDisplay.style.borderLeftColor = context.parameters.outputBorderColor.raw;
        }
        
        if (context.parameters.outputFontSize.raw) {
            this._resultDisplay.style.fontSize = `${context.parameters.outputFontSize.raw}px`;
        }
        
        // Update height if changed
        if (context.parameters.textBoxHeight.raw) {
            this._textInput.style.height = `${context.parameters.textBoxHeight.raw}px`;
        }
    }

    /**
     * Return outputs for the framework
     */
    public getOutputs(): IOutputs {
        return {
            aiResult: this._aiResult
        };
    }

    /**
     * Destroy method - cleanup
     */
    public destroy(): void {
        // Cleanup
    }
}
```

### Step 5: Add Custom Styles

Edit `css/AIRatingControl.css`:

```css
.ai-rating-container {
    font-family: "Segoe UI", "Segoe UI Web (West European)", -apple-system, BlinkMacSystemFont, Roboto, "Helvetica Neue", sans-serif;
    padding: 20px;
    max-width: 800px;
}

.ai-rating-label {
    display: block;
    font-weight: 600;
    font-size: 14px;
    color: #323130;
    margin-bottom: 8px;
}

.ai-rating-input {
    width: 100%;
    padding: 12px;
    border: 1px solid #8a8886;
    border-radius: 2px;
    font-size: 14px;
    font-family: "Segoe UI", "Segoe UI Web (West European)", -apple-system, BlinkMacSystemFont, Roboto, "Helvetica Neue", sans-serif;
    resize: vertical;
    box-sizing: border-box;
    transition: border-color 0.2s;
}

.ai-rating-input:focus {
    outline: none;
    border-color: #0078d4;
    box-shadow: 0 0 0 1px #0078d4;
}

.ai-rating-input::placeholder {
    color: #a19f9d;
}

.ai-rating-button {
    margin-top: 12px;
    padding: 10px 24px;
    background-color: #0078d4;
    color: white;
    border: none;
    border-radius: 2px;
    font-size: 14px;
    font-weight: 600;
    cursor: pointer;
    transition: background-color 0.2s;
}

.ai-rating-button:hover:not(:disabled) {
    background-color: #106ebe;
}

.ai-rating-button:active:not(:disabled) {
    background-color: #005a9e;
}

.ai-rating-button:disabled {
    background-color: #f3f2f1;
    color: #a19f9d;
    cursor: not-allowed;
}

.ai-rating-loading {
    margin-top: 12px;
    padding: 12px;
    background-color: #fff4ce;
    border-left: 4px solid #ffb900;
    font-size: 14px;
    color: #323130;
    display: flex;
    align-items: center;
}

.ai-rating-loading::before {
    content: "⏳";
    margin-right: 8px;
    animation: pulse 1.5s infinite;
}

@keyframes pulse {
    0%, 100% { opacity: 1; }
    50% { opacity: 0.5; }
}

.ai-rating-result {
    margin-top: 12px;
    padding: 16px;
    border-radius: 2px;
    font-size: 14px;
    line-height: 1.6;
    min-height: 100px;
    background-color: #f3f2f1;
    border-left: 4px solid #0078d4;
    white-space: pre-wrap;
    word-wrap: break-word;
}

.ai-rating-result.success {
    background-color: #dff6dd;
    border-left-color: #107c10;
    color: #323130;
}

.ai-rating-result.error {
    background-color: #fde7e9;
    border-left-color: #d13438;
    color: #a80000;
}

.ai-rating-result:empty::after {
    content: "Results will appear here...";
    color: #a19f9d;
    font-style: italic;
}
```

### Step 6: Build and Test

```bash
# Build the control
npm run build

# Start test harness
npm start watch
```

This will open a browser with the test harness where you can test your control.

### Step 7: Deploy to Dataverse

```bash
# Create solution folder
mkdir AIRatingSolution
cd AIRatingSolution

# Create solution
pac solution init --publisher-name Contoso --publisher-prefix contoso

# Add control reference
pac solution add-reference --path ..\AIRatingControl

# Build solution
msbuild /t:build /restore

# Deploy to environment
pac auth create --environment https://yourorg.crm.dynamics.com
pac solution import --path bin\Debug\AIRatingSolution.zip
```

## Configurable Properties

When added to an app, users can configure these custom text box and styling properties:

### Input Text Box Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `inputText` | Text | (required) | Bound field for the input text |
| `inputBackgroundColor` | Text | `#ffffff` | Background color of input text box |
| `inputTextColor` | Text | `#323130` | Text color inside input box |
| `inputBorderColor` | Text | `#8a8886` | Border color of input box |
| `inputFontSize` | Number | `14` | Font size in pixels for input text |
| `inputPlaceholder` | Text | `"Enter text to analyze..."` | Placeholder text shown when empty |
| `textBoxHeight` | Number | `200` | Height of both text boxes in pixels |

### Output Text Box Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `outputBackgroundColor` | Text | `#f3f2f1` | Background color of results text box |
| `outputTextColor` | Text | `#323130` | Text color for AI results |
| `outputBorderColor` | Text | `#0078d4` | Border accent color for results box |
| `outputFontSize` | Number | `14` | Font size for results display |

### Button Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `buttonText` | Text | `"Analyze with AI Rating"` | Custom button text |
| `buttonBackgroundColor` | Text | `#0078d4` | Button background color |
| `buttonTextColor` | Text | `#ffffff` | Button text color |

### Output Property

| Property | Type | Description |
|----------|------|-------------|
| `aiResult` | Text | Output property containing AI Rating analysis result |

## Advanced Features to Add

### 1. **Real-time Character Count**
```typescript
// Add to init()
const charCount = document.createElement("div");
charCount.className = "char-count";
this._textInput.addEventListener("input", () => {
    charCount.textContent = `${this._textInput.value.length} characters`;
});
```

### 2. **Multiple AI Models Dropdown**
```typescript
// Add model selector
<property name="availableModels" display-name-key="Models_Display_Key" 
          of-type="Multiple" usage="input" />
```

### 3. **Export Results Button**
```typescript
private exportResults(): void {
    const blob = new Blob([this._aiResult || ""], { type: "text/plain" });
    const url = URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = url;
    a.download = "ai-analysis.txt";
    a.click();
}
```

### 4. **History Tracking**
Store previous analyses in local storage or Dataverse for review.

## Troubleshooting

### Control not showing in Power Apps
- Ensure solution is imported successfully
- Check control is added to allowed controls in environment settings
- Verify AI Builder is enabled

### AI API errors
- Confirm AI Builder prompt is published
- Check API permissions in app registration
- Verify model name matches exactly

### Styling not applying
- Clear browser cache
- Rebuild solution: `npm run build`
- Reimport to environment

## Resources

- [PCF Control Documentation](https://learn.microsoft.com/power-apps/developer/component-framework/overview)
- [AI Builder API Reference](https://learn.microsoft.com/ai-builder/api-overview)
- [PCF Gallery Samples](https://pcf.gallery/)
- [Power Apps CLI Reference](https://learn.microsoft.com/power-platform/developer/cli/introduction)

## License

MIT License - feel free to customize and extend!
