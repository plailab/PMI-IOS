//
//  GameView.swift
//  PLAILabIOS
//
//  Created by Jack Wei on 2/23/25.
//

import SwiftUI

struct GameView: View {
    @ObservedObject var poseEstimator: PoseEstimator
    var size: CGSize
    let exercise: String

    var body: some View {
        switch exercise {
        case "ShoulderRaise":
            ShoulderRaiseGameView(poseEstimator: poseEstimator, size: size)
        default:
            ShoulderRaiseGameView(poseEstimator: poseEstimator, size: size)
        }

    }

}
