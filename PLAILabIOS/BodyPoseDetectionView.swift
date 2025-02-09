// HandPoseDetectionView.swift
import SwiftUI
import AVFoundation
import Vision

struct BodyPoseDetectionView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var bodyPoseInfo: String = "Detecting body poses..."
    @State private var bodyPoints: [CGPoint] = []
    
    var body: some View {
        ZStack(alignment: .bottom) {
            BodyScannerView(bodyPoseInfo: $bodyPoseInfo, bodyPoints: $bodyPoints)
            
            // Draw lines between finger joints and the wrist
            BodyLinesView(bodyPoints: bodyPoints)
            
            // Draw circles for the hand points
            BodyPointsView(bodyPoints: bodyPoints)
            
            VStack { // vertical stack
                // Back button at the top
                HStack { // horizontal stack
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding(.top, 20)
                    }
                    Spacer()
                }.padding([.top, .leading], 20) // leading is left side, trailing is right side
                
                Spacer()
                
                // Hand pose info at the bottom
                Text(bodyPoseInfo)
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.bottom, 50)
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}
