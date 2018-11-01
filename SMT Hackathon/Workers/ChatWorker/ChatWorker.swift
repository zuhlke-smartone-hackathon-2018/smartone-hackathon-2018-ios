//
//  ChatWorker.swift
//  SMT Hackathon
//
//  Created by Kevin Lo on 20/10/2018.
//  Copyright © 2018 Zuhlke. All rights reserved.
//

import Foundation
import AVFoundation
import SocketRocket

private let BotServiceSecret = "UHk7Q_9H9cs.cwA.lVc.vYP20wKhApiaOAwCa15q4LQLYTx3aJSp458bXAg5Q-4"

final class ChatWorker: NSObject, ChatWorkerProtocol {

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
                completion(nil)
            })
        }
    }

    deinit {
        self.webSocket?.close()
    }

    // MARK: Internal implementation

    private var conversationId: String?

    private var streamUrl: String?

    private lazy var webSocket: SRWebSocket? = {
        guard let streamUrl = self.streamUrl,
            let webSocketUrl = URL(string: streamUrl) else {
                return nil
        }
        let _webSocket = SRWebSocket(url: webSocketUrl)
        _webSocket!.delegate = self
        return _webSocket
    }()

    private let user = UUID().uuidString

    private var getMessageTimer: Timer?

    private var othersMessages: [String] = [] {
        didSet {
            guard oldValue != self.othersMessages,
                let lastMessage = self.othersMessages.last,
                !lastMessage.isEmpty else {
                return
            }            

            DispatchQueue.main.async {
                self.delegate?.chatWorker(self, didReceiveMessage: lastMessage)
                TTSVocalizer.sharedInstance.vocalize(lastMessage)
            }
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
            self.streamUrl = conversation?.streamUrl
            self.webSocket?.open()
            completion(true)
        }
    }

    @available(*, deprecated)
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

            completion(true)
        }
    }

    @available(*, deprecated)
    private func createTimerIfNecessary() {
        guard self.getMessageTimer == nil else {
            return
        }
        self.getMessageTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true, block: { _ in
            self.refreshMessage(completion: { _ in })
        })
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
                    completion(nil)
                    return
            }
            debugPrint("[conversation] stream url:", conversation.streamUrl)
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
        Logger.log(message: "\(String(data: request.httpBody!, encoding: .utf8)!)", event: .debug)
        let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            Logger.log(message: "Response \(String(data: data!, encoding: .utf8)!))", event: .debug)
            guard
                let statusCode = (response as? HTTPURLResponse)?.statusCode,
                statusCode / 100 == 2,
                let data = data,
                let response = try? JSONDecoder().decode(PostActivityResponse.self, from: data)
                else {
                    completion(nil)
                    return
            }
            completion(response)
        }
        dataTask.resume()
    }

    @available(*, deprecated)
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
                    completion(nil)
                    return
            }
            completion(response)
        }
        dataTask.resume()
    }

}

extension ChatWorker: SRWebSocketDelegate {
    func webSocket(_ webSocket: SRWebSocket!, didReceiveMessage message: Any!) {
        guard let data = message as? Data,
            let activitySet = try? JSONDecoder().decode(ActivitySet.self, from: data) else {
            return
        }
        self.othersMessages = activitySet.activities.sorted(by: { $0.id < $1.id }).filter { $0.from.id != self.user }.compactMap { $0.text }
    }

    func webSocket(_ webSocket: SRWebSocket!, didReceivePong pongPayload: Data!) {
        Logger.log(message: "did receive pong", event: .debug)
    }

    func webSocket(_ webSocket: SRWebSocket!, didFailWithError error: Error!) {
        Logger.log(message: "didFailWithError:\(error.localizedDescription)", event: .error)
    }

    func webSocket(_ webSocket: SRWebSocket!, didCloseWithCode code: Int, reason: String!, wasClean: Bool) {
        Logger.log(message: "didCloseWithCode:\(code) reason:\(reason ?? "") wasClean:\(wasClean)", event: .debug)
    }

    func webSocketDidOpen(_ webSocket: SRWebSocket!) {
        Logger.log(message: "webSocketDidOpen", event: .debug)
    }

    func webSocketShouldConvertTextFrame(toString webSocket: SRWebSocket!) -> Bool {
        return false
    }
}

struct Conversation: Codable {

    let conversationId: String
    let streamUrl: String

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
    let watermark: String?

}

private extension URLRequest {

    mutating func addSecurityHeader(secret: String) {
        self.setValue("application/json", forHTTPHeaderField: "Content-Type")
        self.setValue("Bearer \(secret)", forHTTPHeaderField: "Authorization")
    }

}
