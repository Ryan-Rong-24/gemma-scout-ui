import Foundation

struct ChatSession: Codable, Identifiable {
    let id: UUID
    let title: String
    let content: String
    let createdDate: Date
    let lastModified: Date
    
    init(title: String, content: String, createdDate: Date, lastModified: Date) {
        self.id = UUID()
        self.title = title
        self.content = content
        self.createdDate = createdDate
        self.lastModified = lastModified
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
    @Published var chatSessions: [ChatSession] = []
    @Published var currentChatId: UUID?
    
    private let userDefaults = UserDefaults.standard
    private let chatHistoryKey = "ChatHistoryKey"
    
    init() {
        loadChatHistory()
    }
    
    func saveChatSession(title: String, content: String) {
        guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let session = ChatSession(
            title: title,
            content: content,
            createdDate: Date(),
            lastModified: Date()
        )
        
        chatSessions.insert(session, at: 0) // Add to beginning for newest first
        saveChatHistory()
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