import SwiftUI

struct WildGuideChatView: View {
    @StateObject private var llamaState = LlamaState()
    @ObservedObject private var historyManager = ChatHistoryManager.shared
    @State private var inputText = ""
    @State private var showingInitialPrompts = true
    @State private var showingNewChatAlert = false
    
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
                Text("WildGuide AI")
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
                    
                    // Display the actual chat messages from llamaState
                    if !llamaState.messages.isEmpty {
                        Text(.init(llamaState.messages))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                            .textSelection(.enabled)
                            .font(.body)
                    }
                    
                    // Quick prompts (show when no messages yet)
                    if llamaState.messages.isEmpty {
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
                    // Send button
                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                            .foregroundColor(inputText.isEmpty ? .gray : .blue)
                    }
                    .disabled(inputText.isEmpty)
                    
                    // Clear chat button
                    Button(action: clearMessages) {
                        Image(systemName: "trash.circle.fill")
                            .font(.title2)
                            .foregroundColor(.red)
                    }
                    .disabled(llamaState.messages.isEmpty)
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
            return
        }
        
        Task {
            await llamaState.complete(text: userInput)
        }
    }
    
    private func clearMessages() {
        Task {
            await llamaState.clear()
            showingInitialPrompts = true
        }
    }
    
    private func saveCurrentChatAndStartNew() {
        // Debug: Print current messages
        print("DEBUG: Current messages content: '\(llamaState.messages)'")
        print("DEBUG: Messages isEmpty: \(llamaState.messages.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)")
        
        // Save current chat if it has content
        if !llamaState.messages.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let title = generateChatTitle(from: llamaState.messages)
            print("DEBUG: Saving chat with title: '\(title)'")
            historyManager.saveChatSession(title: title, content: llamaState.messages)
            print("DEBUG: Chat sessions count after save: \(historyManager.chatSessions.count)")
        } else {
            print("DEBUG: No content to save - messages are empty")
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
    
    func loadChat(_ session: ChatSession) {
        Task {
            await llamaState.clear()
            llamaState.messages = session.content
            showingInitialPrompts = false
            historyManager.loadChat(session)
        }
    }
}

#Preview {
    WildGuideChatView()
}