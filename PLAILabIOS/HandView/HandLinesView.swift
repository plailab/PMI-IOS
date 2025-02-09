// HandLinesView.swift
import SwiftUI

struct HandLinesView: View {
    let handPoints: [CGPoint]
    
    var body: some View {
        Path { path in
            let fingerJoints = [
                [1, 2, 3, 4],    // Thumb joints
                [5, 6, 7, 8],    // Index finger joints
                [9, 10, 11, 12],  // Middle finger joints
                [13, 14, 15, 16], // Ring finger joints
                [17, 18, 19, 20]  // Little finger joints
            ]
            
            if let wristIndex = handPoints.firstIndex(where: { $0 == handPoints.first }) {
                for joints in fingerJoints {
                    guard joints.count > 1 else { continue }
                    
                    if joints[0] < handPoints.count {
                        let firstJoint = handPoints[joints[0]]
                        let wristPoint = handPoints[wristIndex]
                        path.move(to: wristPoint)
                        path.addLine(to: firstJoint)
                    }
                    
                    for i in 0..<(joints.count - 1) {
                        if joints[i] < handPoints.count && joints[i + 1] < handPoints.count {
                            let startPoint = handPoints[joints[i]]
                            let endPoint = handPoints[joints[i + 1]]
                            path.move(to: startPoint)
                            path.addLine(to: endPoint)
                        }
                    }
                }
            }
        }
        .stroke(Color.blue, lineWidth: 3)
    }
}
