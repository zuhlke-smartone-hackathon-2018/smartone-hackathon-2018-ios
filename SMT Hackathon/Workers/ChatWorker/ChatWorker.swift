//
//  ChatWorker.swift
//  SMT Hackathon
//
//  Created by Kevin Lo on 20/10/2018.
//  Copyright © 2018 Zuhlke. All rights reserved.
//

import Foundation
import AVFoundation

private let BotServiceSecret = "Gpj9YxxEclo.cwA.eP8.plEZ1adsvuMWkYfr8wsx1gNNVrSWaamc2ongP1Lzncg"

class ChatWorker: ChatWorkerProtocol {

    weak var delegate: ChatWorkerDelegate?

    func sendMessage(_ text: String, completion: @escaping (Error?) -> Void) {
        self.createConversationIfNecessary { succeed in
            guard succeed else {
                return
            }

            self.postMessage(conversationId: self.conversationId ?? "", from: self.user, message: text, completion: { (response: PostActivityResponse?) in
                guard response != nil else {
                    let error = NSError(domain: "PostMessage", code: 100, userInfo: nil)
                    completion(error as Error)
                    return
                }

                DispatchQueue.main.async {
                    self.createTimerIfNecessary()
                }

                completion(nil)
            })
        }
    }

    // MARK: Internal implementation

    private var conversationId: String?

    private let user = UUID().uuidString

    private var getMessageTimer: Timer?

    private var othersMessages: [String] = [] {
        didSet {
            guard self.othersMessages.count > oldValue.count else {
                return
            }
            let oldCount = oldValue.count
            let newMessages = [self.othersMessages.last ?? ""] //self.othersMessages.suffix(from: oldCount)
            self.setEarSepeakerOn()
            let textToVoice = newMessages.joined(separator: ",")
            let utterance = AVSpeechUtterance(string: textToVoice)
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            let synth = AVSpeechSynthesizer()
            synth.speak(utterance)
        }
    }

    private func createConversationIfNecessary(completion: @escaping (Bool) -> Void) {
        guard self.conversationId == nil else {
            completion(true)
            return
        }

        self.postConversation { conversation in
            guard let conversationId = conversation?.conversationId else {
                completion(false)
                return
            }

            self.conversationId = conversationId

            self.refreshMessage(completion: { succeed in
                guard succeed else {
                    completion(false)
                    return
                }
                completion(true)
            })

        }
    }

    private func refreshMessage(completion: @escaping (Bool) -> Void) {
        guard let conversationId = self.conversationId else {
            completion(false)
            return
        }

        self.getMessages(conversationId: conversationId) { activitySet in
            guard let activitySet = activitySet else {
                completion(false)
                return
            }

            self.othersMessages = activitySet.activities.sorted(by: { $0.id < $1.id }).filter { $0.from.id != self.user }.compactMap { $0.text }
        }
    }

    private func createTimerIfNecessary() {
        guard self.getMessageTimer == nil else {
            return
        }
        self.getMessageTimer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true, block: { _ in
            self.refreshMessage(completion: { _ in })
        })
    }

    private func setEarSepeakerOn()
    {
        do {
            try AVAudioSession.sharedInstance().setMode(.spokenAudio)
        } catch _ {
        }
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch _ {
        }
        do {
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
        } catch _ {
        }
    }

}

extension ChatWorker {

    func postConversation(completion: @escaping (Conversation?) -> Void) {
        guard let url = URL(string: "https://directline.botframework.com/v3/directline/conversations") else {
            return completion(nil)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addSecurityHeader(secret: BotServiceSecret)
        let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            guard
                let statusCode = (response as? HTTPURLResponse)?.statusCode,
                statusCode / 100 == 2,
                let data = data,
                let conversation = try? JSONDecoder().decode(Conversation.self, from: data)
                else {
                    NSLog("[Error] Fail to create conversation")
                    completion(nil)
                    return
            }
            completion(conversation)
        }
        dataTask.resume()
    }

    func postMessage(conversationId: String, from: String, message: String, completion: @escaping (PostActivityResponse?) -> Void) {
        guard let url = URL(string: "https://directline.botframework.com/v3/directline/conversations/\(conversationId)/activities") else {
            return completion(nil)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addSecurityHeader(secret: BotServiceSecret)
        request.httpBody = try? JSONEncoder().encode(
            PostActivityRequest(type: "message", from: PostActivityRequest.From(id: self.user), text: message)
        )
        NSLog("[postMessage Request]: \(String(data: request.httpBody!, encoding: .utf8)!)")
        let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            NSLog("[postMessage Response]: \(String(data: data!, encoding: .utf8)!)")
            guard
                let statusCode = (response as? HTTPURLResponse)?.statusCode,
                statusCode / 100 == 2,
                let data = data,
                let response = try? JSONDecoder().decode(PostActivityResponse.self, from: data)
                else {
                    NSLog("[Error] Fail to create activity")
                    completion(nil)
                    return
            }
            completion(response)
        }
        dataTask.resume()
    }

    func getMessages(conversationId: String, completion: @escaping (ActivitySet?) -> Void) {
        let urlText = "https://directline.botframework.com/v3/directline/conversations/\(conversationId)/activities"
        guard let url = URL(string: urlText) else {
            return completion(nil)
        }

        var request = URLRequest(url: url)
        request.addSecurityHeader(secret: BotServiceSecret)
        let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            guard
                let statusCode = (response as? HTTPURLResponse)?.statusCode,
                statusCode / 100 == 2,
                let data = data,
                let response = try? JSONDecoder().decode(ActivitySet.self, from: data)
                else {
                    NSLog("[Error] Fail to get activities")
                    completion(nil)
                    return
            }
            NSLog("[getMessage Response]: \(response.activities.flatMap({ $0.text} ))")
            completion(response)
        }
        dataTask.resume()
    }

}

struct Conversation: Codable {

    let conversationId: String

}

struct PostActivityRequest: Codable {

    let type: String

    let from: From

    let text: String

    struct From: Codable {

        let id: String

    }

}

struct PostActivityResponse: Codable {

    let id: String

}

struct Activity: Codable {

    let id: String

    let type: String

    let timestamp: String

    let text: String?

    let from: From

    struct From: Codable {

        let id: String

    }

}

struct ActivitySet: Codable {

    let activities: [Activity]

}

private extension URLRequest {

    mutating func addSecurityHeader(secret: String) {
        self.setValue("application/json", forHTTPHeaderField: "Content-Type")
        self.setValue("Bearer \(secret)", forHTTPHeaderField: "Authorization")
    }

}
