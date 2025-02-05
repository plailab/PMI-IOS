import AVFoundation
import Vision
import UIKit

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
        let request = VNDetectHumanBodyPose3DRequest { [weak self] (request, error) in
            guard let self = self,
                  let observations = request.results as? [VNHumanBodyPose3DObservation],
                  !observations.isEmpty else {
                DispatchQueue.main.async {
                    self?.parent.bodyPoseInfo = "No body detected"
                    self?.parent.bodyPoints = []
                }
                return
            }

            
        }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
        do {
            try handler.perform([request])
        } catch {
            print("Body pose detection failed: \(error)")
        }
    }
    
    /// Converts a 3D body joint position to 2D screen coordinates
    func project3DPointToScreen(_ point3D: simd_float3) -> CGPoint {
        let x = CGFloat(point3D.x)
        let y = CGFloat(point3D.y)
        let screenSize = UIScreen.main.bounds.size
        // Normalize: Vision outputs values in world space (-1 to 1), so map it to screen coordinates
        let screenX = (x + 1) / 2 * screenSize.width
        let screenY = (1 - y) / 2 * screenSize.height

        return CGPoint(x: screenX, y: screenY)
    }

    func convertVisionPoint(_ point: CGPoint, previewLayer: AVCaptureVideoPreviewLayer) -> CGPoint {
        return previewLayer.layerPointConverted(fromCaptureDevicePoint: point)
    }
}
