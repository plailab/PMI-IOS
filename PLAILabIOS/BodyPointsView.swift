// HandPointsView.swift
import SwiftUI

struct BodyPointsView: View {
    let bodyPoints: [CGPoint]
    
    var body: some View {
        ForEach(bodyPoints, id: \.self) { point in
            Circle()
                .fill(.red)
                .frame(width: 15)
                .position(x: point.x, y: point.y)
        }
    }
}
