import SwiftUI
import SDWebImageSwiftUI

struct GameView: View {
    @ObservedObject var poseEstimator: PoseEstimator
    var size: CGSize
    let exercise: String

    private var gifName: String {
        switch exercise {
        case "Shoulder Raises": return "ShoulderRaises"
        case "Leg Raises": return "LegRaises"
        case "Cross Body Reach": return "CrossbodyReach"
        default: return "ShoulderRaises"
        }
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // The main exercise game view
            Group {
                switch exercise {
                case "Shoulder Raises":
                    ShoulderRaiseGameView(poseEstimator: poseEstimator, size: size)
                case "Leg Raises":
                    LegRaiseGameView(poseEstimator: poseEstimator, size: size)
                case "Cross Body Reach":
                    CrossBodyReachGameView(poseEstimator: poseEstimator, size: size)
                default:
                    ShoulderRaiseGameView(poseEstimator: poseEstimator, size: size)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.opacity(0.001)) // ensure it takes full space

            // 🔹 Animated GIF pinned to top-right
            if let path = Bundle.main.path(forResource: gifName, ofType: "gif") {
                let url = URL(fileURLWithPath: path)
                WebImage(url: url)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 140, height: 140)
                    .padding(.top, 40)
                    .padding(.trailing, 16)
                    .zIndex(1) // ensure it stays on top
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        .ignoresSafeArea(edges: .top) // if you want it at screen corner, above safe area
    }
}
