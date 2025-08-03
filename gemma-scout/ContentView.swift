import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var chatView = WildGuideChatView()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            chatView
                .tabItem {
                    Image(systemName: "message.circle")
                    Text("Chat")
                }
                .tag(0)
            
            LibraryView()
                .tabItem {
                    Image(systemName: "book")
                    Text("Library")
                }
                .tag(1)
            
            HistoryView()
                .tabItem {
                    Image(systemName: "clock.arrow.circlepath")
                    Text("History")
                }
                .tag(2)
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person")
                    Text("Profile")
                }
                .tag(3)
        }
        .accentColor(.primary)
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("LoadChatSession"))) { notification in
            if let session = notification.object as? ChatSession {
                chatView.loadChat(session)
                selectedTab = 0 // Switch to chat tab
            }
        }
    }
}

#Preview {
    ContentView()
}