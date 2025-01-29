//
//  ContentView.swift
//  iPaint
//
//  Created by Zeth Abney on 1/7/25.
//

//
//  ContentView.swift
//  iPaint
//
//  Created by Zeth Abney on 1/7/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme // Add dark mode support
    @Query(sort: \Item.itemIndex, order: .reverse) private var items: [Item]
    @Query private var metadata: [AppMetadata]
    @State private var isEditing: Bool = false // Track edit mode status
    
    // sort menu properties
    @State private var showSortMenu = false
    @State private var sortOrder: SortOrder = .descending
    @State private var sortBy: SortType = .itemIndex
    
    // enums for sorting options
    enum SortOrder {
        case ascending, descending
        
        var systemImage: String {
            switch self {
            case .ascending: return "arrow.up"
            case .descending: return "arrow.down"
            }
        }
    }
    
    enum SortType: String, CaseIterable {
        case itemIndex = "Item #"
        case title = "Title"
        case dateCreated = "Date Created"
        case lastEdited = "Last Edited"
    }

    private func getMetadata() -> AppMetadata {
        if let existing = metadata.first {
            return existing
        }
        let newMetadata = AppMetadata()
        modelContext.insert(newMetadata)
        return newMetadata
    }
    
    // Computed property for sorted items
    private var sortedItems: [Item] {
        var result = items
        switch sortBy {
        case .itemIndex:
            result.sort { sortOrder == .ascending ? $0.itemIndex < $1.itemIndex : $0.itemIndex > $1.itemIndex }
        case .title:
            result.sort { sortOrder == .ascending ? $0.title < $1.title : $0.title > $1.title }
        case .dateCreated:
            result.sort { sortOrder == .ascending ? $0.timestamp < $1.timestamp : $0.timestamp > $1.timestamp }
        case .lastEdited:
            result.sort { sortOrder == .ascending ? $0.lastEdited < $1.lastEdited : $0.lastEdited > $1.lastEdited }
        }
        
        return result
    }
    
    var body: some View {
        NavigationSplitView {
            // Sidebar (List of items)
            List {
                ForEach(sortedItems) { item in
                    if isEditing {
                        HStack {
                            // Add TextField for editing title
                            TextField("Add title", text: Binding(
                                get: { item.title },
                                set: { newValue in
                                    item.title = newValue
                                    item.lastEdited = Date()
                                }
                            ))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.vertical, 4)
                            
                            Spacer()
                            
                            // Keep the delete button
                            Button(role: .destructive) {
                                deleteItem(item)
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(.horizontal, 4)
                    } else {
                        // Non-edit mode remains the same
                        NavigationLink {
                            ItemDetailView(item: item)
                        } label: {
                            Text(item.title.isEmpty ? "Add title" : item.title)
                        }
                    }
                }
                .onDelete(perform: deleteItems) // Still supports swipe-to-delete in non-edit mode
            }
            .toolbar {
                // sort menu
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showSortMenu.toggle()
                    } label: {
                        HStack {
                            Image(systemName: "arrow.up.arrow.down")
                            Image(systemName: sortOrder.systemImage)
                                .font(.system(size: 8))
                                .offset(y: 2)
                        }
                    }
                }
                // edit button
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? "Done" : "Edit") {
                        isEditing.toggle() // Toggle edit mode
                    }
                }
                // add item (+)
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            .overlay(
                Group {
                    if showSortMenu {
                        GeometryReader { geometry in
                            SortMenuView(sortBy: $sortBy, sortOrder: $sortOrder)
                                .position(x: 120, y: 80) // Increased x value to move menu right
                                .transition(.opacity)
                        }
                        .background(
                            Color.black.opacity(0.001)
                                .onTapGesture {
                                    showSortMenu = false
                                }
                        )
                    }
                }
            )
        } detail: {
            Text("Select an item")
        }
    }

    // MARK: Functions
    // Add item to the list
    private func addItem() {
        withAnimation {
            _ = getMetadata()
            let newItem = Item(itemIndex: AppMetadata.lastUsedIndex)
            modelContext.insert(newItem)
        }
    }

    // Delete items in bulk (used for swipe-to-delete in non-edit mode)
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }

    // Delete a specific item (used for delete button in edit mode)
    private func deleteItem(_ item: Item) {
        withAnimation {
            modelContext.delete(item)
        }
    }
}

struct SortMenuView: View {
    @Binding var sortBy: ContentView.SortType
    @Binding var sortOrder: ContentView.SortOrder
    @Environment(\.colorScheme) private var colorScheme // Add dark mode support
    
    private var menuBackgroundColor: Color {
        colorScheme == .dark ? Color(.systemGray6) : .white
    }
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach(ContentView.SortType.allCases, id: \.self) { type in
                Button {
                    if sortBy == type {
                        // Toggle order if same type selected
                        sortOrder = sortOrder == .ascending ? .descending : .ascending
                    } else {
                        sortBy = type
                    }
                } label: {
                    HStack {
                        Text(type.rawValue)
                            .foregroundColor(.primary)
                        Spacer()
                        if sortBy == type {
                            Image(systemName: sortOrder.systemImage)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(sortBy == type ?
                                  (colorScheme == .dark ? Color.white.opacity(0.1) : Color.gray.opacity(0.1)) :
                                  Color.clear)
                    )
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(menuBackgroundColor)
                .shadow(radius: 3)
        )
        .frame(width: 200)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
