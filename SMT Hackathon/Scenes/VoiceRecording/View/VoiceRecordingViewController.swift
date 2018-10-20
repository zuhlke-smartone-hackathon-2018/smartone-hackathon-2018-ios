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
            self.spinner?.startAnimating()
        } else {
            self.spinner?.stopAnimating()
        }
    }

    func showResult(with text: String) {
        self.textLabel?.text = text
    }

    func showError(with message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        self.present(alert, animated: true, completion: nil)
    }

    // MARK: Internal implementation

    @IBOutlet private var textLabel: UILabel?

    @IBOutlet private var button: UIButton?

    @IBOutlet private var spinner: UIActivityIndicatorView?

    convenience init() {
        self.init(nibName: "VoiceRecordingViewController", bundle: nil)
    }

    @IBAction private func tapRecord() {
        self.interactor?.record()
    }

}
