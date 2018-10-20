//
//  SpeechWorkerProtocols.swift
//  SMT Hackathon
//
//  Created by Kevin Lo on 20/10/2018.
//  Copyright © 2018 Zuhlke. All rights reserved.
//

import Foundation

protocol SpeechWorkerProtocol: class {

    func recognizeSpeech(completionHandler: @escaping (String?, SpeechRecognitionError?) -> Void)

}

struct SpeechRecognitionError: Error {

    let errorReason: String

}
