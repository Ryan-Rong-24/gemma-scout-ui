import Foundation

struct ChatMessage: Codable, Identifiable, Equatable {
    let id: UUID
    let content: String
    let isUser: Bool
    let timestamp: Date
    let imageData: [Data]? // Store image data as Data array
    
    init(content: String, isUser: Bool, timestamp: Date, imageData: [Data]? = nil) {
        self.id = UUID()
        self.content = content
        self.isUser = isUser
        self.timestamp = timestamp
        self.imageData = imageData
    }
    
    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        return lhs.id == rhs.id && lhs.content == rhs.content && lhs.isUser == rhs.isUser
    }
}

struct ChatSession: Codable, Identifiable {
    let id: UUID
    let title: String
    let messages: [ChatMessage]
    let createdDate: Date
    let lastModified: Date
    
    // Legacy content property for backward compatibility
    var content: String {
        return messages.map { message in
            if message.isUser {
                return "*\(message.content)*"
            } else {
                return message.content
            }
        }.joined(separator: "\n\n")
    }
    
    init(title: String, messages: [ChatMessage], createdDate: Date, lastModified: Date) {
        self.id = UUID()
        self.title = title
        self.messages = messages
        self.createdDate = createdDate
        self.lastModified = lastModified
    }
    
    // Legacy initializer for backward compatibility
    init(title: String, content: String, createdDate: Date, lastModified: Date) {
        self.id = UUID()
        self.title = title
        self.createdDate = createdDate
        self.lastModified = lastModified
        
        // Parse legacy content into messages
        var parsedMessages: [ChatMessage] = []
        let lines = content.split(separator: "\n").map(String.init)
        var currentMessage = ""
        var isUserMessage = false
        
        for line in lines {
            if line.hasPrefix("*") && line.hasSuffix("*") {
                // Save previous message if exists
                if !currentMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    parsedMessages.append(ChatMessage(
                        content: currentMessage.trimmingCharacters(in: .whitespacesAndNewlines),
                        isUser: isUserMessage,
                        timestamp: createdDate
                    ))
                }
                // Start new user message
                let userContent = String(line.dropFirst().dropLast())
                parsedMessages.append(ChatMessage(
                    content: userContent,
                    isUser: true,
                    timestamp: createdDate
                ))
                currentMessage = ""
                isUserMessage = false
            } else if !line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                currentMessage += line + "\n"
                isUserMessage = false
            }
        }
        
        // Save final message if exists
        if !currentMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            parsedMessages.append(ChatMessage(
                content: currentMessage.trimmingCharacters(in: .whitespacesAndNewlines),
                isUser: isUserMessage,
                timestamp: createdDate
            ))
        }
        
        self.messages = parsedMessages
    }
    
    var preview: String {
        let lines = content.split(separator: "\n").filter { !$0.isEmpty }
        if let firstUserMessage = lines.first(where: { $0.hasPrefix("*") && $0.hasSuffix("*") }) {
            let cleaned = String(firstUserMessage.dropFirst().dropLast())
            return cleaned.count > 50 ? String(cleaned.prefix(47)) + "..." : cleaned
        }
        return "New Chat"
    }
    
    var messageCount: Int {
        let userMessages = content.split(separator: "\n").filter { $0.hasPrefix("*") && $0.hasSuffix("*") }
        return userMessages.count
    }
}

@MainActor
class ChatHistoryManager: ObservableObject {
    static let shared = ChatHistoryManager()
    
    @Published var chatSessions: [ChatSession] = []
    @Published var currentChatId: UUID?
    @Published var currentMessages: [ChatMessage] = []
    @Published var sessionToLoad: ChatSession?
    
    private let userDefaults = UserDefaults.standard
    private let chatHistoryKey = "ChatHistoryKey"
    
    private init() {
        loadChatHistory()
    }
    
    func saveChatSession(title: String, content: String) {
        guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { 
            return 
        }
        
        let session = ChatSession(
            title: title,
            content: content,
            createdDate: Date(),
            lastModified: Date()
        )
        
        chatSessions.insert(session, at: 0) // Add to beginning for newest first
        saveChatHistory()
    }
    
    func saveChatSessionFromMessages(title: String, messages: [ChatMessage]) {
        guard !messages.isEmpty else { return }
        
        let session = ChatSession(
            title: title,
            messages: messages,
            createdDate: Date(),
            lastModified: Date()
        )
        
        chatSessions.insert(session, at: 0)
        saveChatHistory()
    }
    
    func addMessage(_ message: ChatMessage) {
        currentMessages.append(message)
    }
    
    func clearCurrentMessages() {
        currentMessages.removeAll()
    }
    
    func updateCurrentChat(content: String) {
        guard let currentId = currentChatId,
              let index = chatSessions.firstIndex(where: { $0.id == currentId }) else { return }
        
        let updatedSession = chatSessions[index]
        let newSession = ChatSession(
            title: updatedSession.title,
            content: content,
            createdDate: updatedSession.createdDate,
            lastModified: Date()
        )
        
        chatSessions[index] = newSession
        saveChatHistory()
    }
    
    func updateCurrentChatWithMessages(_ messages: [ChatMessage]) {
        guard let currentId = currentChatId,
              let index = chatSessions.firstIndex(where: { $0.id == currentId }) else { return }
        
        let updatedSession = chatSessions[index]
        let newSession = ChatSession(
            title: updatedSession.title,
            messages: messages,
            createdDate: updatedSession.createdDate,
            lastModified: Date()
        )
        
        chatSessions[index] = newSession
        saveChatHistory()
    }
    
    func deleteChat(_ session: ChatSession) {
        chatSessions.removeAll { $0.id == session.id }
        if currentChatId == session.id {
            currentChatId = nil
        }
        saveChatHistory()
    }
    
    func startNewChat() {
        currentChatId = nil
    }
    
    func loadChat(_ session: ChatSession) {
        currentChatId = session.id
    }
    
    func requestLoadChat(_ session: ChatSession) {
        sessionToLoad = session
    }
    
    func clearLoadRequest() {
        sessionToLoad = nil
    }
    
    private func saveChatHistory() {
        do {
            let data = try JSONEncoder().encode(chatSessions)
            userDefaults.set(data, forKey: chatHistoryKey)
        } catch {
            print("Failed to save chat history: \(error)")
        }
    }
    
    private func loadChatHistory() {
        guard let data = userDefaults.data(forKey: chatHistoryKey) else { return }
        
        do {
            chatSessions = try JSONDecoder().decode([ChatSession].self, from: data)
        } catch {
            print("Failed to load chat history: \(error)")
            chatSessions = []
        }
    }
}