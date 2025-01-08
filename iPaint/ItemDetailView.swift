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
                TextField("Add title", text: $item.title)
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
            VStack(spacing: 20) {
                Text("Item Details")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.black)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Title: \(item.title)")
                        .foregroundColor(.black)
                    Text("Timestamp: \(item.timestamp.formatted(date: .abbreviated, time: .shortened))")
                        .foregroundColor(.gray)

                    Text("Details:")
                        .font(.headline)
                        .foregroundColor(.black)

                    TextEditor(text: Binding(
                        get: { item.details ?? "" },
                        set: { newValue in item.details = newValue }
                    ))
                    .frame(height: 100)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(radius: 4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    )
                }
                .padding()
                .background(Color.white)
                .cornerRadius(8)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 10)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
