//
//  VoiceRecordingProtocols.swift
//  SMT Hackathon
//
//  Created by Kevin Lo on 20/10/2018.
//  Copyright © 2018 Zuhlke. All rights reserved.
//

import Foundation

protocol VoiceRecordingViewProtocol: class {

    var interactor: VoiceRecordingInteractorProtocol? { get set }

    func showIsRecording(_ isRecording: Bool)

    func showResult(with text: String)

    func showError(with message: String)

}

protocol VoiceRecordingInteractorProtocol: class {

    var presenter: VoiceRecordingPresenterProtocol? { get set }

    var speechWorker: SpeechWorkerProtocol? { get set }

    var chatWorker: ChatWorkerProtocol? { get set }

    func record()

}

protocol VoiceRecordingPresenterProtocol: class {

    var view: VoiceRecordingViewProtocol? { get set }

    func presentIsRecording(_ isRecording: Bool)

    func presentText(_ text: String)

    func presentError(_ errorMessage: String)
}
