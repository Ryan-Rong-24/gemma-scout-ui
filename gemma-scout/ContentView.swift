import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            WildGuideChatView()
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
            
            BookmarksView()
                .tabItem {
                    Image(systemName: "bookmark")
                    Text("Saved")
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
    }
}

#Preview {
    ContentView()
}