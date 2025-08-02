import Foundation

@MainActor
class LlamaState: ObservableObject {
    @Published var messages = ""
    private var llamaContext: LlamaContext?

    func loadModel() throws {
        if let modelPath = Bundle.main.path(forResource: "ggml-org_gemma-3-4b-it-GGUF_gemma-3-4b-it-Q4_K_M", ofType: "gguf") {
            llamaContext = try LlamaContext.create_context(path: modelPath)
            return
        }
    }

    func complete(text: String) async {
        guard let llamaContext else {
            return
        }

        await llamaContext.completion_init(text: text)
        Task.detached {
            while await !llamaContext.is_done {
                let result = await llamaContext.completion_loop()
                await MainActor.run {
                    self.messages += "\(result)"
                }
            }
            await MainActor.run {
                self.messages += "\n"
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
    }
}
