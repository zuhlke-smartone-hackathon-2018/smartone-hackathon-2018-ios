//
//  SpeechWorker.swift
//  SMT Hackathon
//
//  Created by Kevin Lo on 20/10/2018.
//  Copyright © 2018 Zuhlke. All rights reserved.
//

import Foundation

class SpeechWorker: SpeechWorkerProtocol {

    private let subscription = "2dd02f7891dc401e90c5725e45d89848"

    private let region = "eastasia"

    func recognizeSpeech(completionHandler: @escaping (String?, SpeechRecognitionError?) -> Void) {
        guard
            let speechConfig = SPXSpeechConfiguration(subscription: self.subscription, region: self.region),
            let recognizer = SPXSpeechRecognizer(speechConfig)
            else {
                return
        }

        DispatchQueue(label: "background").async {
            let result = recognizer.recognizeOnce()
            DispatchQueue.main.async {
                switch result.reason {
                case .recognizedSpeech, .recognizedIntent:
                    guard let text = result.text else {
                        break
                    }
                    completionHandler(text, nil)
                case .canceled:
                    guard let cancelDetails = SPXCancellationDetails(fromCanceledRecognitionResult: result) else {
                        break
                    }
                    completionHandler(nil, SpeechRecognitionError(errorReason: cancelDetails.errorDetails ?? ""))
                default:
                    guard let noMatchDetails = SPXNoMatchDetails(fromNoMatch: result) else {
                        break
                    }
                    completionHandler(nil, SpeechRecognitionError(errorReason: "No match \(noMatchDetails.reason)"))
                }
            }
        }
    }

}
