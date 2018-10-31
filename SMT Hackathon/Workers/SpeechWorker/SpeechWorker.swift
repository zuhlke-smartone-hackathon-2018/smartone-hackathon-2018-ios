//
//  SpeechWorker.swift
//  SMT Hackathon
//
//  Created by Kevin Lo on 20/10/2018.
//  Copyright © 2018 Zuhlke. All rights reserved.
//

import Foundation

final class SpeechWorker: SpeechWorkerProtocol {
    
    private let subscription: String

    private let region: String

    init() {
        self.subscription = AzureService.apiKey
        self.region = AzureService.region
    }

    func recognizeSpeech(completionHandler: @escaping (String?, SpeechRecognitionError?) -> Void) {
        DispatchQueue.global(qos: .userInteractive).async {
            guard let speechConfig = SPXSpeechConfiguration(subscription: self.subscription, region: self.region),
                let recognizer = SPXSpeechRecognizer(speechConfig) else {
                    return
            }
            recognizer.recognizeOnceAsync { result in
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

}
