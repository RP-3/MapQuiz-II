//
//  SoundBoard.swift
//  MapQuiz
//
//  Created by Rohan Pethiyagoda on 12/3/19.
//  Copyright © 2019 Phosphorous Labs. All rights reserved.
//

import Foundation
import AVFoundation

enum Sound: String {
    case yep = "right"
    case nope = "wrong"
    case skip = "bounce"
    case reveal = "plop"
}

class SoundBoard {

    private static var player: AVAudioPlayer?

    public static func play(_ sound: Sound){
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
}
