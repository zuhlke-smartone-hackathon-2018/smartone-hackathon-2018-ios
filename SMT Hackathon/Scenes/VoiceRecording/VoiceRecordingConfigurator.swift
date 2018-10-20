//
//  VoiceRecordingConfigurator.swift
//  SMT Hackathon
//
//  Created by Kevin Lo on 20/10/2018.
//  Copyright © 2018 Zuhlke. All rights reserved.
//

import UIKit

class VoiceRecordingConfigurator {

    class func make() -> UIViewController {
        let view = VoiceRecordingViewController()
        let interactor = VoiceRecordingInteractor()
        let presenter = VoiceRecordingPresenter()
        view.interactor = interactor
        interactor.presenter = presenter
        interactor.speechWorker = SpeechWorker()
        presenter.view = view
        return view
    }

}
