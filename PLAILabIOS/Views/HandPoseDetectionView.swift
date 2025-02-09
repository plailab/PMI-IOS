// HandPoseDetectionView.swift
import SwiftUI
import AVFoundation
import Vision

struct HandPoseDetectionView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var handPoseInfo: String = "Detecting hand poses..."
    @State private var handPoints: [CGPoint] = []
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScannerView(handPoseInfo: $handPoseInfo, handPoints: $handPoints)
            
            // Draw lines between finger joints and the wrist
            HandLinesView(handPoints: handPoints)
            
            // Draw circles for the hand points
            HandPointsView(handPoints: handPoints)
            
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
                Text(handPoseInfo)
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.bottom, 50)
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}
