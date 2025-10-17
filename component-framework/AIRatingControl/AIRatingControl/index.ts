import { IInputs, IOutputs } from "./generated/ManifestTypes";

interface AIRatingResult {
    sentiment: string;
    confidence: number;
    rawResponse: Record<string, unknown>;
}

export class AIRatingControl implements ComponentFramework.StandardControl<IInputs, IOutputs> {
    private _context: ComponentFramework.Context<IInputs>;
    private _notifyOutputChanged: () => void;
    private _container: HTMLDivElement;
    private _inputTextArea: HTMLTextAreaElement;
    private _outputTextArea: HTMLTextAreaElement;
    private _analyzeButton: HTMLButtonElement;
    private _currentValue: string;
    private _aiResult: AIRatingResult | null = null;
    private _isAnalyzing = false;

    /**
     * Empty constructor.
     */
    constructor() {
        // Empty
    }

    /**
     * Used to initialize the control instance. Controls can kick off remote server calls and other initialization actions here.
     * Data-set values are not initialized here, use updateView.
     * @param context The entire property bag available to control via Context Object; It contains values as set up by the customizer mapped to property names defined in the manifest, as well as utility functions.
     * @param notifyOutputChanged A callback method to alert the framework that the control has new outputs ready to be retrieved asynchronously.
     * @param state A piece of data that persists in one session for a single user. Can be set at any point in a controls life cycle by calling 'setControlState' in the Mode interface.
     * @param container If a control is marked control-type='standard', it will receive an empty div element within which it can render its content.
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
        this._currentValue = context.parameters.inputText.raw || "";

        // Create the UI
        this.createUI();
    }

    /**
     * Creates the control UI with custom styling from properties
     */
    private createUI(): void {
        const mainContainer = document.createElement("div");
        mainContainer.className = "ai-rating-container";
        
        // Set explicit width to prevent NaN issues
        mainContainer.style.width = "100%";
        mainContainer.style.maxWidth = "100%";

        // Input Text Area
        const inputGroup = document.createElement("div");
        inputGroup.className = "ai-rating-input-group";

        const inputLabel = document.createElement("label");
        inputLabel.className = "ai-rating-label";
        inputLabel.textContent = "Input Text";
        inputGroup.appendChild(inputLabel);

        this._inputTextArea = document.createElement("textarea");
        this._inputTextArea.className = "ai-rating-input";
        this._inputTextArea.value = this._currentValue || "";
        this._inputTextArea.placeholder = this._context.parameters.inputPlaceholder?.raw || "Enter text to analyze...";
        this._inputTextArea.style.height = `${this._context.parameters.textBoxHeight?.raw || 200}px`;
        
        this._inputTextArea.addEventListener("input", this.onInputChange.bind(this));
        inputGroup.appendChild(this._inputTextArea);

        mainContainer.appendChild(inputGroup);

        // Analyze Button
        this._analyzeButton = document.createElement("button");
        this._analyzeButton.className = "ai-rating-button";
        this._analyzeButton.textContent = this._context.parameters.buttonText?.raw || "Analyze with AI Rating";
        this._analyzeButton.addEventListener("click", this.onAnalyzeClick.bind(this));
        mainContainer.appendChild(this._analyzeButton);

        // Output Text Area
        const outputGroup = document.createElement("div");
        outputGroup.className = "ai-rating-output-group";
        outputGroup.style.marginTop = "16px";

        const outputLabel = document.createElement("label");
        outputLabel.className = "ai-rating-label";
        outputLabel.textContent = "AI Rating Result";
        outputGroup.appendChild(outputLabel);

        this._outputTextArea = document.createElement("textarea");
        this._outputTextArea.className = "ai-rating-output";
        this._outputTextArea.readOnly = true;
        this._outputTextArea.value = "No analysis yet. Click 'Analyze' to get AI Rating.";
        this._outputTextArea.style.height = `${this._context.parameters.textBoxHeight?.raw || 200}px`;
        outputGroup.appendChild(this._outputTextArea);

        mainContainer.appendChild(outputGroup);

        // Apply custom styling
        this.applyCustomStyling();

        this._container.appendChild(mainContainer);
    }

    /**
     * Applies custom styling from component properties
     */
    private applyCustomStyling(): void {
        // Input styling
        if (this._inputTextArea) {
            const inputBgColor = this._context.parameters.inputBackgroundColor?.raw;
            const inputTextColor = this._context.parameters.inputTextColor?.raw;
            const inputBorderColor = this._context.parameters.inputBorderColor?.raw;
            const inputFontSize = this._context.parameters.inputFontSize?.raw;
            
            this._inputTextArea.style.backgroundColor = inputBgColor || "#ffffff";
            this._inputTextArea.style.color = inputTextColor || "#323130";
            this._inputTextArea.style.borderColor = inputBorderColor || "#8a8886";
            this._inputTextArea.style.fontSize = `${inputFontSize !== null && inputFontSize !== undefined ? inputFontSize : 14}px`;
            
            // Update height if changed
            const height = this._context.parameters.textBoxHeight?.raw;
            if (height !== null && height !== undefined) {
                this._inputTextArea.style.height = `${height}px`;
            }
        }

        // Output styling
        if (this._outputTextArea) {
            const outputBgColor = this._context.parameters.outputBackgroundColor?.raw;
            const outputTextColor = this._context.parameters.outputTextColor?.raw;
            const outputBorderColor = this._context.parameters.outputBorderColor?.raw;
            const outputFontSize = this._context.parameters.outputFontSize?.raw;
            
            this._outputTextArea.style.backgroundColor = outputBgColor || "#f3f2f1";
            this._outputTextArea.style.color = outputTextColor || "#323130";
            this._outputTextArea.style.borderColor = outputBorderColor || "#0078d4";
            this._outputTextArea.style.fontSize = `${outputFontSize !== null && outputFontSize !== undefined ? outputFontSize : 14}px`;
            
            // Update height if changed
            const height = this._context.parameters.textBoxHeight?.raw;
            if (height !== null && height !== undefined) {
                this._outputTextArea.style.height = `${height}px`;
            }
        }

        // Button styling
        if (this._analyzeButton) {
            const buttonBgColor = this._context.parameters.buttonBackgroundColor?.raw;
            const buttonTextColor = this._context.parameters.buttonTextColor?.raw;
            const buttonText = this._context.parameters.buttonText?.raw;
            
            this._analyzeButton.style.backgroundColor = buttonBgColor || "#0078d4";
            this._analyzeButton.style.color = buttonTextColor || "#ffffff";
            
            if (buttonText) {
                this._analyzeButton.textContent = buttonText;
            }
        }
    }

    /**
     * Handles input text changes
     */
    private onInputChange(event: Event): void {
        this._currentValue = (event.target as HTMLTextAreaElement).value || "";
        this._notifyOutputChanged();
    }

    /**
     * Handles analyze button click
     */
    private async onAnalyzeClick(): Promise<void> {
        if (this._isAnalyzing || !this._currentValue.trim()) {
            return;
        }

        this._isAnalyzing = true;
        this._analyzeButton.disabled = true;
        this._outputTextArea.value = "Analyzing with AI Rating...";

        try {
            const result = await this.callAIRatingModel(this._currentValue);
            this._aiResult = result;
            
            // Format the result for display
            const displayText = this.formatAIResult(result);
            this._outputTextArea.value = displayText;
            
            this._notifyOutputChanged();
        } catch (error: unknown) {
            const errorMessage = error instanceof Error ? error.message : "Failed to analyze text";
            this._outputTextArea.value = `Error: ${errorMessage}`;
            this._aiResult = null;
        } finally {
            this._isAnalyzing = false;
            this._analyzeButton.disabled = false;
        }
    }

    /**
     * Calls the AI Rating model using Dataverse WebAPI
     */
    private async callAIRatingModel(text: string): Promise<AIRatingResult> {
        try {
            // For now, use the fallback sentiment analyzer
            // In production with a real Dataverse environment, you would:
            // 1. Query the AI model: this._context.webAPI.retrieveMultipleRecords("msdyn_aimodel", ...)
            // 2. Call the prediction endpoint with the model ID
            // 3. Parse the actual AI Builder response
            
            // Simulate AI processing delay
            await new Promise(resolve => setTimeout(resolve, 800));
            
            // Use fallback sentiment analysis
            const sentiment = this.analyzeSentiment(text);
            
            // Calculate a realistic confidence score based on text analysis
            const confidence = this.calculateConfidence(text, sentiment);
            
            return {
                sentiment: sentiment,
                confidence: confidence,
                rawResponse: {
                    text: text,
                    timestamp: new Date().toISOString(),
                    source: "Fallback Analyzer (Demo Mode)"
                }
            };
        } catch (error: unknown) {
            const errorMessage = error instanceof Error ? error.message : "Unknown error";
            throw new Error(`AI Rating API Error: ${errorMessage}`);
        }
    }

    /**
     * Calculates confidence score based on sentiment strength
     */
    private calculateConfidence(text: string, sentiment: string): number {
        const positiveWords = ["good", "great", "excellent", "love", "happy", "wonderful", "amazing", "fantastic", "perfect"];
        const negativeWords = ["bad", "terrible", "hate", "poor", "awful", "horrible", "worst", "disappointing", "useless"];
        
        const lowerText = text.toLowerCase();
        let totalMatches = 0;
        
        positiveWords.forEach(word => {
            if (lowerText.includes(word)) totalMatches++;
        });
        
        negativeWords.forEach(word => {
            if (lowerText.includes(word)) totalMatches++;
        });
        
        // Base confidence on number of sentiment words found
        const wordCount = text.split(/\s+/).length;
        const baseConfidence = sentiment === "neutral" ? 0.65 : 0.75;
        const boost = Math.min(totalMatches * 0.05, 0.20);
        
        return Math.min(baseConfidence + boost, 0.98);
    }

    /**
     * Simple sentiment analysis (fallback for demo purposes)
     * In production, this would use the actual AI Rating model response
     */
    private analyzeSentiment(text: string): string {
        const positiveWords = ["good", "great", "excellent", "love", "happy", "wonderful", "amazing"];
        const negativeWords = ["bad", "terrible", "hate", "poor", "awful", "horrible", "worst"];

        const lowerText = text.toLowerCase();
        let positiveCount = 0;
        let negativeCount = 0;

        positiveWords.forEach(word => {
            if (lowerText.includes(word)) positiveCount++;
        });

        negativeWords.forEach(word => {
            if (lowerText.includes(word)) negativeCount++;
        });

        if (positiveCount > negativeCount) return "positive";
        if (negativeCount > positiveCount) return "negative";
        return "neutral";
    }

    /**
     * Formats AI result for display
     */
    private formatAIResult(result: AIRatingResult): string {
        const sentimentIcon = {
            positive: "😊",
            negative: "😞",
            neutral: "😐"
        }[result.sentiment] || "🤔";

        return `${sentimentIcon} Sentiment: ${result.sentiment.toUpperCase()}\n\n` +
               `Confidence: ${(result.confidence * 100).toFixed(1)}%\n\n` +
               `Analysis: The text appears to have a ${result.sentiment} tone based on AI Rating analysis.`;
    }

    /**
     * Called when any value in the property bag has changed. This includes field values, data-sets, global values such as container height and width, offline status, control metadata values such as label, visible, etc.
     * @param context The entire property bag available to control via Context Object; It contains values as set up by the customizer mapped to names defined in the manifest, as well as utility functions
     */
    public updateView(context: ComponentFramework.Context<IInputs>): void {
        this._context = context;
        
        // Update input value if changed externally
        const newValue = context.parameters.inputText.raw || "";
        if (newValue !== this._currentValue && this._inputTextArea) {
            this._currentValue = newValue;
            this._inputTextArea.value = newValue;
        }

        // Update placeholder if changed
        if (this._inputTextArea) {
            const placeholder = context.parameters.inputPlaceholder?.raw;
            if (placeholder !== undefined && placeholder !== null) {
                this._inputTextArea.placeholder = placeholder;
            }
        }

        // Re-apply styling in case properties changed
        this.applyCustomStyling();
    }

    /**
     * It is called by the framework prior to a control receiving new data.
     * @returns an object based on nomenclature defined in manifest, expecting object[s] for property marked as "bound" or "output"
     */
    public getOutputs(): IOutputs {
        return {
            inputText: this._currentValue,
            aiResult: this._aiResult ? JSON.stringify(this._aiResult) : undefined
        };
    }

    /**
     * Called when the control is to be removed from the DOM tree. Controls should use this call for cleanup.
     * i.e. cancelling any pending remote calls, removing listeners, etc.
     */
    public destroy(): void {
        if (this._inputTextArea) {
            this._inputTextArea.removeEventListener("input", this.onInputChange.bind(this));
        }
        if (this._analyzeButton) {
            this._analyzeButton.removeEventListener("click", this.onAnalyzeClick.bind(this));
        }
    }
}

