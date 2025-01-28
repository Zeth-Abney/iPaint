//
//  ItemDetailView.swift
//  iPaint
//
//  Created by Zeth Abney on 1/7/25.
//

import SwiftUI
import SwiftData

// MARK: codable lines on canvas
struct Line: Codable {
    var points: [CGPoint]
    var color: Color
    var lineWidth: Double
    var type: Brush
    
    init(points: [CGPoint] = [], color: Color = .red, lineWidth: Double = 1.0, type: Brush = .pen) {
        self.points = points
        self.color = color
        self.lineWidth = lineWidth
        self.type = type
    }
    
    enum CodingKeys: String, CodingKey {
        case points, lineWidth, type
        case colorComponents
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(points, forKey: .points)
        try container.encode(lineWidth, forKey: .lineWidth)
        try container.encode(type, forKey: .type)
        
        // Convert Color to RGB components
        let uiColor = UIColor(color)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let components = [red, green, blue, alpha]
        try container.encode(components, forKey: .colorComponents)
    }
    
    init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            points = try container.decode([CGPoint].self, forKey: .points)
            lineWidth = try container.decode(Double.self, forKey: .lineWidth)
            type = try container.decode(Brush.self, forKey: .type)
            
            let components = try container.decode([CGFloat].self, forKey: .colorComponents)
            color = Color(UIColor(red: components[0],
                                green: components[1],
                                blue: components[2],
                                alpha: components[3]))
        }
}

// MARK: main item view content
struct ItemDetailView: View {
    @Bindable var item: Item
    @State private var showPopup: Bool = false
    @State private var currentLine = Line()
    @State private var lines: [Line] = []
    @State private var currentColor: Color = .black
    @State private var currentThickness: CGFloat = 2.0
    @State private var currentBrush: Brush = .pen
    
    init(item: Item) {
        self.item = item
        
        // Load saved canvas data
        if let canvasData = item.canvasData,
           let decodedLines = try? JSONDecoder().decode([Line].self, from: canvasData) {
            _lines = State(initialValue: decodedLines)
        }
    }
    
    private func saveCanvasData() {
        if let encodedData = try? JSONEncoder().encode(lines) {
            item.canvasData = encodedData
            item.lastEdited = Date()
        }
    }

    private func eraseLines(at point: CGPoint) {
        lines = lines.filter { line in
            if line.type == .eraser {
                return true
            }
            
            let eraserRadius = currentThickness
            return !line.points.contains { linePoint in
                let distance = sqrt(pow(linePoint.x - point.x, 2) + pow(linePoint.y - point.y, 2))
                return distance <= eraserRadius
            }
        }
        // Save after erasing
        saveCanvasData()
    }
    
    // MARK: item view body
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                TextField("Add title", text: Binding(
                    get: { item.title },
                    set: { newValue in
                        item.title = newValue
                        item.lastEdited = Date()
                    }
                ))
                    .font(.headline)
                    .bold()
                    .padding(.top, 20)
                    .frame(maxWidth: .infinity, alignment: .top)
                    .multilineTextAlignment(.center)
                    .textFieldStyle(PlainTextFieldStyle())
                Spacer()
                
                Canvas { context, size in
                    for line in lines {
                        var path = Path()
                        path.addLines(line.points)
                        if line.type == .eraser {
                            continue
                        }
                        context.stroke(path,
                                     with: .color(line.color),
                                     lineWidth: line.lineWidth)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .border(Color.blue)
                .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged({ value in
                        let newPoint = value.location
                        
                        if currentBrush == .eraser {
                            eraseLines(at: newPoint)
                            if currentLine.points.isEmpty {
                                currentLine = Line(points: [],
                                                color: .clear,
                                                lineWidth: currentThickness,
                                                type: .eraser)
                            }
                        } else {
                            if currentLine.points.isEmpty {
                                currentLine = Line(points: [],
                                                color: currentColor,
                                                lineWidth: currentThickness,
                                                type: currentBrush)
                            }
                        }
                        
                        currentLine.points.append(newPoint)
                        
                        if let lastIndex = lines.lastIndex(where: { $0.points == currentLine.points.dropLast() }) {
                            lines.remove(at: lastIndex)
                        }
                        lines.append(currentLine)
                        
                        // Save after each point
                        saveCanvasData()
                    })
                    .onEnded({ value in
                        if currentBrush != .eraser {
                            self.lines.append(currentLine)
                        }
                        self.currentLine = Line()
                        
                        // Save after stroke completion
                        saveCanvasData()
                    })
                )
            
                Spacer()
                BrushPickerView(currentColor: $currentColor,
                              currentThickness: $currentThickness,
                              currentBrush: $currentBrush)
            }
            .padding()

            if showPopup {
                popupOverlay
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showPopup.toggle()
                }) {
                    Image(systemName: "info.circle")
                        .font(.title2)
                }
            }
        }
    }
    
    // MARK: info popup
    private var popupOverlay: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    showPopup = false
                }

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
                    
                    Text("Last edited: \(item.lastEdited.formatted(date: .abbreviated, time: .shortened))")
                        .foregroundColor(.gray)
                    
                    Text("Details:")
                        .font(.headline)
                        .foregroundColor(.black)
                    
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: Binding(
                            get: { item.details ?? "" },
                            set: { newValue in
                                item.details = newValue
                                item.lastEdited = Date()
                            }
                        ))
                        .frame(height: 100)
                        .padding(.top, 8)
                        .foregroundColor(.black)
                        .background(Color.clear)
                        
                        if (item.details ?? "").isEmpty {
                            Text("Add details...")
                                .foregroundColor(.gray)
                                .padding(.top, 8)
                                .padding(.leading, 5)
                                .multilineTextAlignment(.center)
                        }
                    }
                }
                .padding()
            }
            .padding(.horizontal, 30)
            .background(Color.white)
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
