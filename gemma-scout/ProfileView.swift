import SwiftUI

struct ProfileStat {
    let label: String
    let value: String
    let color: Color
}

struct MenuItem {
    let id: String
    let icon: String
    let title: String
    let subtitle: String
    let badge: String?
}

struct ProfileView: View {
    let stats = [
        ProfileStat(label: "Guides Read", value: "23", color: .blue),
        ProfileStat(label: "Chats", value: "47", color: .green),
        ProfileStat(label: "Bookmarks", value: "12", color: .orange)
    ]
    
    let menuItems = [
        MenuItem(
            id: "offline",
            icon: "arrow.down.circle",
            title: "Offline Content",
            subtitle: "Download guides for offline use",
            badge: "12 guides"
        ),
        MenuItem(
            id: "emergency",
            icon: "shield",
            title: "Emergency Contacts",
            subtitle: "Set up emergency information",
            badge: nil
        ),
        MenuItem(
            id: "settings",
            icon: "gear",
            title: "Settings",
            subtitle: "App preferences and privacy",
            badge: nil
        ),
        MenuItem(
            id: "help",
            icon: "questionmark.circle",
            title: "Help & Support",
            subtitle: "Get help and send feedback",
            badge: nil
        )
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Content
                ScrollView {
                    VStack(spacing: 24) {
                        quickActionsSection
                        menuItemsSection
                        appInfoSection
                        footerSection
                    }
                    .padding()
                }
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                Circle()
                    .fill(LinearGradient(
                        colors: [.green, .blue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 64, height: 64)
                    .overlay(
                        Image(systemName: "person")
                            .font(.title)
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Wilderness Explorer")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    Text("Survival enthusiast")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            
            // Stats
            HStack {
                ForEach(stats, id: \.label) { stat in
                    VStack(spacing: 4) {
                        Text(stat.value)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(stat.color)
                        Text(stat.label)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.5))
    }
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 12) {
                QuickActionButton(
                    icon: "arrow.down.circle",
                    title: "Download All",
                    backgroundColor: LinearGradient(
                        colors: [.green, .blue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                
                QuickActionButton(
                    icon: "shield",
                    title: "Emergency",
                    backgroundColor: LinearGradient(
                        colors: [.orange, .red],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            }
        }
    }
    
    private var menuItemsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Account & Settings")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 8) {
                ForEach(menuItems, id: \.id) { item in
                    MenuItemCard(item: item)
                }
            }
        }
    }
    
    private var appInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("About")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                InfoRow(label: "App Version", value: "1.0.0")
                InfoRow(label: "AI Model", value: "Gemma 3 4B")
                InfoRow(label: "Storage Used", value: "2.8 GB")
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
    
    private var footerSection: some View {
        VStack(spacing: 8) {
            Text("WildGuide AI • Built for wilderness survival")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Text("Always prioritize safety and proper training")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical)
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    let backgroundColor: LinearGradient
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(backgroundColor)
        .cornerRadius(12)
    }
}

struct MenuItemCard: View {
    let item: MenuItem
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.blue.opacity(0.1))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: item.icon)
                        .foregroundColor(.blue)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(item.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    if let badge = item.badge {
                        Text(badge)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(4)
                            .foregroundColor(.secondary)
                    }
                }
                
                Text(item.subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    ProfileView()
}