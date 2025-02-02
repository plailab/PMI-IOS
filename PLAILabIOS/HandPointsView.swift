// HandPointsView.swift
import SwiftUI

struct HandPointsView: View {
    let handPoints: [CGPoint]
    
    var body: some View {
        ForEach(handPoints, id: \.self) { point in
            Circle()
                .fill(.red)
                .frame(width: 15)
                .position(x: point.x, y: point.y)
        }
    }
}
