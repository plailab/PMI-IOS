import AVFoundation
import UIKit


// BASICALLY SAYS TO LIVESTREAM THE CAMERA DATA overiding the class defined by UIKIT (called CALayer which is ot meant for streaming)
// JUST OPTIMIZES THIS

final class CameraView: UIView {
    
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }
    var previewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
      }
}
