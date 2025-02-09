import Foundation
import UIKit

extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        return sqrt(pow(x - point.x, 2) + pow(y - point.y, 2)) // literally just the distance formula
    }
}
