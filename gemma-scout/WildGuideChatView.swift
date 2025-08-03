import SwiftUI
import PhotosUI

struct WildGuideChatView: View {
    @StateObject private var llamaState = LlamaState()
    @ObservedObject private var historyManager = ChatHistoryManager.shared
    @State private var inputText = ""
    @State private var showingInitialPrompts = true
    @State private var showingNewChatAlert = false
    @State private var showingImagePicker = false
    @State private var showingImageActionSheet = false
    @State private var showingCameraPicker = false
    
    let quickPrompts = [
        "How to build a fire?",
        "Finding safe water",
        "Emergency shelter",
        "Navigation basics"
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with wilderness theme
                headerView
                
                // Messages area
                messagesView
                
                // Input area
                inputView
            }
        }
        .navigationBarHidden(true)
        .onReceive(historyManager.$sessionToLoad) { session in
            if let session = session {
                loadChat(session)
                historyManager.clearLoadRequest()
            }
        }
        .confirmationDialog("Add Image", isPresented: $showingImageActionSheet) {
            Button("Camera") {
                showingCameraPicker = true
            }
            Button("Photo Library") {
                showingImagePicker = true
            }
            Button("Cancel", role: .cancel) { }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker { image in
                llamaState.addImage(image)
            }
        }
        .sheet(isPresented: $showingCameraPicker) {
            CameraPicker { image in
                llamaState.addImage(image)
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            Circle()
                .fill(LinearGradient(
                    gradient: Gradient(colors: [Color.green, Color.blue]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "compass")
                        .foregroundColor(.white)
                        .font(.title2)
                )
            
            VStack(alignment: .leading) {
                Text("Gemma Scout")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text("Your survival companion")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.9))
            }
            
            Spacer()
            
            // New Chat Button
            Button(action: {
                if !llamaState.messages.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    showingNewChatAlert = true
                } else {
                    startNewChat()
                }
            }) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundColor(.white)
            }
        }
        .padding()
        .background(LinearGradient(
            colors: [.green, .teal],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ))
        .alert("Start New Chat", isPresented: $showingNewChatAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Start New Chat") {
                saveCurrentChatAndStartNew()
            }
        } message: {
            Text("This will save your current conversation and start a new chat.")
        }
    }
    
    private var messagesView: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: true) {
                LazyVStack(spacing: 16) {
                    // Add some top padding
                    Color.clear.frame(height: 8)
                    
                    // Display chat messages with images inline
                    if !llamaState.chatMessages.isEmpty {
                        ForEach(llamaState.chatMessages) { message in
                            messageView(for: message)
                        }
                    }
                    
                    // Display selected images for current input
                    if !llamaState.selectedImages.isEmpty {
                        selectedImagesView
                    }
                    
                    // Display the legacy text messages if no chat messages exist
                    if llamaState.chatMessages.isEmpty && !llamaState.messages.isEmpty {
                        Text(.init(llamaState.messages))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                            .textSelection(.enabled)
                            .font(.body)
                    }
                    
                    // Quick prompts (show when no messages yet)
                    if llamaState.chatMessages.isEmpty && llamaState.messages.isEmpty {
                        quickPromptsView
                    }
                    
                    // Bottom spacer for scrolling
                    Color.clear
                        .frame(height: 20)
                        .id("bottom")
                }
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
            .onChange(of: llamaState.chatMessages) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        proxy.scrollTo("bottom", anchor: .bottom)
                    }
                }
            }
            .onChange(of: llamaState.messages) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        proxy.scrollTo("bottom", anchor: .bottom)
                    }
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    proxy.scrollTo("bottom", anchor: .bottom)
                }
            }
        }
    }
    
    private func messageView(for message: ChatMessage) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // Message header
                HStack {
                    Circle()
                        .fill(message.isUser ? Color.blue : Color.green)
                        .frame(width: 20, height: 20)
                        .overlay(
                            Image(systemName: message.isUser ? "person.fill" : "compass")
                                .font(.caption2)
                                .foregroundColor(.white)
                        )
                    
                    Text(message.isUser ? "You" : "Gemma Scout")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(message.timestamp.formatted(date: .omitted, time: .shortened))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                
                Spacer()
            }
            
            // Images if any
            if let imageData = message.imageData, !imageData.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(imageData.enumerated()), id: \.offset) { index, data in
                            if let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 120, height: 120)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .frame(height: 130)
            }
            
            // Message text
            Text(.init(message.content))
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
                .textSelection(.enabled)
                .font(.body)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color(.systemGray6).opacity(0.3))
        .cornerRadius(12)
        .padding(.horizontal, 8)
    }
    
    private var quickPromptsView: some View {
        VStack(spacing: 8) {
            Text("Try asking about:")
                .font(.caption)
                .foregroundColor(.secondary)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                ForEach(quickPrompts, id: \.self) { prompt in
                    Button(action: {
                        inputText = prompt
                    }) {
                        Text(prompt)
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray6))
                            .foregroundColor(.primary)
                            .cornerRadius(8)
                    }
                }
            }
        }
        .padding()
    }
    
    private var inputView: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(alignment: .bottom, spacing: 12) {
                // Text input
                ZStack(alignment: .leading) {
                    if inputText.isEmpty {
                        Text("Ask about survival techniques...")
                            .foregroundColor(Color(.placeholderText))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 12)
                    }
                    
                    TextEditor(text: $inputText)
                        .padding(8)
                        .frame(minHeight: 40, maxHeight: 120)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }
                
                // Buttons
                VStack(spacing: 8) {
                    // Image picker button
                    Button(action: {
                        showingImageActionSheet = true
                    }) {
                        Image(systemName: "photo.circle.fill")
                            .font(.title2)
                            .foregroundColor(llamaState.isProcessing ? .gray : .green)
                    }
                    .disabled(llamaState.isProcessing)
                    
                    // Send button or loading indicator
                    Button(action: sendMessage) {
                        if llamaState.isProcessing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.title2)
                                .foregroundColor(inputText.isEmpty ? .gray : .blue)
                        }
                    }
                    .disabled(inputText.isEmpty || llamaState.isProcessing)
                    
                    // Clear chat button
                    Button(action: clearMessages) {
                        Image(systemName: "trash.circle.fill")
                            .font(.title2)
                            .foregroundColor(llamaState.isProcessing ? .gray : .red)
                    }
                    .disabled(llamaState.messages.isEmpty || llamaState.isProcessing)
                }
            }
            .padding()
        }
        .background(Color(.systemBackground))
    }
    
    private func sendMessage() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        // Add user input to llamaState.messages (like the original implementation)
        llamaState.messages += "\n\n"
        llamaState.messages += "*\(inputText)*"
        llamaState.messages += "\n\n"
        
        let userInput = inputText
        inputText = ""
        showingInitialPrompts = false
        
        // Load model and get AI response
        do {
            try llamaState.loadModel()
        } catch {
            llamaState.messages += "Error loading model!\n"
            llamaState.isProcessing = false
            return
        }
        
        Task {
            await llamaState.complete(text: userInput)
            
            // Update the current chat session if we're in an existing conversation
            if let currentChatId = historyManager.currentChatId {
                historyManager.updateCurrentChatWithMessages(llamaState.chatMessages)
            }
        }
    }
    
    private func clearMessages() {
        Task {
            await llamaState.clear()
            showingInitialPrompts = true
        }
    }
    
    private func saveCurrentChatAndStartNew() {
        // Save current chat if it has content
        if !llamaState.chatMessages.isEmpty {
            let title = generateChatTitle(from: llamaState.chatMessages)
            historyManager.saveChatSessionFromMessages(title: title, messages: llamaState.chatMessages)
        } else if !llamaState.messages.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            // Fallback to legacy messages if new structure is empty
            let title = generateChatTitle(from: llamaState.messages)
            historyManager.saveChatSession(title: title, content: llamaState.messages)
        }
        
        // Start new chat
        startNewChat()
    }
    
    private func startNewChat() {
        Task {
            await llamaState.clear()
            showingInitialPrompts = true
            historyManager.startNewChat()
        }
    }
    
    private func generateChatTitle(from content: String) -> String {
        let lines = content.split(separator: "\n").filter { !$0.isEmpty }
        if let firstUserMessage = lines.first(where: { $0.hasPrefix("*") && $0.hasSuffix("*") }) {
            let cleaned = String(firstUserMessage.dropFirst().dropLast()).trimmingCharacters(in: .whitespacesAndNewlines)
            return cleaned.count > 30 ? String(cleaned.prefix(27)) + "..." : cleaned
        }
        return "Wilderness Chat"
    }
    
    private func generateChatTitle(from messages: [ChatMessage]) -> String {
        if let firstUserMessage = messages.first(where: { $0.isUser }) {
            let cleaned = firstUserMessage.content.trimmingCharacters(in: .whitespacesAndNewlines)
            return cleaned.count > 30 ? String(cleaned.prefix(27)) + "..." : cleaned
        }
        return "Wilderness Chat"
    }
    
    func loadChat(_ session: ChatSession) {
        Task {
            // Set loading state
            llamaState.isProcessing = true
            
            // Load the model first
            do {
                try llamaState.loadModel()
            } catch {
                print("Error loading model: \(error)")
                llamaState.isProcessing = false
                return
            }
            
            await llamaState.clear()
            
            // Load messages from new structure if available, otherwise use legacy content
            if !session.messages.isEmpty {
                llamaState.chatMessages = session.messages
                // Restore context for continuation
                await llamaState.restoreContextFromMessages(session.messages)
            } else {
                llamaState.messages = session.content
            }
            
            showingInitialPrompts = false
            historyManager.loadChat(session)
            
            // Clear loading state
            llamaState.isProcessing = false
        }
    }
    
    private var selectedImagesView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(llamaState.selectedImages.enumerated()), id: \.offset) { index, image in
                    ZStack(alignment: .topTrailing) {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        
                        Button(action: {
                            llamaState.removeImage(at: index)
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(.white)
                                .background(Color.black.opacity(0.6))
                                .clipShape(Circle())
                        }
                        .offset(x: 5, y: -5)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .frame(height: 90)
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    let onImageSelected: (UIImage) -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onImageSelected: onImageSelected)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let onImageSelected: (UIImage) -> Void
        
        init(onImageSelected: @escaping (UIImage) -> Void) {
            self.onImageSelected = onImageSelected
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                onImageSelected(image)
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

struct CameraPicker: UIViewControllerRepresentable {
    let onImageSelected: (UIImage) -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        picker.allowsEditing = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onImageSelected: onImageSelected)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let onImageSelected: (UIImage) -> Void
        
        init(onImageSelected: @escaping (UIImage) -> Void) {
            self.onImageSelected = onImageSelected
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                onImageSelected(image)
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

#Preview {
    WildGuideChatView()
}