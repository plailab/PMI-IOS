import Foundation
import AVFoundation
import Vision
import Combine

class PoseEstimator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, ObservableObject {
    
    let sequenceHandler = VNSequenceRequestHandler()
    @Published var bodyParts = [VNHumanBodyPoseObservation.JointName : VNRecognizedPoint]()
    var subscriptions = Set<AnyCancellable>()
    private var currentExercise: String // selected exercise by user

    
    // generalizes all of this for each method
    @Published var isGoodPosture = true
    @Published var exerciseCount = 0
    @Published var wasInBottomPosition = false
    
    
    init(selectedExercise: String) {
        self.currentExercise = selectedExercise
        
        super.init()
        $bodyParts
            .dropFirst()
            .sink { [weak self] bodyParts in // Learn more about weak self
                guard let self = self else { return }
                switch self.currentExercise {
                    case "Shoulder Raises":
                        self.countShoulderRaises(bodyParts: bodyParts)
                    case "Squats":
                        self.countSquats(bodyParts: bodyParts)
                    case "Knee Extensions (No)":
                        self.countKneeExtensions(bodyParts: bodyParts)
                    case "Raise Them Knees (No)":
                        self.countKneeRaises(bodyParts: bodyParts)
                    default:
                        self.countShoulderRaises(bodyParts: bodyParts) // fallback to default
                }
            }
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
              self.wasInBottomPosition = true
          }
          if self.wasInBottomPosition && leftWrist.y > leftElbow.y && leftElbow.y > leftShoulder.y && rightWrist.y > rightElbow.y && rightElbow.y > rightShoulder.y {
              self.exerciseCount += 1
              self.wasInBottomPosition = false
          }
      }
      
      
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
          if angleDiffDegrees > 150 && self.wasInBottomPosition {
              self.exerciseCount += 1
              self.wasInBottomPosition = false
          }
          
          let hipHeight = rightHip.y
          let kneeHeight = rightKnee.y
          if hipHeight < kneeHeight {
              self.wasInBottomPosition = true
          }
          

          let kneeDistance = rightKnee.distance(to: leftKnee)
          let ankleDistance = rightAnkle.distance(to: leftAnkle)
          
          if ankleDistance > kneeDistance {
              self.isGoodPosture = false
          } else {
              self.isGoodPosture = true
          }
          
      }
    private func countKneeExtensions(bodyParts: [VNHumanBodyPoseObservation.JointName : VNRecognizedPoint]) {
     
        
    }
    
    private func countKneeRaises(bodyParts: [VNHumanBodyPoseObservation.JointName : VNRecognizedPoint]) {
    }

  }
    
   

