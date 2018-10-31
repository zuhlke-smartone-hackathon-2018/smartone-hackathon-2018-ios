import Foundation

final class TTSHttpRequest: NSObject {

    func submit(withUrl url: String, andHeaders headers: [String: String]? = nil, andBody body: Data? = nil, _ callback: @escaping (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> ()) {
        guard let url = URL(string: url) else { return }
        var request = URLRequest(url: url)

        request.httpMethod = "POST"
        headers?.forEach({ (header: (key: String, value: String)) in
            request.setValue(header.value, forHTTPHeaderField: header.key)
        })
        if let body = body {
            request.httpBody = body
        }

        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
        let task = session.dataTask(with: request) { (data, response, error) in
            callback(data, response, error)
        }

        task.resume()
    }
    
}

extension TTSHttpRequest: URLSessionDelegate {
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.useCredential, nil)
            return
        }
        let credential = URLCredential(trust: serverTrust)
        completionHandler(.useCredential, credential)        
    }
}
