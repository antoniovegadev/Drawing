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

struct ContentView: View {
    let dash: CGFloat = 20
    let circleDash: CGFloat = 40
    @State private var phase: CGFloat = 0
    @State private var phase2: CGFloat = 0
    @State private var offset: CGFloat = -500.0

    var body: some View {
        ZStack {
            Triangle()
            .stroke(Color.red, style: StrokeStyle(lineWidth: 8, lineCap: .round, lineJoin: .round, dash: [dash, 25], dashPhase: phase))
                .frame(width: 250, height: 250)
            
            Triangle()
            .stroke(Color.purple, style: StrokeStyle(lineWidth: 8, lineCap: .round, lineJoin: .round, dash: [dash, 25], dashPhase: phase2))
                .frame(width: 300, height: 300)
                .offset(y: -10)
            
            RainDrop()
                .fill(LinearGradient(gradient: Gradient(colors: [.white, .blue]), startPoint: .top, endPoint: .bottom))
                .frame(width: 100, height: 100)
                .offset(x: 0, y: offset)
            
        }
        .onAppear {
            withAnimation(Animation.linear(duration: 2.75).repeatForever(autoreverses: false)) {
                phase += (dash+25)*2.0
                phase2 -= (dash+25)*2.0
                offset += 1000.0
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
