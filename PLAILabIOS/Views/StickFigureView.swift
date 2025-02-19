import SwiftUI

struct StickFigureView: View {
    @ObservedObject var poseEstimator: PoseEstimator
    var size: CGSize
    var body: some View {
        if poseEstimator.bodyParts.isEmpty == false {
            ZStack {
                // For showing a single coordinate point with proper formatting
                
                // Even though the information is inversed, the position
                
                // Everything is normalized by percent so if you are in half of the x and half of the y, it will be (.5,.5)
                // Important notes, because everything is scaled to be 1,1 at the top left
                // even though the screen is 1080 x 1920
                
                // Notes for points
                // Applicable to Front Camera (selfie camera)
                // Top right of screen is (0,1)
                // Top left of screen is (1,1)
                // Bottom right of screen is (0,0)
                // Bottom left os screen is (1,0)
                // Right leg
                
                // If it doesn't see a body part, it assumes that the point is (0,1) (being at the top right of the screen)
                
                Text(String(format: "(%.2f, %.2f, %.2f, %.2f, %.2f, %.2f)",
                            poseEstimator.bodyParts[.rightAnkle]?.x ?? 0,
                            poseEstimator.bodyParts[.rightAnkle]?.y ?? 0,
                     poseEstimator.bodyParts[.rightKnee]?.x ?? 0,
                     poseEstimator.bodyParts[.rightKnee]?.y ?? 0,
                     poseEstimator.bodyParts[.rightHip]?.x ?? 0,
                     poseEstimator.bodyParts[.rightHip]?.y ?? 0))
                    .foregroundColor(.white)
                    .background(Color.black.opacity(0.7))
                    .padding(4)
                    .cornerRadius(4)
                
                
                // Right leg
                if (poseEstimator.bodyParts[.rightAnkle]?.x ?? 0 ) != 0
                && (poseEstimator.bodyParts[.rightKnee]?.x ?? 0 )  != 0
                && (poseEstimator.bodyParts[.rightHip]?.x ?? 0 )  != 0
                {
                    Stick(points: [poseEstimator.bodyParts[.rightAnkle]!.location, poseEstimator.bodyParts[.rightKnee]!.location, poseEstimator.bodyParts[.rightHip]!.location,
                    poseEstimator.bodyParts[.root]!.location], size: size)
                        .stroke(lineWidth: 5.0)
                        .fill(Color.green)
            
                }
                
                // Left leg
                if (poseEstimator.bodyParts[.leftAnkle]?.x ?? 0 )  != 0
                    && (poseEstimator.bodyParts[.leftHip]?.x ?? 0 ) != 0
                    && (poseEstimator.bodyParts[.rightKnee]?.x ?? 0 ) != 0

                {
                    Stick(points: [poseEstimator.bodyParts[.leftAnkle]!.location, poseEstimator.bodyParts[.leftKnee]!.location, poseEstimator.bodyParts[.leftHip]!.location,
                                   poseEstimator.bodyParts[.root]!.location], size: size)
                        .stroke(lineWidth: 5.0)
                        .fill(Color.green)
                }
         
                // Right arm
                if (poseEstimator.bodyParts[.rightWrist]?.x ?? 0 )  != 0
                    && (poseEstimator.bodyParts[.rightElbow]?.x ?? 0 ) != 0
                    && (poseEstimator.bodyParts[.neck]?.x ?? 0 )  != 0
                {
                    Stick(points: [poseEstimator.bodyParts[.rightWrist]!.location, poseEstimator.bodyParts[.rightElbow]!.location, poseEstimator.bodyParts[.rightShoulder]!.location, poseEstimator.bodyParts[.neck]!.location], size: size)
                        .stroke(lineWidth: 5.0)
                        .fill(Color.green)
                }
              
                // Left arm
                if (poseEstimator.bodyParts[.leftWrist]?.x ?? 0 ) != 0
                    && (poseEstimator.bodyParts[.leftElbow]?.x ?? 0 ) != 0
                    && (poseEstimator.bodyParts[.neck]?.x ?? 0 ) != 0
                {
                    Stick(points: [poseEstimator.bodyParts[.leftWrist]!.location, poseEstimator.bodyParts[.leftElbow]!.location, poseEstimator.bodyParts[.leftShoulder]!.location, poseEstimator.bodyParts[.neck]!.location], size: size)
                        .stroke(lineWidth: 5.0)
                        .fill(Color.green)
                }
                
                // Root to nose
                if (poseEstimator.bodyParts[.root]?.x ?? 0 ) != 0
                    && (poseEstimator.bodyParts[.neck]?.x ?? 0 ) != 0
                    && (poseEstimator.bodyParts[.nose]?.x ?? 0 ) != 0
                {
                    
                    Stick(points: [poseEstimator.bodyParts[.root]!.location,
                                   poseEstimator.bodyParts[.neck]!.location,  poseEstimator.bodyParts[.nose]!.location], size: size)
                        .stroke(lineWidth: 5.0)
                        .fill(Color.green)
                }
               

                }
            }
        }
}

