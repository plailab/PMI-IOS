import Foundation
import AVFoundation
import Vision
import Combine

// delegate just takes frames from the AVCaptureDevice
class PoseEstimator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, ObservableObject {
    // let can't change
    // but var can :)
    let sequenceHandler = VNSequenceRequestHandler()
    @Published var bodyParts = [VNHumanBodyPoseObservation.JointName : VNRecognizedPoint]() // THIS IS WHERE WE WILL BE ABLE TO DETECT EACH VARIABLE
    var wasInBottomPositionSquat = false
    @Published var squatCount = 0
    @Published var isGoodPosture = true
    
    // Messing around with a shoulder raise
    @Published var shoulderRaiseCount = 0
    @Published var wasInBottomPositionShoulderRaise = false
    @Published var isGoodShoulderRaisePosture = true // this should probably be done using the angle of their elbows
    
    var subscriptions = Set<AnyCancellable>()
    
    override init() {
        super.init()
        $bodyParts
            .dropFirst()
            .sink(receiveValue: { bodyParts in self.countShoulderRaises(bodyParts: bodyParts)})
            .store(in: &subscriptions)
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let humanBodyRequest = VNDetectHumanBodyPoseRequest(completionHandler: detectedBodyPose)
        do {
            try sequenceHandler.perform(
              [humanBodyRequest],
              on: sampleBuffer,
                orientation: .right)
        } catch {
          print(error.localizedDescription)
        }
    }
    func detectedBodyPose(request: VNRequest, error: Error?) {
        guard let bodyPoseResults = request.results as? [VNHumanBodyPoseObservation]
          else { return }
        guard let bodyParts = try? bodyPoseResults.first?.recognizedPoints(.all) else { return }
        DispatchQueue.main.async {
            self.bodyParts = bodyParts
        }
    }
    
    func countShoulderRaises(bodyParts: [VNHumanBodyPoseObservation.JointName : VNRecognizedPoint]) {
        let leftElbow = bodyParts[.leftElbow]!.location
        let rightElbow = bodyParts[.rightElbow]!.location
        let rightShoulder = bodyParts[.rightShoulder]!.location
        let leftShoulder = bodyParts[.leftShoulder]!.location
        let leftWrist = bodyParts[.leftWrist]!.location
        let rightWrist = bodyParts[.rightWrist]!.location
        
        // FOR GOOD FORM
        // The elbow will be the origin and the shoulder will be vector 1 and the wrist will be vector too.
        // It doesn't matter if the elbow moves/origin moves because the other vectors will move proportionately with it
        
        if leftWrist.y < leftShoulder.y && rightWrist.y < rightShoulder.y {
            self.wasInBottomPositionShoulderRaise = true
        }
        if self.wasInBottomPositionShoulderRaise && leftWrist.y > leftElbow.y && leftElbow.y > leftShoulder.y && rightWrist.y > rightElbow.y && rightElbow.y > rightShoulder.y {
            self.shoulderRaiseCount += 1
            self.wasInBottomPositionShoulderRaise = false
        }
        // To track if
    }
    
    // THIS LOOKS LIKE A GOOD START FOR MAKING EXERCISES
    
    func countSquats(bodyParts: [VNHumanBodyPoseObservation.JointName : VNRecognizedPoint]) {
        
        let rightKnee = bodyParts[.rightKnee]!.location
        let leftKnee = bodyParts[.rightKnee]!.location
        let rightHip = bodyParts[.rightHip]!.location
        let rightAnkle = bodyParts[.rightAnkle]!.location
        let leftAnkle = bodyParts[.leftAnkle]!.location
        
        let firstAngle = atan2(rightHip.y - rightKnee.y, rightHip.x - rightKnee.x)
        let secondAngle = atan2(rightAnkle.y - rightKnee.y, rightAnkle.x - rightKnee.x)
        var angleDiffRadians = firstAngle - secondAngle
        while angleDiffRadians < 0 {
                    angleDiffRadians += CGFloat(2 * Double.pi)
                }
        let angleDiffDegrees = Int(angleDiffRadians * 180 / .pi)
        if angleDiffDegrees > 150 && self.wasInBottomPositionSquat {
            self.squatCount += 1
            self.wasInBottomPositionSquat = false
        }
        
        let hipHeight = rightHip.y
        let kneeHeight = rightKnee.y
        if hipHeight < kneeHeight {
            self.wasInBottomPositionSquat = true
        }
        

        let kneeDistance = rightKnee.distance(to: leftKnee)
        let ankleDistance = rightAnkle.distance(to: leftAnkle)
        
        if ankleDistance > kneeDistance {
            self.isGoodPosture = false
        } else {
            self.isGoodPosture = true
        }
        
    }

}
