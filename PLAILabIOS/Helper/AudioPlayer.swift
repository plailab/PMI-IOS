//
//  AudioPlayer.swift
//  PLAILabIOS
//
//  Created by Jack Wei on 4/13/25.
//
import AVFoundation

struct AudioPlayer {
    static var player: AVAudioPlayer?

    static func playScore() {
        guard let path = Bundle.main.path(forResource: "score", ofType: "mp3") else { return }
        let url = URL(fileURLWithPath: path)

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch {
            print("Playback failed: \(error.localizedDescription)")
        }
    }
}
