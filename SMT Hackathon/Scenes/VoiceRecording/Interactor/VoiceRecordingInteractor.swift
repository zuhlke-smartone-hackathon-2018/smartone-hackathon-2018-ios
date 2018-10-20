//
//  VoiceRecordingInteractor.swift
//  SMT Hackathon
//
//  Created by Kevin Lo on 20/10/2018.
//  Copyright © 2018 Zuhlke. All rights reserved.
//

import Foundation

class VoiceRecordingInteractor: VoiceRecordingInteractorProtocol {

    var presenter: VoiceRecordingPresenterProtocol?

    var speechWorker: SpeechWorkerProtocol?

    var chatWorker: ChatWorkerProtocol?

    func record() {
        self.presenter?.presentIsRecording(true)
        self.speechWorker?.recognizeSpeech { (text: String?, error: SpeechRecognitionError?) in
            if let text = text {
                self.chatWorker?.sendMessage(text) { chatError in
                    if let chatError = chatError {
                        self.presenter?.presentError(chatError.localizedDescription)
                    }
                }
                self.presenter?.presentText(text)
            } else if let errorMessage = error?.errorReason {
                self.presenter?.presentError(errorMessage)
            }
            self.presenter?.presentIsRecording(false)
        }
    }

}
