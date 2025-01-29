//
//  BrushPickerView.swift
//  iPaint
//
//  Created by Zeth Abney on 1/10/25.
//

import SwiftUI
import SwiftData

enum Brush: String, CaseIterable, Codable {
    case pen = "🖋️"
    case pencil = "✏️"
    case bucket = "🪣"
    case eraser = "🤖"
}

struct BrushSettings {
    var color: Color = .black
    var thickness: CGFloat = 2.0
}

struct BrushState {
    var settings: BrushSettings
    var isSelected: Bool
}

// brush tool bar
public struct BrushPickerView: View {
    @State private var brushStates: [Brush: BrushState] = Dictionary(
        uniqueKeysWithValues: Brush.allCases.map {
            ($0, BrushState(settings: BrushSettings(), isSelected: false))
        }
    )
    @State private var selectedBrush: Brush = .pen
    @State private var showSettingsFor: Brush? = nil
    
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var hasSetInitialPosition: Bool = false
    
    @Binding var currentColor: Color
    @Binding var currentThickness: CGFloat
    @Binding var currentBrush: Brush
    
    private func GripHandle() -> some View {
        VStack(spacing: 4) {
            ForEach(0..<3) { _ in
                HStack(spacing: 4) {
                    ForEach(0..<2) { _ in
                        Circle()
                            .fill(Color.gray.opacity(0.5))
                            .frame(width: 3, height: 3)
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    private func clampOffset(_ offset: CGSize, in size: CGSize) -> CGSize {
        // Keep at least 40 pixels visible on each edge
        let minVisiblePortion: CGFloat = 40
        
        return CGSize(
            width: min(max(offset.width, -size.width + minVisiblePortion), size.width - minVisiblePortion),
            height: min(max(offset.height, -size.height + minVisiblePortion), size.height - minVisiblePortion)
        )
    }
    
    public var body: some View {
            GeometryReader { geometry in
                ZStack {
                    VStack {
                        Spacer() // This pushes content to bottom
                        
                        ZStack(alignment: .bottom) {
                            // Settings overlays
                            ForEach(Brush.allCases, id: \.self) { brush in
                                if showSettingsFor == brush {
                                    BrushSettingsToolbar(settings: Binding(
                                        get: { brushStates[brush]?.settings ?? BrushSettings() },
                                        set: { newSettings in
                                            var updatedStates = brushStates
                                            updatedStates[brush]?.settings = newSettings
                                            brushStates = updatedStates
                                            
                                            if brush == selectedBrush {
                                                currentColor = newSettings.color
                                                currentThickness = newSettings.thickness
                                            }
                                        }
                                    ))
                                    .offset(y: -70)
                                    .transition(.opacity)
                                }
                            }
                            
                            // Brush toolbar with grips
                            HStack(spacing: 0) {
                                GripHandle()
                                    .padding(.horizontal, 4)
                                
                                HStack(alignment: .center, spacing: 12) {
                                    ForEach(Brush.allCases, id: \.self) { brush in
                                        Button {
                                            if selectedBrush == brush {
                                                showSettingsFor = showSettingsFor == brush ? nil : brush
                                            } else {
                                                selectedBrush = brush
                                                currentBrush = brush
                                                showSettingsFor = nil
                                                if let settings = brushStates[brush]?.settings {
                                                    currentColor = settings.color
                                                    currentThickness = settings.thickness
                                                }
                                            }
                                        } label: {
                                            Text(brush.rawValue)
                                                .font(.title2)
                                                .padding(8)
                                                .background(selectedBrush == brush ? Color.gray.opacity(0.2) : Color.clear)
                                                .cornerRadius(6)
                                        }
                                    }
                                }
                                .padding(.horizontal, 8)
                                
                                GripHandle()
                                    .padding(.horizontal, 4)
                            }
                            .padding(.vertical, 8)
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 2)
                        }
                        .offset(x: clampOffset(offset, in: geometry.size).width,
                               y: clampOffset(offset, in: geometry.size).height)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { gesture in
                                    let newOffset = CGSize(
                                        width: lastOffset.width + gesture.translation.width,
                                        height: lastOffset.height + gesture.translation.height
                                    )
                                    offset = clampOffset(newOffset, in: geometry.size)
                                }
                                .onEnded { _ in
                                    lastOffset = offset
                                }
                        )
                        .simultaneousGesture(
                            TapGesture(count: 2)
                                .onEnded {
                                    withAnimation(.spring()) {
                                        // Reset to original position (bottom center)
                                        offset = .zero
                                        lastOffset = .zero
                                    }
                                }
                        )
                    }
                    .padding(.bottom, 20) // Add some padding from the bottom edge
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .ignoresSafeArea()
        }
    }

// brush settings popover
struct BrushSettingsToolbar: View {
    @Binding var settings: BrushSettings
    
    var body: some View {
        HStack(alignment: .center, spacing: 20) {
            Canvas { context, size in
                let rect = CGRect(x: 10, y: size.height/2 - settings.thickness/2,
                                width: size.width - 20, height: settings.thickness)
                let path = Path(rect)
                context.fill(path, with: .color(settings.color))
            }
            .frame(width: 80, height: 50)
            
            ColorPicker("", selection: $settings.color)
                .frame(width: 40, height: 50)
            
            HStack(spacing: 8) {
                Text("1")
                    .frame(width: 20)
                Slider(value: $settings.thickness, in: 1...10, step: 0.5)
                    .frame(width: 100)
                Text("10")
                    .frame(width: 20)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .shadow(radius: 3)
        )
        .transition(.opacity)
        .animation(.easeInOut, value: settings.thickness)
    }
}

// sim preview
struct BrushPickerPreview: View {
    @State private var previewColor: Color = .black
    @State private var previewThickness: CGFloat = 2.0
    @State private var previewBrush: Brush = .pencil
    
    var body: some View {
        BrushPickerView(currentColor: $previewColor,
                       currentThickness: $previewThickness,
                       currentBrush: $previewBrush)
            .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensure full screen in preview
            .background(Color.gray.opacity(0.1)) // Optional: helps visualize the layout
    }
}

#Preview {
    BrushPickerPreview()
}
