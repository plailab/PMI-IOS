import Foundation
import SwiftUI

struct Stick: Shape { // lets Stick be drawable
    var points: [CGPoint]
    var size: CGSize
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: points[0]) // MAKES YOU START AT POINT[0]
        for point in points { // DRAWS THE LINES
            path.addLine(to: point)
        }
        // PHOTO WAS INFERSED, SO IT FIXES IT
        return path.applying(CGAffineTransform.identity.scaledBy(x: size.width, y: size.height))
            .applying(CGAffineTransform(scaleX: -1, y: -1).translatedBy(x: -size.width, y: -size.height))
    }
}



