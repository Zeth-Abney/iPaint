//
//  BrushPickerView.swift
//  iPaint
//
//  Created by Zeth Abney on 1/10/25.
//

import SwiftUI
import SwiftData

enum Brush: String, CaseIterable {
    case pen = "🖋️"
    case pencil = "✏️"
    case bucket = "🪣"
    case eraser = "🤖"
}

public struct BrushPickerView: View {
    @State private var selectedBrush: Brush = .pen
    
    public var body: some View {
        HStack {
            Picker("Brush", selection:$selectedBrush) {
                ForEach(Brush.allCases, id: \.self) { brush in
                    Text(brush.rawValue)
                }
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: UIScreen.main.bounds.width - 80)
        }
        .padding()
    }
}

#Preview {
    BrushPickerView()
}
