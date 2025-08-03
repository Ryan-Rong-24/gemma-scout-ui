import SwiftUI

struct HistoryView: View {
    @ObservedObject private var historyManager = ChatHistoryManager.shared
    @State private var selectedChatToDelete: ChatSession?
    @State private var showingDeleteAlert = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Content
                if historyManager.chatSessions.isEmpty {
                    emptyStateView
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(historyManager.chatSessions) { session in
                                ChatHistoryCard(
                                    session: session,
                                    onTap: { loadChat(session) },
                                    onDelete: { deleteChat(session) }
                                )
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .alert("Delete Chat", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { 
                selectedChatToDelete = nil
            }
            Button("Delete", role: .destructive) {
                if let session = selectedChatToDelete {
                    historyManager.deleteChat(session)
                }
                selectedChatToDelete = nil
            }
        } message: {
            Text("Are you sure you want to delete this chat? This action cannot be undone.")
        }
    }
    
    private var headerView: some View {
        HStack {
            Circle()
                .fill(Color.white.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "clock.arrow.circlepath")
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading) {
                Text("Chat History")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text("\(historyManager.chatSessions.count) conversations")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.9))
            }
            Spacer()
        }
        .padding()
        .background(LinearGradient(
            colors: [.orange, .red],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ))
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Circle()
                .fill(Color(.systemGray6))
                .frame(width: 64, height: 64)
                .overlay(
                    Image(systemName: "message")
                        .font(.title)
                        .foregroundColor(.secondary)
                )
            
            Text("No chat history yet")
                .font(.headline)
                .fontWeight(.medium)
            
            Text("Start a conversation and it will appear here for easy access later")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func loadChat(_ session: ChatSession) {
        // Request loading the chat through the shared manager
        historyManager.requestLoadChat(session)
        
        // Also post notification to switch to chat tab
        NotificationCenter.default.post(
            name: NSNotification.Name("SwitchToChatTab"), 
            object: nil
        )
    }
    
    private func deleteChat(_ session: ChatSession) {
        selectedChatToDelete = session
        showingDeleteAlert = true
    }
}

struct ChatHistoryCard: View {
    let session: ChatSession
    let onTap: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(session.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                    
                    Text(session.preview)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(session.lastModified, style: .date)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
            
            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Image(systemName: "message")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(session.messageCount) messages")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(session.createdDate, style: .time)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .onTapGesture {
            onTap()
        }
    }
}

#Preview {
    HistoryView()
}