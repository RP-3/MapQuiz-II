//
//  ProfileViewController.swift
//  MapQuiz
//
//  Created by Rohan Pethiyagoda on 18/1/20.
//  Copyright © 2020 Phosphorous Labs. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    private let BLUR_VIEW_TAG = 500

    // MARK: Outlets
    @IBOutlet weak var muteSwitch: UISwitch!
    @IBOutlet weak var vibrationSwitch: UISwitch!

    // MARK: Actions
    @IBAction func muteSwitchToggled(_ sender: Any) {
        SoundBoard.set(muted: muteSwitch.isOn)
    }
    @IBAction func vibrationSwitchToggled(_ sender: Any) {
        SoundBoard.set(vibrationDisabled: vibrationSwitch.isOn)
    }

    // MARK: Lifecycle Methods
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let blurEffect = UIBlurEffect.init(style: .dark)
        let bluredView = UIVisualEffectView.init(effect: blurEffect)
        bluredView.frame = UIScreen.main.bounds
        bluredView.tag = BLUR_VIEW_TAG
        view.insertSubview(bluredView, at: 0)
        muteSwitch.isOn = SoundBoard.isMuted()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.view.viewWithTag(BLUR_VIEW_TAG)?.removeFromSuperview()
    }
}
