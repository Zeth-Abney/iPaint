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

    var body: some View {
        VStack(alignment: .center) {
            TextField("Add title", text: $item.title) // Correct binding syntax
                .font(.headline)
                .bold()
                .padding(.top, 20)
                .frame(maxWidth: .infinity, alignment: .top)
                .multilineTextAlignment(.center)
                .textFieldStyle(PlainTextFieldStyle())
            Spacer()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    print("Info button tapped")
                }) {
                    Image(systemName: "info.circle")
                        .font(.title2) // Adjust icon size
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
