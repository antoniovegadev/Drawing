//
//  ContentView.swift
//  Drawing
//
//  Created by Antonio Vega on 4/30/21.
//

import SwiftUI

struct Checkerboard: Shape {
    let rows: Int
    let columns: Int

    func path(in rect: CGRect) -> Path {
        var path = Path()

        // figure out how big each row/column needs to be
        let rowSize = rect.height / CGFloat(rows)
        let columnSize = rect.width / CGFloat(columns)

        // loop over all rows and columns, making alternating squares colored
        for row in 0 ..< rows {
            for column in 0 ..< columns {
                if (row + column).isMultiple(of: 2) {
                    // this square should be colored; add a rectangle here
                    let startX = columnSize * CGFloat(column)
                    let startY = rowSize * CGFloat(row)

                    let rect = CGRect(x: startX, y: startY, width: columnSize, height: rowSize)
                    path.addRect(rect)
                }
            }
        }

        return path
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))

        return path
    }
}

struct RainDrop: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addQuadCurve(to: CGPoint(x: rect.midX, y: rect.maxY), control: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addQuadCurve(to: CGPoint(x: rect.midX, y: rect.minY), control: CGPoint(x: rect.minX, y: rect.maxY))
        
        return path
    }
}


struct Arc: InsettableShape {
    var startAngle: Angle
    var endAngle: Angle
    var clockwise: Bool
    var insetAmount: CGFloat = 0

    func path(in rect: CGRect) -> Path {
        let rotationAdjustment = Angle.degrees(90)
        let modifiedStart = startAngle - rotationAdjustment
        let modifiedEnd = endAngle - rotationAdjustment

        var path = Path()
        path.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: rect.width / 2 - insetAmount, startAngle: modifiedStart, endAngle: modifiedEnd, clockwise: !clockwise)

        return path
    }
    
    func inset(by amount: CGFloat) -> some InsettableShape {
        var arc = self
        arc.insetAmount += amount
        return arc
    }
}

//struct Flower: Shape {
//    // How much to move this petal away from the center
//    var petalOffset: Double = -20
//
//    // How wide to make each petal
//    var petalWidth: Double = 100
//
//    func path(in rect: CGRect) -> Path {
//        // The path that will hold all petals
//        var path = Path()
//
//        // Count from 0 up to pi * 2, moving up pi / 8 each time
//        for number in stride(from: 0, to: CGFloat.pi * 2, by: CGFloat.pi / 8) {
//            // rotate the petal by the current value of our loop
//            let rotation = CGAffineTransform(rotationAngle: number)
//
//            // move the petal to be at the center of our view
//            let position = rotation.concatenating(CGAffineTransform(translationX: rect.width / 2, y: rect.height / 2))
//
//            // create a path for this petal using our properties plus a fixed Y and height
//            let originalPetal = Path(ellipseIn: CGRect(x: CGFloat(petalOffset), y: 0, width: CGFloat(petalWidth), height: rect.width / 2))
//
//            // apply our rotation/position transformation to the petal
//            let rotatedPetal = originalPetal.applying(position)
//
//            // add it to our main path
//            path.addPath(rotatedPetal)
//        }
//
//        // now send the main path back
//        return path
//    }
//}

struct Arrow: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY * 0.5))
        path.addLine(to: CGPoint(x: rect.midX * 0.5, y: rect.maxY * 0.5))
        path.addLine(to: CGPoint(x: rect.midX * 0.5, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX * 1.5, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX * 1.5, y: rect.maxY * 0.5))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY * 0.5))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY * 0.5))
        
        return path
    }
}

struct ColorCyclingCircle: View {
    var amount = 0.0
    var steps = 100

    var body: some View {
        ZStack {
            ForEach(0..<steps) { value in
                Rectangle()
                    .inset(by: CGFloat(value))
//                    .strokeBorder(self.color(for: value, brightness: 1), lineWidth: 2)
                    .strokeBorder(LinearGradient(gradient: Gradient(colors: [
                        self.color(for: value, brightness: 1),
                        self.color(for: value, brightness: 0.5)
                    ]), startPoint: .top, endPoint: .bottom), lineWidth: 2)
            }
        }
        .drawingGroup()
    }

    func color(for value: Int, brightness: Double) -> Color {
        var targetHue = Double(value) / Double(self.steps) + self.amount

        if targetHue > 1 {
            targetHue -= 1
        }

        return Color(hue: targetHue, saturation: 1, brightness: brightness)
    }
}

struct ContentView: View {
    @State private var dash: CGFloat = 20
    @State private var width: CGFloat = 5
    @State private var colorCycle = 0.0
    @State private var dashPhase: CGFloat = 40
    @State private var rotationAmount: Double = 0



    var body: some View {
        VStack {
            Stepper("Border Size", onIncrement: {
                withAnimation(Animation.easeOut) {
                    width *= 2
                    dash *= 2
                    rotationAmount += 90
                }
                withAnimation(Animation.linear(duration: 2.75).repeatForever(autoreverses: false)) {
                    dashPhase += (dash*2)
                }
            }, onDecrement: {
                withAnimation {
                    width /= 2
                    dash /= 2
                    rotationAmount -= 90
                }
                withAnimation(Animation.linear(duration: 2.75).repeatForever(autoreverses: false)) {
                    dashPhase += (dash*2)
                }
            })
            .padding()
            
            Spacer()
            
            Arrow()
                .stroke(Color.secondary, style: StrokeStyle(lineWidth: width, lineCap: .round, dash: [dash], dashPhase: dashPhase))
                .frame(width: 100, height: 200)
                .rotationEffect(.degrees(rotationAmount))
            
            Spacer()
            
        }
        .onAppear {
            withAnimation(Animation.linear(duration: 2.75).repeatForever(autoreverses: false)) {
                dashPhase += (dash*2)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
