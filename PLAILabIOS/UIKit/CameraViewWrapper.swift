import Foundation
import SwiftUI
import AVFoundation
import Vision


// WRAPS CAMERA VIEW CONTROLLER
struct CameraViewWrapper: UIViewControllerRepresentable {
    var poseEstimator: PoseEstimator
    func makeUIViewController(context: Context) -> some UIViewController {
        let cvc = CameraViewController()
        cvc.delegate = poseEstimator
        return cvc
    }
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    }
}
