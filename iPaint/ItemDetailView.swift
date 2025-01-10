//
//  ItemDetailView.swift
//  iPaint
//
//  Created by Zeth Abney on 1/7/25.
//

import SwiftUI
import SwiftData

struct ItemDetailView: View {
    @Bindable var item: Item // Use @Bindable for SwiftData-managed models
    @State private var showPopup: Bool = false // Track popup visibility

    var body: some View {
        ZStack {
            // Main content
            VStack(alignment: .center) {
                TextField("Add title", text: Binding(
                    get: { item.title },
                    set: { newValue in
                        item.title = newValue
                        item.lastEdited = Date() }
                ))
                    .font(.headline)
                    .bold()
                    .padding(.top, 20)
                    .frame(maxWidth: .infinity, alignment: .top)
                    .multilineTextAlignment(.center)
                    .textFieldStyle(PlainTextFieldStyle())

                Spacer()
            }

            // Popup overlay
            if showPopup {
                popupOverlay
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showPopup.toggle() // Toggle popup visibility
                }) {
                    Image(systemName: "info.circle")
                        .font(.title2)
                }
            }
        }
    }

    // MARK: - Popup Overlay
    private var popupOverlay: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    showPopup = false // Dismiss popup
                }

            // Popup content
            VStack(alignment: .center, spacing: 10) {
                Text("Item Details")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.black)
                

                VStack(alignment: .leading, spacing: 10) {
                    Text("Title: \(item.title)")
                        .foregroundColor(.black)
                    
                    Text("Item # \(item.itemIndex)")
                        .foregroundColor(.gray)
                    
                    Text("Created: \(item.timestamp.formatted(date: .abbreviated, time: .shortened))")
                        .foregroundColor(.gray)
                    
                    Text("Laste edited: \(item.lastEdited.formatted(date: .abbreviated, time: .shortened))")
                        .foregroundColor(.gray)
                    
                    Text("Details:")
                        .font(.headline)
                        .foregroundColor(.black)
                    
                    ZStack(alignment: .topLeading) {
                        
                        // Editable TextEditor
                        TextEditor(text: Binding(
                            get: { item.details ?? "" },
                            set: { newValue in
                                item.details = newValue
                                item.lastEdited = Date()
                            }
                        ))
                        .frame(height: 100) // Multiline editing
                        .padding(.top, 8) // Match placeholder spacing
                        .foregroundColor(.black) // User input in black
                        .background(Color.clear) // Ensure transparency
                        
                        // Placeholder text
                        if (item.details ?? "").isEmpty {
                            Text("Add details...")
                                .foregroundColor(.gray) // Placeholder color
                                .padding(.top, 8) // Align with TextEditor content
                                .padding(.leading, 5) // Adjust for left padding
                                .multilineTextAlignment(.center)
                        }
                    }
                }
                .padding() // General padding for content
            }
            .padding(.horizontal, 30)
            .background(Color.white) // Background for popup
            .frame(maxWidth: UIScreen.main.bounds.width - 60)
            .cornerRadius(10)
            .shadow(radius: 10)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
