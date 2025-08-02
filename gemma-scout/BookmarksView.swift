import SwiftUI

struct BookmarkedItem {
    let id: String
    let type: String // "guide" or "chat"
    let title: String
    let category: String
    let savedDate: String
    let readTime: String?
    let rating: Double?
    let preview: String?
}

struct BookmarksView: View {
    @State private var bookmarkedItems: [BookmarkedItem] = [
        BookmarkedItem(
            id: "1",
            type: "guide",
            title: "Building a Fire in Wet Conditions",
            category: "Fire & Warmth",
            savedDate: "2 days ago",
            readTime: "5 min",
            rating: 4.8,
            preview: nil
        ),
        BookmarkedItem(
            id: "2",
            type: "chat",
            title: "How to purify water using UV sterilization?",
            category: "Chat Response",
            savedDate: "1 week ago",
            readTime: nil,
            rating: nil,
            preview: "For UV sterilization: 1) Clear water of debris first, 2) Use UV sterilizer pen for 90 seconds per liter..."
        ),
        BookmarkedItem(
            id: "3",
            type: "guide",
            title: "Identifying Edible Plants in North America",
            category: "Food & Foraging",
            savedDate: "1 week ago",
            readTime: "12 min",
            rating: 4.9,
            preview: nil
        ),
        BookmarkedItem(
            id: "4",
            type: "chat",
            title: "Emergency signaling techniques in wilderness",
            category: "Chat Response",
            savedDate: "2 weeks ago",
            readTime: nil,
            rating: nil,
            preview: "Key signaling methods: 1) Three of anything (universal distress), 2) Mirror signals during day..."
        )
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Content
                if bookmarkedItems.isEmpty {
                    emptyStateView
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(bookmarkedItems, id: \.id) { item in
                                BookmarkCard(item: item)
                            }
                            
                            quickActionsSection
                        }
                        .padding()
                    }
                }
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            Circle()
                .fill(Color.white.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "star.fill")
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading) {
                Text("Saved Items")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text("\(bookmarkedItems.count) saved items")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.9))
            }
            Spacer()
        }
        .padding()
        .background(LinearGradient(
            colors: [.purple, .pink],
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
                    Image(systemName: "star")
                        .font(.title)
                        .foregroundColor(.secondary)
                )
            
            Text("No saved items yet")
                .font(.headline)
                .fontWeight(.medium)
            
            Text("Bookmark guides and chat responses for quick access")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Rectangle()
                .fill(Color(.systemGray5))
                .frame(height: 1)
                .padding(.vertical)
            
            Text("Quick Actions")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            VStack(spacing: 8) {
                QuickActionCard(
                    title: "Export saved items",
                    backgroundColor: Color.blue.opacity(0.1),
                    textColor: .blue
                )
                
                QuickActionCard(
                    title: "Clear all bookmarks",
                    backgroundColor: Color.red.opacity(0.1),
                    textColor: .red
                )
            }
        }
    }
}

struct BookmarkCard: View {
    let item: BookmarkedItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                HStack(spacing: 8) {
                    Text(item.type == "guide" ? "Guide" : "Chat")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(item.type == "guide" ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                        .foregroundColor(item.type == "guide" ? .blue : .secondary)
                        .cornerRadius(4)
                    
                    Text(item.savedDate)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(item.title)
                .font(.subheadline)
                .fontWeight(.medium)
                .multilineTextAlignment(.leading)
            
            Text(item.category)
                .font(.caption)
                .foregroundColor(.secondary)
            
            if let preview = item.preview {
                Text(preview)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            HStack(spacing: 16) {
                if let readTime = item.readTime {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(readTime)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                if let rating = item.rating {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
                        Text(String(format: "%.1f", rating))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct QuickActionCard: View {
    let title: String
    let backgroundColor: Color
    let textColor: Color
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(textColor)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(backgroundColor)
        .cornerRadius(12)
    }
}

#Preview {
    BookmarksView()
}