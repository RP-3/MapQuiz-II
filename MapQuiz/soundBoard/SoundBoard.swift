//
//  SoundBoard.swift
//  MapQuiz
//
//  Created by Rohan Pethiyagoda on 12/3/19.
//  Copyright © 2019 Phosphorous Labs. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

enum Sound: String {
    case yep = "right"
    case nope = "wrong"
    case skip = "bounce"
    case reveal = "plop"
}

class SoundBoard {

    private static var player: AVAudioPlayer?
    private static let muteKey = "soundboard_muted"
    private static let vibrationKey = "vibration_muted"

    public static func play(_ sound: Sound){
        if(!isMuted()){
            let url = URL(fileURLWithPath: Bundle.main.path(forResource: sound.rawValue, ofType: "wav")!)
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)
                player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.wav.rawValue)
                guard let player = player else { return }
                player.play()
            } catch let error {
                print(error.localizedDescription)
            }
        }

        if(!vibrationDisabled()){
            let generator = UINotificationFeedbackGenerator()
            switch (sound) {
            case .yep: generator.notificationOccurred(.success)
            case .nope: generator.notificationOccurred(.error)
            default: generator.notificationOccurred(.warning)
            }
        }
    }

    public static func isMuted() -> Bool {
        return UserDefaults.standard.bool(forKey: muteKey)
    }

    public static func vibrationDisabled() -> Bool {
        return UserDefaults.standard.bool(forKey: vibrationKey)
    }

    public static func set(muted: Bool) {
        UserDefaults.standard.set(muted, forKey: muteKey)
    }

    public static func set(vibrationDisabled: Bool) {
        UserDefaults.standard.set(vibrationDisabled, forKey: vibrationKey)
    }
}
