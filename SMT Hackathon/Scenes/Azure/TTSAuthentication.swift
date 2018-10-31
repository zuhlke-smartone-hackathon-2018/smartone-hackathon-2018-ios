import Foundation

final class TTSAuthentication {
    static let sharedInstace = TTSAuthentication()
    private static let accessTokenUri = AzureService.authTokenUri
    private let apiKey: String
    private var accessToken: String?
    
    //Access token expires every 10 minutes. Renew it every 9 minutes only.
    private static let refreshTokenDuration: Double = 9 * 60
    
    private init() {
        self.apiKey = AzureService.apiKey
        self.refreshToken()
        defer {
            // renew the token every specified minutes
            DispatchQueue.global().asyncAfter(deadline: .now() + TTSAuthentication.refreshTokenDuration) {
                self.refreshToken()
            }
        }
    }
    
    func getAccessToken(_ callback: @escaping (String) -> ()) {
        if let token = self.accessToken {
            callback(token)
        } else {
            self.refreshToken({ (token: String) in
                callback(token)
            })
        }
    }
    
    private func refreshToken(_ callback: ((String) -> ())? = nil) {
        let httpRequest = TTSHttpRequest()
        httpRequest.submit(withUrl: TTSAuthentication.accessTokenUri,
                              andHeaders: ["Ocp-Apim-Subscription-Key": apiKey]) { [weak self] (data: Data?, response: URLResponse?, error: Error?) in
            guard let data = data, let accessToken = String(data: data, encoding: String.Encoding.utf8) else {
                return
            }
            self?.accessToken = accessToken
            callback?(accessToken)
        }
    }

}
