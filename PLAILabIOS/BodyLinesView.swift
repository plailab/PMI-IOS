// HandLinesView.swift
import SwiftUI

struct BodyLinesView: View {
    let bodyPoints: [CGPoint]
    
    var body: some View {
        Path { path in
            let fingerJoints = [
                [1, 2, 3, 4],    // Thumb joints
                [5, 6, 7, 8],    // Index finger joints
                [9, 10, 11, 12],  // Middle finger joints
                [13, 14, 15, 16], // Ring finger joints
                [17, 18, 19, 20]  // Little finger joints
            ]
            
            if let wristIndex = bodyPoints.firstIndex(where: { $0 == bodyPoints.first }) {
                for joints in fingerJoints {
                    guard joints.count > 1 else { continue }
                    
                    if joints[0] < bodyPoints.count {
                        let firstJoint = bodyPoints[joints[0]]
                        let wristPoint = bodyPoints[wristIndex]
                        path.move(to: wristPoint)
                        path.addLine(to: firstJoint)
                    }
                    
                    for i in 0..<(joints.count - 1) {
                        if joints[i] < bodyPoints.count && joints[i + 1] < bodyPoints.count {
                            let startPoint = bodyPoints[joints[i]]
                            let endPoint = bodyPoints[joints[i + 1]]
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
