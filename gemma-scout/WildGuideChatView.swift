import SwiftUI

struct Message: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
    let timestamp: Date
}

struct WildGuideChatView: View {
    @StateObject private var llamaState = LlamaState()
    @State private var inputText = ""
    @State private var messages: [Message] = []
    
    let quickPrompts = [
        "How to build a fire?",
        "Finding safe water",
        "Emergency shelter",
        "Navigation basics"
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with wilderness theme
            headerView
            
            // Messages area
            messagesView
            
            // Input area
            inputView
        }
        .onAppear {
            initializeChat()
        }
    }
    
    private var headerView: some View {
        ZStack {
            // Background gradient simulating wilderness image
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.green.opacity(0.8),
                    Color.brown.opacity(0.6)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 120)
            
            VStack {
                Spacer()
                HStack {
                    // App icon placeholder
                    Circle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [Color.green, Color.blue]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 48, height: 48)
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
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
    }
    
    private var messagesView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(messages) { message in
                        MessageBubble(message: message)
                    }
                    
                    // Quick prompts (show when only initial message)
                    if messages.count == 1 {
                        quickPromptsView
                    }
                    
                    Color.clear
                        .frame(height: 1)
                        .id("bottom")
                }
                .padding()
            }
            .onChange(of: messages.count) {
                withAnimation(.easeInOut(duration: 0.5)) {
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
            
            HStack(spacing: 12) {
                TextField("Ask about survival techniques...", text: $inputText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onSubmit {
                        sendMessage()
                    }
                
                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundColor(inputText.isEmpty ? .gray : .blue)
                }
                .disabled(inputText.isEmpty)
            }
            .padding()
        }
        .background(Color(.systemBackground))
    }
    
    private func initializeChat() {
        messages.append(Message(
            text: "Hello! I'm your AI wilderness survival guide. I can help you with camping tips, wildlife safety, emergency procedures, and outdoor navigation. What would you like to know?",
            isUser: false,
            timestamp: Date()
        ))
    }
    
    private func sendMessage() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let userMessage = Message(
            text: inputText,
            isUser: true,
            timestamp: Date()
        )
        
        messages.append(userMessage)
        let userInput = inputText
        inputText = ""
        
        // Load model and get AI response
        do {
            try llamaState.loadModel()
        } catch {
            let errorMessage = Message(
                text: "Error loading model: \(error.localizedDescription)",
                isUser: false,
                timestamp: Date()
            )
            messages.append(errorMessage)
            return
        }
        
        Task {
            await llamaState.complete(text: userInput)
            
            await MainActor.run {
                if !llamaState.messages.isEmpty {
                    let aiResponse = Message(
                        text: llamaState.messages,
                        isUser: false,
                        timestamp: Date()
                    )
                    messages.append(aiResponse)
                    llamaState.messages = "" // Clear for next use
                }
            }
        }
    }
}

struct MessageBubble: View {
    let message: Message
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
                messageBubble
                    .background(Color.blue)
                    .foregroundColor(.white)
            } else {
                messageBubble
                    .background(Color(.systemGray6))
                    .foregroundColor(.primary)
                Spacer()
            }
        }
    }
    
    private var messageBubble: some View {
        VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
            Text(message.text)
                .font(.body)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            
            Text(message.timestamp, style: .time)
                .font(.caption2)
                .opacity(0.7)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
        }
        .background(Color.clear)
        .cornerRadius(16)
        .frame(maxWidth: UIScreen.main.bounds.width * 0.8, alignment: message.isUser ? .trailing : .leading)
    }
}

#Preview {
    WildGuideChatView()
}