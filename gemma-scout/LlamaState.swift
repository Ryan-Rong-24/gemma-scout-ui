import Foundation
import UIKit

@MainActor
class LlamaState: ObservableObject {
    @Published var messages = ""
    @Published var selectedImages: [UIImage] = []
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

        // Prepare images if any are selected
        if !selectedImages.isEmpty {
            await prepareImagesForCompletion()
            await llamaContext.completion_init_with_images(text: text)
        } else {
            await llamaContext.completion_init(text: text)
        }
        
        Task.detached {
            while await !llamaContext.is_done {
                let result = await llamaContext.completion_loop()
                await MainActor.run {
                    self.messages += "\(result)"
                }
            }
            await MainActor.run {
                self.messages += "\n"
                // Clear images after completion
                self.clearSelectedImages()
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
