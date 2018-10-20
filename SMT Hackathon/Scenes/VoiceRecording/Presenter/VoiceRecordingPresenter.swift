//
//  VoiceRecordingPresenter.swift
//  SMT Hackathon
//
//  Created by Kevin Lo on 20/10/2018.
//  Copyright © 2018 Zuhlke. All rights reserved.
//

import Foundation

class VoiceRecordingPresenter: VoiceRecordingPresenterProtocol {

    weak var view: VoiceRecordingViewProtocol?

    func presentIsRecording(_ isRecording: Bool) {
        self.view?.showIsRecording(isRecording)
    }

    func presentText(_ text: String) {
        self.view?.showResult(with: text)
    }

    func presentError(_ errorMessage: String) {
        self.view?.showError(with: errorMessage)
    }

}
