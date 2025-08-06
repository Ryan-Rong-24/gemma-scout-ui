import Foundation
import UIKit

@MainActor
class LlamaState: ObservableObject {
    @Published var messages = ""
    @Published var selectedImages: [UIImage] = []
    @Published var chatMessages: [ChatMessage] = []
    @Published var isProcessing = false
    @Published var isMultimodalLoaded = false
    private var llamaContext: LlamaContext?
    private var temporaryImagePaths: [String] = []

    func loadModel() throws {
        if let modelPath = Bundle.main.path(forResource: "ggml-org_gemma-3-4b-it-GGUF_gemma-3-4b-it-Q4_K_M", ofType: "gguf") {
            // Load base model without multimodal support initially to save RAM
            llamaContext = try LlamaContext.create_context(path: modelPath, enable_multimodal: false)
            return
        }
    }
    
    func ensureMultimodalSupport() async -> Bool {
        guard let llamaContext = llamaContext else { return false }
        
        // Check if multimodal support is already enabled
        if await llamaContext.has_multimodal_support() {
            isMultimodalLoaded = true
            return true
        }
        
        // Load multimodal projection model dynamically
        guard let mmproj_path = Bundle.main.path(forResource: "ggml-org_gemma-3-4b-it-GGUF_mmproj-model-f16", ofType: "gguf") else {
            print("Multimodal projection model not found in bundle")
            return false
        }
        
        print("Loading multimodal support for image processing...")
        let success = await llamaContext.enable_multimodal_support(mmproj_path: mmproj_path)
        if success {
            print("Multimodal support successfully loaded")
            isMultimodalLoaded = true
        } else {
            print("Failed to load multimodal support")
            isMultimodalLoaded = false
        }
        return success
    }

    func complete(text: String) async {
        guard let llamaContext else {
            return
        }

        // Set processing state to true
        isProcessing = true

        // Convert selected images to Data for storage
        let imageDataArray = selectedImages.compactMap { $0.jpegData(compressionQuality: 0.8) }
        
        // Add user message with images to chat history
        let userMessage = ChatMessage(
            content: text,
            isUser: true,
            timestamp: Date(),
            imageData: imageDataArray.isEmpty ? nil : imageDataArray
        )
        chatMessages.append(userMessage)

        // Add "Be concise" to the actual prompt sent to the model, but don't show it in UI
        let enhancedPrompt = text + ". Be concise."
        
        // Prepare images if any are selected and clear them from UI immediately
        let hasImages = !selectedImages.isEmpty
        if hasImages {
            // Ensure multimodal support is loaded when we have images
            let multimodalReady = await ensureMultimodalSupport()
            if !multimodalReady {
                print("Warning: Could not load multimodal support, processing text only")
                await llamaContext.completion_init(text: enhancedPrompt)
            } else {
                await prepareImagesForCompletion()
                // Clear images from UI immediately after processing
                selectedImages.removeAll()
                await llamaContext.completion_init_with_images(text: enhancedPrompt)
            }
        } else {
            await llamaContext.completion_init(text: enhancedPrompt)
        }
        
        // Start building AI response
        var aiResponse = ""
        
        // Create a placeholder AI message that we'll update in real-time
        let placeholderAiMessage = ChatMessage(
            content: "",
            isUser: false,
            timestamp: Date()
        )
        chatMessages.append(placeholderAiMessage)
        let aiMessageIndex = chatMessages.count - 1
        
        Task.detached {
            while await !llamaContext.is_done {
                let result = await llamaContext.completion_loop()
                await MainActor.run {
                    self.messages += "\(result)"
                    aiResponse += result
                    
                    // Update the AI message in real-time
                    let updatedAiMessage = ChatMessage(
                        content: aiResponse,
                        isUser: false,
                        timestamp: self.chatMessages[aiMessageIndex].timestamp
                    )
                    self.chatMessages[aiMessageIndex] = updatedAiMessage
                }
            }
            await MainActor.run {
                self.messages += "\n"
                
                // Final update to AI message
                let finalAiMessage = ChatMessage(
                    content: aiResponse.trimmingCharacters(in: .whitespacesAndNewlines),
                    isUser: false,
                    timestamp: self.chatMessages[aiMessageIndex].timestamp
                )
                self.chatMessages[aiMessageIndex] = finalAiMessage
                
                // Set processing state to false when complete
                self.isProcessing = false
                
                // Images were already cleared at the start of completion
            }
            await llamaContext.clear()
        }
    }

    func clear() async {
        guard let llamaContext else {
            return
        }
        await llamaContext.clear()
        messages = ""
        chatMessages.removeAll()
        isProcessing = false
        clearSelectedImages()
        // Note: We don't reset isMultimodalLoaded here since the context retains multimodal support
    }
    
    // MARK: - Image Management
    
    func addImage(_ image: UIImage) {
        selectedImages.append(image)
    }
    
    func removeImage(at index: Int) {
        guard index < selectedImages.count else { return }
        selectedImages.remove(at: index)
    }
    
    func clearSelectedImages() {
        selectedImages.removeAll()
        // Clean up temporary files
        for path in temporaryImagePaths {
            try? FileManager.default.removeItem(atPath: path)
        }
        temporaryImagePaths.removeAll()
    }
    
    func hasMultimodalSupport() async -> Bool {
        guard let llamaContext else { return false }
        return await llamaContext.has_multimodal_support()
    }
    
    func restoreContextFromMessages(_ messages: [ChatMessage]) async {
        guard let llamaContext else { return }
        
        // Skip if no messages to restore
        guard !messages.isEmpty else { return }
        
        // Check if any messages contain images - if so, we need multimodal support
        let hasImageMessages = messages.contains { $0.imageData != nil && !$0.imageData!.isEmpty }
        if hasImageMessages {
            let _ = await ensureMultimodalSupport()
        }
        
        // Clear current context
        await llamaContext.clear()
        
        // Rebuild conversation history in the format the model expects
        var conversationHistory = ""
        
        for message in messages {
            if message.isUser {
                conversationHistory += "*\(message.content)*\n\n"
            } else {
                conversationHistory += "\(message.content)\n\n"
            }
        }
        
        // Initialize context with full conversation history
        let trimmedHistory = conversationHistory.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedHistory.isEmpty {
            print("Restoring context with \(messages.count) messages")
            
            // Initialize the context with the conversation history
            await llamaContext.completion_init(text: trimmedHistory)
            
            // Let the model process the conversation history to build context
            // but don't add the output to messages (this is just for context building)
            var outputBuffer = ""
            while await !llamaContext.is_done {
                let result = await llamaContext.completion_loop()
                outputBuffer += result
            }
            
            print("Context restored, processed \(outputBuffer.count) characters")
            
            // Clear the completion state but keep the built context
            await llamaContext.clear()
        }
    }
    
    private func prepareImagesForCompletion() async {
        guard let llamaContext else { return }
        
        // Clear previous temporary files
        for path in temporaryImagePaths {
            try? FileManager.default.removeItem(atPath: path)
        }
        temporaryImagePaths.removeAll()
        
        // Save images to temporary files and add to context
        for (index, image) in selectedImages.enumerated() {
            if let imageData = image.jpegData(compressionQuality: 0.8) {
                let tempURL = FileManager.default.temporaryDirectory
                    .appendingPathComponent("temp_image_\(index)_\(UUID().uuidString).jpg")
                
                do {
                    try imageData.write(to: tempURL)
                    let path = tempURL.path
                    temporaryImagePaths.append(path)
                    
                    let success = await llamaContext.add_image(path: path)
                    if !success {
                        print("Failed to add image \(index) to llama context")
                    }
                } catch {
                    print("Failed to save temporary image \(index): \(error)")
                }
            }
        }
    }
}
