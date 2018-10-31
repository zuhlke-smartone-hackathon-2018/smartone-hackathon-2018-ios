//
//  VoiceRecordingViewController.swift
//  SMT Hackathon
//
//  Created by Kevin Lo on 20/10/2018.
//  Copyright © 2018 Zuhlke. All rights reserved.
//

import UIKit

class VoiceRecordingViewController: UIViewController, VoiceRecordingViewProtocol {

    var interactor: VoiceRecordingInteractorProtocol?

    func showIsRecording(_ isRecording: Bool) {
        self.button?.isEnabled = !isRecording
        if isRecording {
            self.textLabel.text = "Listening..."
            self.buildingLabel.text = ""
        }         
    }

    func showResult(with text: String) {
        self.textLabel.text = text
    }

    func showBuildingText(_ text: String) {
        self.buildingLabel.text = text
    }

    func showError(with message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        self.present(alert, animated: true, completion: nil)
        self.buildingLabel.text = ""
    }

    // MARK: Internal implementation

    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var buildingLabel: UILabel!

    @IBOutlet private var button: UIButton?

    convenience init() {
        self.init(nibName: "VoiceRecordingViewController", bundle: nil)
    }

    @IBAction private func tapRecord() {
        self.interactor?.record()
    }

}
