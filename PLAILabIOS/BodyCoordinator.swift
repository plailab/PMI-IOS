// Coordinator.swift
import AVFoundation
import Vision

class BodyCoordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    var parent: ScannerBodyView
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    init(_ parent: ScannerBodyView) {
        self.parent = parent
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        self.detectBodyPose(in: pixelBuffer)
    }
    
    func detectBodyPose(in pixelBuffer: CVPixelBuffer) {
        let request = VNDetectHumanBodyPose3DRequest{ [weak self] (request, error) in
            guard let self = self,
                  let observations = request.results as? [VNHumanBodyPose3DObservation],
                  !observations.isEmpty else {
                DispatchQueue.main.async {
                    self?.parent.bodyPoseInfo = "No body detected"
                    self?.parent.bodyPoints = []
                }
                return
            }
            
            if let observation = observations.first {
                var points: [CGPoint] = []
                let bodyJoints: [VNHumanBodyPose3DObservation.JointName] = [
                    .topHead, .centerHead, .centerShoulder, .leftShoulder, .rightShoulder,
                    .leftHip, .rightHip, .leftKnee, .rightKnee, .leftAnkle, .rightAnkle,
                    .leftWrist, .rightWrist, .leftElbow, .rightElbow, .root, .spine
                        
                ]
                
//                for joint in bodyJoints {
//                    let recognizedPoint = observation.recognizedPoint(joint)
////                    if let recognizedPoint = try? observation.recognizedPoint(joint),
////                       recognizedPoint.confidence > 0.5 {
//                    points.append(recognizedPoint.localPosition)
//                    //}
//                }
//                
                DispatchQueue.main.async {
                    // Only convert points if we have a valid preview layer
                    if let previewLayer = self.previewLayer {
                        self.parent.bodyPoints = points.map { self.convertVisionPoint($0, previewLayer: previewLayer) }
                        self.parent.bodyPoseInfo = "Body detected with \(points.count) points"
                    }
                }
            }
        }
        
//        request.maximumHandCount = 1
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
        do {
            try handler.perform([request])
        } catch {
            print("Hand pose detection failed: \(error)")
        }
    }
    
    func convertVisionPoint(_ point: CGPoint, previewLayer: AVCaptureVideoPreviewLayer) -> CGPoint {
        // Convert normalized point from Vision (0,0 to 1,1) to AVCaptureVideoPreviewLayer coordinates
        let pointInLayer = previewLayer.layerPointConverted(fromCaptureDevicePoint: point)
        return pointInLayer
    }
}
