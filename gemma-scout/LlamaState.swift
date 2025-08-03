import Foundation
import UIKit

@MainActor
class LlamaState: ObservableObject {
    @Published var messages = ""
    @Published var selectedImages: [UIImage] = []
    @Published var chatMessages: [ChatMessage] = []
    @Published var isProcessing = false
    private var llamaContext: LlamaContext?
    private var temporaryImagePaths: [String] = []

    func loadModel() throws {
        if let modelPath = Bundle.main.path(forResource: "ggml-org_gemma-3-4b-it-GGUF_gemma-3-4b-it-Q4_K_M", ofType: "gguf") {
            // Try to load multimodal projection model
            let mmproj_path = Bundle.main.path(forResource: "ggml-org_gemma-3-4b-it-GGUF_mmproj-model-f16", ofType: "gguf")
            
            llamaContext = try LlamaContext.create_context(path: modelPath, mmproj_path: mmproj_path)
            return
        }
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

        // Prepare images if any are selected and clear them from UI immediately
        let hasImages = !selectedImages.isEmpty
        if hasImages {
            await prepareImagesForCompletion()
            // Clear images from UI immediately after processing
            selectedImages.removeAll()
            await llamaContext.completion_init_with_images(text: text)
        } else {
            await llamaContext.completion_init(text: text)
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
