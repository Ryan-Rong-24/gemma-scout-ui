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
    let content: String
}

struct LibraryView: View {
    @State private var searchText = ""
    @State private var selectedCategory: String?
    
    var categories: [Category] {
        [
            Category(id: "fire", name: "Fire & Warmth", count: allGuides.filter { $0.category == "Fire & Warmth" }.count, 
                    gradient: LinearGradient(colors: [.orange, .red], startPoint: .topLeading, endPoint: .bottomTrailing)),
            Category(id: "water", name: "Water & Hydration", count: allGuides.filter { $0.category == "Water & Hydration" }.count,
                    gradient: LinearGradient(colors: [.blue, .teal], startPoint: .topLeading, endPoint: .bottomTrailing)),
            Category(id: "shelter", name: "Shelter & Protection", count: allGuides.filter { $0.category == "Shelter & Protection" }.count,
                    gradient: LinearGradient(colors: [.brown, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)),
            Category(id: "navigation", name: "Navigation", count: allGuides.filter { $0.category == "Navigation" }.count,
                    gradient: LinearGradient(colors: [.green, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)),
            Category(id: "food", name: "Food & Foraging", count: allGuides.filter { $0.category == "Food & Foraging" }.count,
                    gradient: LinearGradient(colors: [.green, .yellow], startPoint: .topLeading, endPoint: .bottomTrailing)),
            Category(id: "safety", name: "Wildlife Safety", count: allGuides.filter { $0.category == "Wildlife Safety" }.count,
                    gradient: LinearGradient(colors: [.red, .orange], startPoint: .topLeading, endPoint: .bottomTrailing))
        ]
    }
    
    let allGuides = [
        // Fire & Warmth (4 guides)
        Guide(id: "fire1", title: "Building a Fire in Wet Conditions", category: "Fire & Warmth", 
              readTime: "5 min", difficulty: "Intermediate", rating: 4.8,
              content: "Gather dry tinder from inner bark of birch trees or pine needles. Create a platform using larger sticks to keep tinder off wet ground. Use fatwood or birch bark as fire starter. Build a teepee structure with progressively larger dry wood."),
        Guide(id: "fire2", title: "Bow Drill Fire Starting", category: "Fire & Warmth",
              readTime: "8 min", difficulty: "Advanced", rating: 4.5,
              content: "Select dry cedar, basswood, or cottonwood for fireboard and spindle. Create notch at 45° angle. Use steady, consistent pressure and speed. Collect ember on tinder bundle and blow gently to create flame."),
        Guide(id: "fire3", title: "Fire Safety in Dry Conditions", category: "Fire & Warmth",
              readTime: "4 min", difficulty: "Beginner", rating: 4.9,
              content: "Clear 10-foot radius around fire site. Keep water nearby. Never leave fire unattended. Completely extinguish with water and stir ashes. Check for hot spots before leaving area."),
        Guide(id: "fire4", title: "Smokeless Fire Techniques", category: "Fire & Warmth",
              readTime: "6 min", difficulty: "Intermediate", rating: 4.6,
              content: "Use completely dry hardwood. Build Dakota fire hole with airflow tunnel. Avoid green wood and wet materials. Keep fire small and hot for minimal smoke production."),
        
        // Water & Hydration (4 guides)
        Guide(id: "water1", title: "Emergency Water Purification Methods", category: "Water & Hydration",
              readTime: "7 min", difficulty: "Beginner", rating: 4.9,
              content: "Boil water for 3+ minutes to kill pathogens. Use cloth to filter sediment first. Add water purification tablets if available. Solar disinfection in clear bottle for 6+ hours in direct sunlight."),
        Guide(id: "water2", title: "Finding Water in the Wild", category: "Water & Hydration",
              readTime: "6 min", difficulty: "Intermediate", rating: 4.7,
              content: "Follow animal trails to water sources. Look for green vegetation indicating nearby water. Collect dew with cloth in early morning. Find water at base of cliffs and rock formations."),
        Guide(id: "water3", title: "Solar Water Disinfection", category: "Water & Hydration",
              readTime: "5 min", difficulty: "Beginner", rating: 4.6,
              content: "Fill clear plastic bottles with water. Remove labels for maximum UV penetration. Lay bottles on reflective surface in direct sunlight for 6+ hours. Works best at temperatures above 86°F."),
        Guide(id: "water4", title: "Water Collection from Plants", category: "Water & Hydration",
              readTime: "8 min", difficulty: "Advanced", rating: 4.4,
              content: "Tree tap method: drill hole in maple, birch, or walnut trees. Bag transpiration: tie plastic bag around leafy branch. Morning dew collection with absorbent cloth. Cactus pad extraction in desert environments."),
        
        // Shelter & Protection (4 guides)
        Guide(id: "shelter1", title: "Debris Hut Construction", category: "Shelter & Protection",
              readTime: "12 min", difficulty: "Intermediate", rating: 4.8,
              content: "Find or create ridgepole 9-12 feet long. Angle at 45° supported by tree or rock. Layer ribs every 12 inches. Cover with debris 3+ feet thick for insulation. Create door plug."),
        Guide(id: "shelter2", title: "Emergency Lean-to Shelter", category: "Shelter & Protection",
              readTime: "8 min", difficulty: "Beginner", rating: 4.7,
              content: "Find sturdy ridgepole and lean against tree or rocks. Place support poles at 45° angle. Cover with branches, bark, or tarp. Face opening away from prevailing wind."),
        Guide(id: "shelter3", title: "Snow Cave Construction", category: "Shelter & Protection",
              readTime: "15 min", difficulty: "Advanced", rating: 4.5,
              content: "Find firm snow at least 6 feet deep. Dig entrance lower than sleeping area. Create ventilation hole at top. Smooth walls to prevent dripping. Mark entrance for visibility."),
        Guide(id: "shelter4", title: "Tarp Shelter Configurations", category: "Shelter & Protection",
              readTime: "6 min", difficulty: "Beginner", rating: 4.6,
              content: "A-frame: ridge line between two trees. Lean-to: one side elevated, other staked down. Diamond fly: corner attachment points. Plow point: streamlined for wind protection."),
        
        // Navigation (3 guides)
        Guide(id: "nav1", title: "Reading Natural Weather Signs", category: "Navigation",
              readTime: "6 min", difficulty: "Advanced", rating: 4.7,
              content: "Red sky at night indicates high pressure and fair weather. Mare's tail clouds suggest weather change in 24-48 hours. Wind direction changes indicate pressure changes. Animal behavior can predict storms."),
        Guide(id: "nav2", title: "Navigation Without Compass", category: "Navigation",
              readTime: "10 min", difficulty: "Intermediate", rating: 4.6,
              content: "Use stick shadow method for east-west direction. North Star location using Big Dipper. Moss growth patterns (typically north side in northern hemisphere). Sun position throughout day."),
        Guide(id: "nav3", title: "Map and Compass Basics", category: "Navigation",
              readTime: "12 min", difficulty: "Beginner", rating: 4.8,
              content: "Orient map using compass bearing. Triangulation with known landmarks. Following contour lines for elevation changes. Understanding topographic symbols and scale."),
        
        // Food & Foraging (4 guides)
        Guide(id: "food1", title: "Edible Plant Identification", category: "Food & Foraging",
              readTime: "15 min", difficulty: "Advanced", rating: 4.3,
              content: "Dandelions: entire plant edible. Plantain: natural bandage and edible. Clover: flowers and leaves. Wild garlic: strong onion smell. NEVER eat unknown plants - use universal edibility test."),
        Guide(id: "food2", title: "Fish Trap Construction", category: "Food & Foraging",
              readTime: "20 min", difficulty: "Intermediate", rating: 4.5,
              content: "Bottle trap: cut plastic bottle, invert top portion. Funnel trap: weave funnel from flexible branches. Rock weir: build V-shaped stone dam. Check local regulations before trapping."),
        Guide(id: "food3", title: "Food Preservation in Wild", category: "Food & Foraging",
              readTime: "10 min", difficulty: "Intermediate", rating: 4.4,
              content: "Smoking: thin strips over low, smoky fire for 12+ hours. Salt curing: cover meat in salt. Air drying: hang in cool, dry, ventilated area. Keep away from insects and moisture."),
        Guide(id: "food4", title: "Emergency Fishing Techniques", category: "Food & Foraging",
              readTime: "8 min", difficulty: "Beginner", rating: 4.6,
              content: "Improvised hooks from safety pins, paper clips. Use insects, worms, or small pieces of bright cloth as bait. Fish in deeper pools during hot weather. Early morning and evening are best times."),
        
        // Wildlife Safety (3 guides)
        Guide(id: "safety1", title: "Bear Encounter Protocols", category: "Wildlife Safety",
              readTime: "8 min", difficulty: "Intermediate", rating: 4.9,
              content: "Black bears: make noise, appear large, back away slowly. Grizzly bears: play dead if attacked, fight back with black bears. Never run - bears can reach 35 mph. Store food properly in bear containers."),
        Guide(id: "safety2", title: "Snake Bite Prevention", category: "Wildlife Safety",
              readTime: "6 min", difficulty: "Beginner", rating: 4.7,
              content: "Wear boots and long pants. Use flashlight at night. Step on logs, not over them. Make noise while hiking. If bitten: keep calm, remove jewelry, seek immediate medical attention."),
        Guide(id: "safety3", title: "Insect Protection Methods", category: "Wildlife Safety",
              readTime: "5 min", difficulty: "Beginner", rating: 4.5,
              content: "Natural repellents: mud coating, pine smoke. Cover exposed skin at dawn/dusk. Sleep in elevated, breezy areas. Check for ticks regularly. Remove ticks with fine-tipped tweezers.")
    ]
    
    var filteredGuides: [Guide] {
        var guides = allGuides
        
        // Filter by category if selected
        if let selectedCategory = selectedCategory {
            guides = guides.filter { $0.category == selectedCategory }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            guides = guides.filter { guide in
                guide.title.localizedCaseInsensitiveContains(searchText) ||
                guide.category.localizedCaseInsensitiveContains(searchText) ||
                guide.content.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return guides
    }
    
    var recentGuides: [Guide] {
        Array(filteredGuides.prefix(3))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Content
                ScrollView {
                    VStack(spacing: 24) {
                        if selectedCategory != nil {
                            categoryResultsSection
                        } else if !searchText.isEmpty {
                            searchResultsSection
                        } else {
                            categoriesSection
                            recentGuidesSection
                            quickAccessSection
                        }
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
                    Text("Camping Library")
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
                    CategoryCard(category: category) {
                        selectedCategory = category.name
                        searchText = "" // Clear search when selecting category
                    }
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
                    ExpandableGuideCard(guide: guide)
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
    
    private var searchResultsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Search Results")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                Text("\(filteredGuides.count) found")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if filteredGuides.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "magnifyingglass")
                        .font(.title)
                        .foregroundColor(.secondary)
                    Text("No guides found")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("Try different keywords or browse categories")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(filteredGuides, id: \.id) { guide in
                        ExpandableGuideCard(guide: guide)
                    }
                }
            }
        }
    }
    
    private var categoryResultsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Button(action: {
                    selectedCategory = nil
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.caption)
                        Text("Back to Categories")
                            .font(.subheadline)
                    }
                    .foregroundColor(.blue)
                }
                Spacer()
            }
            
            HStack {
                Text(selectedCategory ?? "Category")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                Text("\(filteredGuides.count) guides")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            LazyVStack(spacing: 12) {
                ForEach(filteredGuides, id: \.id) { guide in
                    ExpandableGuideCard(guide: guide)
                }
            }
        }
    }
}

struct CategoryCard: View {
    let category: Category
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
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
                        .foregroundColor(.primary)
                    Text("\(category.count) guides")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
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

struct ExpandableGuideCard: View {
    let guide: Guide
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded.toggle()
                }
            }) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(guide.title)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .multilineTextAlignment(.leading)
                            .foregroundColor(.primary)
                        Spacer()
                        HStack(spacing: 8) {
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                    .font(.caption)
                                Text(String(format: "%.1f", guide.rating))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
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
                            .foregroundColor(difficultyTextColor(guide.difficulty))
                            .cornerRadius(4)
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(guide.readTime)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            // Expandable content
            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    Divider()
                    
                    Text(guide.content)
                        .font(.body)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
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
    
    private func difficultyTextColor(_ difficulty: String) -> Color {
        switch difficulty {
        case "Beginner": return Color.green
        case "Intermediate": return Color.orange
        case "Advanced": return Color.red
        default: return Color.gray
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