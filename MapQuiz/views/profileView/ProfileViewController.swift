//
//  ProfileViewController.swift
//  MapQuiz
//
//  Created by Rohan Pethiyagoda on 18/1/20.
//  Copyright © 2020 Phosphorous Labs. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    private let BLUR_VIEW_TAG = 500 // arbitrary
    private let nameKey = "ProfileViewController:username"
    private let subheadingText = "You are anonymous. Enter your name below if you want it to appear on the public leaderboard"

    // MARK: Outlets
    @IBOutlet weak var muteSwitch: UISwitch!
    @IBOutlet weak var vibrationSwitch: UISwitch!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var goAnonymousButton: UIButton!
    @IBOutlet weak var subheading: UILabel!
    @IBOutlet weak var pageTitle: UILabel!

    // MARK: Actions
    @IBAction func muteSwitchToggled(_ sender: Any) {
        EffectsBoard.set(muted: muteSwitch.isOn)
    }

    @IBAction func vibrationSwitchToggled(_ sender: Any) {
        EffectsBoard.set(vibrationDisabled: vibrationSwitch.isOn)
    }

    @IBAction func nameUpdated(_ sender: Any) {
        nameField.resignFirstResponder()
        guard nameField.text != savedName() else { return }
        guard let newName = nameField.text, nameField.text?.count ?? 0 != 0 else {
            return showConfirmation(
                title: "Go Anonymous?",
                detail: "Deleting your name will remove you from the global leader board. Are you sure you want to do this?",
                completionHandler: { (action: UIAlertAction) in
                    self.goAnonymous()
                }
            )
        }
        updateUsername(to: newName)
    }

    @IBAction func goAnonymousTapped(_ sender: Any) {
        showConfirmation(
            title: "Go Anonymous?",
            detail: "This will delete your name and remove you from the global leader board. Are you sure you want to do this?",
            completionHandler: { (action: UIAlertAction) in
                self.goAnonymous()
            }
        )
    }


    // MARK: Private Helpers
    private func updateUsername(to newName: String){
        showSpinner()
        RegistrationClient.save(username: newName) { data in
            self.hideSpinner()
            if let savedName = data {
                self.setName(to: savedName)
                self.updateUIForNameState()
                // offer to go to leaderboard now
            }else{
                self.showError(message: "I'm sorry—something went wrong. Maybe try again later?")
                self.updateUIForNameState()
            }
        }
    }

    private func goAnonymous(){
        showSpinner()
        RegistrationClient.save(username: "") { data in
            self.hideSpinner()
            if let savedName = data {
                self.setName(to: savedName)
                self.updateUIForNameState()
            }else{
                self.showError(message: "I'm sorry—something went wrong. Maybe try again later?")
                self.updateUIForNameState()
            }
        }
    }

    private func updateUIForNameState(){
        if let name = savedName() {
            nameField.text = name
            goAnonymousButton.isHidden = false
            animateHideSubheading()
        } else {
            nameField.text = nil
            let placeHolderAttrs = [NSAttributedString.Key.foregroundColor: UIColor.gray]
            let placeHolderText = "Anonymous \(RegistrationClient.defaultName() ?? "")"
            nameField.attributedPlaceholder = NSAttributedString(string: placeHolderText, attributes: placeHolderAttrs)
            goAnonymousButton.isHidden = true
            animateShowSubheading()
        }
    }

    private func animateHideSubheading(){
        UIView.animate(withDuration: 1, animations: {
            self.subheading.text = ""
            self.subheading.alpha = 0
            self.view.layoutIfNeeded()
        })
    }

    private func animateShowSubheading(){
        UIView.animate(withDuration: 1, animations: {
            self.subheading.text = self.subheadingText
            self.subheading.alpha = 1
            self.view.layoutIfNeeded()
        })
    }

    private func setName(to newName: String?){
        let hasValue = (newName?.count ?? 0) > 0
        if(hasValue){
            UserDefaults.standard.set(newName, forKey: nameKey)
        }else{
            UserDefaults.standard.set(nil, forKey: nameKey)
        }
    }

    private func savedName() -> String? {
        return UserDefaults.standard.string(forKey: nameKey)
    }

    private func showSpinner(){
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
    }

    private func hideSpinner(){
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }

    private func showConfirmation(title: String, detail: String, completionHandler: ((UIAlertAction) -> Void)? = nil){
        let alert = UIAlertController(title: title, message: detail, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Yep", style: .destructive, handler: completionHandler))
        alert.addAction(UIAlertAction(title: "Nope", style: .default, handler: { _ in
            self.updateUIForNameState()
        }))
        self.present(alert, animated: true, completion: nil)
    }

    private func showError(message: String){
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    // MARK: Lifecycle Methods
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let blurEffect = UIBlurEffect.init(style: .regular)
        let bluredView = UIVisualEffectView.init(effect: blurEffect)
        bluredView.frame = UIScreen.main.bounds
        bluredView.tag = BLUR_VIEW_TAG
        view.insertSubview(bluredView, at: 0)
        muteSwitch.isOn = EffectsBoard.isMuted()
        vibrationSwitch.isOn = EffectsBoard.vibrationDisabled()
        hideSpinner()
        updateUIForNameState()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.view.viewWithTag(BLUR_VIEW_TAG)?.removeFromSuperview()
    }
}
