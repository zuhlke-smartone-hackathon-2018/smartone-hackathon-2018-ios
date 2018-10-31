//
//  ChatWorkerProtocols.swift
//  SMT Hackathon
//
//  Created by Kevin Lo on 20/10/2018.
//  Copyright © 2018 Zuhlke. All rights reserved.
//

import Foundation

protocol ChatWorkerProtocol: class {

    var delegate: ChatWorkerDelegate? { get  set }

    func sendMessage(_ text: String, completion: @escaping (Error?) -> Void)

}

protocol ChatWorkerDelegate: class {
    func chatWorker(_ worker: ChatWorkerProtocol, didReceiveMessage: String)
}
