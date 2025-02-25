import Foundation
import UIKit
import CoreGraphics

extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        return sqrt(pow(x - point.x, 2) + pow(y - point.y, 2)) // literally just the distance formula
    }
    static func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
    static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    func bounded(to size: CGSize) -> CGPoint {
        return CGPoint(
            x: min(max(x, 0), size.width),
            y: min(max(y, 0), size.height)
        )
    }
    
}
