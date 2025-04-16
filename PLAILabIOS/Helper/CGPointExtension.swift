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
        print(x, y)
        print("size: ", size.width, size.height)
        return CGPoint(
            x: min(max(x, size.width*0.2), size.width*0.9),
            y: min(max(y, size.height*0.2), size.height*0.9)
        )
    }
}
