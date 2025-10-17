# AI Rating Control - Quick Start Guide for Power Apps

## 🚀 Get It Into Power Apps (5 Minutes)

Your control is **already built and ready**! Here's how to get it into Power Apps:

---

## Option 1: Automated Deployment (Easiest) ⚡

### Step 1: Run the Deployment Script

```powershell
.\Deploy-AIRatingControl.ps1
```

**What it does:**
- ✅ Builds the control (already done!)
- ✅ Creates a Power Platform solution
- ✅ Packages everything into a `.zip` file
- ✅ Shows you exactly where the package is

**Time: ~2 minutes**

---

### Step 2: Import to Power Apps

1. **Go to Power Apps**: https://make.powerapps.com
2. **Select your environment** (top-right corner)
3. **Click "Solutions"** (left navigation)
4. **Click "Import solution"** (top toolbar)
5. **Browse** and select: `AIRatingSolution\bin\Debug\AIRatingSolution.zip`
6. **Click "Next"** → **"Import"**
7. **Wait ~30 seconds** for import to complete
8. **Done!** ✅

**Time: ~2 minutes**

---

## Option 2: PAC CLI (For DevOps/Automation) 🔧

### Step 1: Authenticate to Your Environment

```powershell
# List available environments
pac org list

# Authenticate (replace with your environment URL)
pac auth create --environment https://yourenv.crm.dynamics.com
```

### Step 2: Run Deployment Script

```powershell
.\Deploy-AIRatingControl.ps1
```

### Step 3: Import via CLI

```powershell
cd AIRatingSolution
pac solution import --path "bin\Debug\AIRatingSolution.zip"
```

**Time: ~3 minutes**

---

## 📱 Using in Canvas Apps

Once imported, here's how to add it to a Canvas App:

### Step 1: Open Canvas App
1. Go to https://make.powerapps.com
2. **Apps** → **New app** → **Canvas**
3. Or open an existing Canvas App

### Step 2: Import the Control
1. **Insert** (left toolbar) → **Get more components**
2. **Code** tab
3. Find **"AI Rating Control"**
4. Click **Import** ✅

### Step 3: Add to Screen
1. **Insert** → **Code components** (now visible)
2. Click **"AIRatingControl"**
3. Drag onto your canvas

### Step 4: Configure Properties

**In the Properties pane (right side):**

**Basic Setup:**
- `inputText`: Bind to a variable or text input
  - Example: `TextInput1.Text` or `varInputText`

**Customize Colors:**
- `inputBackgroundColor`: "#ffffff" (white)
- `inputTextColor`: "#000000" (black)  
- `inputBorderColor`: "#0078d4" (blue)
- `outputBackgroundColor`: "#f3f2f1" (light gray)
- `outputBorderColor`: "#107c10" (green)
- `buttonBackgroundColor`: "#0078d4" (blue)
- `buttonTextColor`: "#ffffff" (white)

**Customize Text:**
- `inputPlaceholder`: "Type your review here..."
- `buttonText`: "Analyze Sentiment"

**Sizing:**
- `textBoxHeight`: 300 (pixels)
- `inputFontSize`: 16
- `outputFontSize`: 16

### Step 5: Get the Results

The control outputs JSON in the `aiResult` property:

```javascript
// In an OnSelect or other event
Set(varSentiment, 
    JSON(AIRatingControl1.aiResult, JSONFormat.IncludeBinaryData)
);

// Display the sentiment
Label1.Text = varSentiment.sentiment

// Display confidence
Label2.Text = Text(varSentiment.confidence * 100, "0.0") & "%"
```

**Example Formula:**
```javascript
// In a Label to show sentiment with emoji
Switch(
    JSON(AIRatingControl1.aiResult).sentiment,
    "positive", "😊 Positive",
    "negative", "😞 Negative",
    "😐 Neutral"
)
```

---

## 🖥️ Using in Model-Driven Apps

### Step 1: Add to a Form
1. Open your **Model-Driven App**
2. Go to **Tables** → Select a table (e.g., "Feedback", "Review")
3. Open a **Form**
4. Click on a **text field** where you want the control

### Step 2: Add Component
1. Click **Components** (top toolbar)
2. **+ Component** → **AI Rating Control**
3. The control replaces the standard text field

### Step 3: Configure in Properties Pane
- All 15 properties are configurable
- Set colors, fonts, button text, etc.
- Click **Save** → **Publish**

### Step 4: Test
1. Open a record in the app
2. See the AI Rating Control on the form
3. Type text and click "Analyze"
4. Results saved to the field automatically

---

## 🎨 Styling Examples

### Professional Blue Theme
```
inputBackgroundColor: #ffffff
inputBorderColor: #0078d4
outputBackgroundColor: #f3f2f1
outputBorderColor: #0078d4
buttonBackgroundColor: #0078d4
buttonTextColor: #ffffff
```

### Dark Theme
```
inputBackgroundColor: #1e1e1e
inputTextColor: #ffffff
inputBorderColor: #3e3e3e
outputBackgroundColor: #2d2d2d
outputTextColor: #ffffff
outputBorderColor: #0078d4
buttonBackgroundColor: #0078d4
```

### Success/Warning Theme
```
inputBorderColor: #107c10 (green)
outputBorderColor: #107c10 (green)
buttonBackgroundColor: #107c10 (green)
```

---

## 📊 Real-World Usage Example

**Customer Feedback App:**

```javascript
// Screen with AI Rating Control

// Input from user
AIRatingControl1.inputText = TextInput_CustomerFeedback.Text

// Button to save result
OnSelect = 
    Patch(
        CustomerFeedback,
        Defaults(CustomerFeedback),
        {
            FeedbackText: AIRatingControl1.inputText,
            Sentiment: JSON(AIRatingControl1.aiResult).sentiment,
            Confidence: JSON(AIRatingControl1.aiResult).confidence,
            AnalyzedDate: Now()
        }
    );
    Notify("Feedback saved!", NotificationType.Success)

// Display results in gallery
Gallery1.Items = CustomerFeedback
Gallery1.Template.Text = ThisItem.Sentiment
```

---

## 🔄 Production AI Builder Integration

To use the **real AI Builder AI Rating model** instead of the fallback:

### Step 1: Enable AI Builder
1. Power Platform Admin Center
2. Your environment → **Settings**
3. **Features** → Enable **AI Builder**

### Step 2: Update the Code

In `index.ts`, replace the `callAIRatingModel` method with:

```typescript
private async callAIRatingModel(text: string): Promise<AIRatingResult> {
    try {
        // Call AI Builder Sentiment Analysis
        const response = await this._context.webAPI.retrieveMultipleRecords(
            "msdyn_aimodel", 
            "?$filter=msdyn_templateid eq '10707e4e-1d54-e911-8194-000d3a6cd5a5'&$select=msdyn_aimodelid"
        );
        
        if (!response.entities || response.entities.length === 0) {
            throw new Error("AI Rating model not found");
        }
        
        const modelId = response.entities[0].msdyn_aimodelid;
        
        // Call prediction endpoint (requires AI Builder license)
        const prediction = await this._context.webAPI.execute({
            uri: `/api/data/v9.2/msdyn_PredictByModelId`,
            method: "POST",
            data: {
                modelId: modelId,
                input: { text: text }
            }
        });
        
        return {
            sentiment: prediction.sentiment,
            confidence: prediction.confidence,
            rawResponse: prediction
        };
    } catch (error) {
        // Fallback to demo analyzer
        return this.fallbackAnalyzer(text);
    }
}
```

---

## ✅ Checklist: Getting to Production

- [ ] Run `Deploy-AIRatingControl.ps1`
- [ ] Import solution to Power Apps environment
- [ ] Test in Canvas App first (easier)
- [ ] Configure styling properties
- [ ] Test with sample text
- [ ] Deploy to users

**Estimated Total Time: 10-15 minutes** ⏱️

---

## 🆘 Troubleshooting

### "Import failed: Component already exists"
- **Solution**: Increment version in `ControlManifest.Input.xml` (change `version="1.0.0"` to `version="1.0.1"`)

### "Control not showing in Insert menu"
- **Solution**: 
  1. Refresh your browser
  2. Check solution is published
  3. Ensure control is imported via "Get more components"

### "AI Rating not working in production"
- **Solution**: Control uses fallback analyzer by default. See "Production AI Builder Integration" above

### "Can't configure properties"
- **Solution**: Properties only appear in Power Apps maker, not in preview mode

---

## 🎓 Next Steps

1. **Import to Power Apps** (5 min)
2. **Test in Canvas App** (5 min)
3. **Customize colors/text** (2 min)
4. **Deploy to users** (1 min)

**You're ready to go!** 🚀

---

## 📞 Support

- **Power Apps Community**: https://powerusers.microsoft.com
- **PCF Documentation**: https://learn.microsoft.com/power-apps/developer/component-framework/
- **AI Builder**: https://learn.microsoft.com/ai-builder/

---

**Built with ❤️ using Power Apps Component Framework**
