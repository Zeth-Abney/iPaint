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
    @Query private var items: [Item]
    @State private var isEditing: Bool = false // Track edit mode status

    var body: some View {
        NavigationSplitView {
            // Sidebar (List of items)
            List {
                ForEach(items) { item in
                    if isEditing {
                        // Editable title in edit mode
                        HStack {
                            TextField("Add title", text: Binding(
                                get: { item.title },
                                set: { newValue in
                                    item.title = newValue
                                }
                            ))
                            .textFieldStyle(PlainTextFieldStyle())
                            .multilineTextAlignment(.leading)

                            Spacer()

                            // Delete button for each item
                            Button(role: .destructive) {
                                deleteItem(item)
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    } else {
                        // Non-editable title with navigation link
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
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? "Done" : "Edit") {
                        isEditing.toggle() // Toggle edit mode
                    }
                }
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        } detail: {
            Text("Select an item")
        }
    }

    // Add item to the list
    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
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

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
