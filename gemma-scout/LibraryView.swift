import SwiftUI

struct Category {
    let id: String
    let name: String
    let count: Int
    let gradient: LinearGradient
}

struct Guide {
    let id: String
    let title: String
    let category: String
    let readTime: String
    let difficulty: String
    let rating: Double
}

struct LibraryView: View {
    @State private var searchText = ""
    
    let categories = [
        Category(id: "fire", name: "Fire & Warmth", count: 12, 
                gradient: LinearGradient(colors: [.orange, .red], startPoint: .topLeading, endPoint: .bottomTrailing)),
        Category(id: "water", name: "Water & Hydration", count: 8,
                gradient: LinearGradient(colors: [.blue, .teal], startPoint: .topLeading, endPoint: .bottomTrailing)),
        Category(id: "shelter", name: "Shelter & Protection", count: 15,
                gradient: LinearGradient(colors: [.brown, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)),
        Category(id: "navigation", name: "Navigation", count: 6,
                gradient: LinearGradient(colors: [.green, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)),
        Category(id: "food", name: "Food & Foraging", count: 10,
                gradient: LinearGradient(colors: [.green, .yellow], startPoint: .topLeading, endPoint: .bottomTrailing)),
        Category(id: "safety", name: "Wildlife Safety", count: 7,
                gradient: LinearGradient(colors: [.red, .orange], startPoint: .topLeading, endPoint: .bottomTrailing))
    ]
    
    let recentGuides = [
        Guide(id: "1", title: "Building a Fire in Wet Conditions", category: "Fire & Warmth", 
              readTime: "5 min", difficulty: "Intermediate", rating: 4.8),
        Guide(id: "2", title: "Emergency Water Purification Methods", category: "Water & Hydration",
              readTime: "7 min", difficulty: "Beginner", rating: 4.9),
        Guide(id: "3", title: "Reading Natural Weather Signs", category: "Navigation",
              readTime: "6 min", difficulty: "Advanced", rating: 4.7)
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Content
                ScrollView {
                    VStack(spacing: 24) {
                        categoriesSection
                        recentGuidesSection
                        quickAccessSection
                    }
                    .padding()
                }
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            HStack {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "book")
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading) {
                    Text("Survival Library")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Text("Essential wilderness knowledge")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                }
                Spacer()
            }
            
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white.opacity(0.7))
                
                TextField("Search guides and tips...", text: $searchText)
                    .foregroundColor(.white)
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(10)
        }
        .padding()
        .background(LinearGradient(
            colors: [.green, .teal],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ))
    }
    
    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Categories")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(categories, id: \.id) { category in
                    CategoryCard(category: category)
                }
            }
        }
    }
    
    private var recentGuidesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent & Popular")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                ForEach(recentGuides, id: \.id) { guide in
                    GuideCard(guide: guide)
                }
            }
        }
    }
    
    private var quickAccessSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Access")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 8) {
                QuickAccessCard(
                    icon: "flame",
                    title: "Emergency Checklist",
                    subtitle: "Essential items to survive",
                    gradient: LinearGradient(colors: [.orange, .red], startPoint: .leading, endPoint: .trailing)
                )
                
                QuickAccessCard(
                    icon: "compass",
                    title: "Offline Maps",
                    subtitle: "Downloaded for offline use",
                    gradient: LinearGradient(colors: [.green, .blue], startPoint: .leading, endPoint: .trailing)
                )
            }
        }
    }
}

struct CategoryCard: View {
    let category: Category
    
    var body: some View {
        VStack(spacing: 12) {
            Rectangle()
                .fill(category.gradient)
                .frame(height: 64)
                .cornerRadius(10)
                .overlay(
                    Text("\(category.count)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(category.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text("\(category.count) guides")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct GuideCard: View {
    let guide: Guide
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(guide.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.leading)
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                    Text(String(format: "%.1f", guide.rating))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack(spacing: 8) {
                Text(guide.category)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(4)
                
                Text(guide.difficulty)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(difficultyColor(guide.difficulty))
                    .cornerRadius(4)
            }
            
            HStack {
                Image(systemName: "clock")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(guide.readTime)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func difficultyColor(_ difficulty: String) -> Color {
        switch difficulty {
        case "Beginner": return Color.green.opacity(0.1)
        case "Intermediate": return Color.yellow.opacity(0.1)
        case "Advanced": return Color.red.opacity(0.1)
        default: return Color.gray.opacity(0.1)
        }
    }
}

struct QuickAccessCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let gradient: LinearGradient
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(gradient)
                .frame(width: 32, height: 32)
                .overlay(
                    Image(systemName: icon)
                        .foregroundColor(.white)
                        .font(.caption)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    LibraryView()
}