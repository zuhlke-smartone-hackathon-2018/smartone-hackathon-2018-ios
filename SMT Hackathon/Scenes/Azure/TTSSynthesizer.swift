import Foundation

final class TTSSynthesizer {
    
    enum TTSAudioOutputFormat: String {
        case raw8Khz8BitMonoMULaw = "raw-8khz-8bit-mono-mulaw"
        case raw16Khz16BitMonoPcm = "raw-16khz-16bit-mono-pcm"
        case riff8Khz8BitMonoMULaw = "riff-8khz-8bit-mono-mulaw"        
        case riff16Khz16BitMonoPcm = "riff-16khz-16bit-mono-pcm"
    }
    
    enum TTSGender: String {
        case female = "Female"
        case male = "Male"

        func getVoiceName(forLacale locale: String = "en-US") -> String {
            switch self {
            case .female:
                switch locale {
                case "zh-cn":
                    return "Microsoft Server Speech Text to Speech Voice (zh-CN, HuihuiRUS)"
                case "es-es":
                    return "Microsoft Server Speech Text to Speech Voice (es-ES, Laura, Apollo)"
                case "fr-fr":
                    return "Microsoft Server Speech Text to Speech Voice (fr-FR, Julie, Apollo)"
                case "de-de":
                    return "Microsoft Server Speech Text to Speech Voice (de-DE, Hedda)"
                case "en-au":
                    return "Microsoft Server Speech Text to Speech Voice (en-AU, Catherine)"
                case "en-ca":
                    return "Microsoft Server Speech Text to Speech Voice (en-CA, Linda)"
                case "en-gb":
                    return "Microsoft Server Speech Text to Speech Voice (en-GB, Susan, Apollo)"
                default:
                    return "Microsoft Server Speech Text to Speech Voice (en-US, ZiraRUS)"
                }
            default:
                switch locale {
                case "zh-cn":
                    return "Microsoft Server Speech Text to Speech Voice (zh-CN, Kangkang, Apollo)"
                case "it-it":
                    return "Microsoft Server Speech Text to Speech Voice (it-IT, Cosimo, Apollo)"
                case "es-es":
                    return "Microsoft Server Speech Text to Speech Voice (es-ES, Pablo, Apollo)"
                case "fr-fr":
                    return "Microsoft Server Speech Text to Speech Voice (fr-FR, Paul, Apollo)"
                case "de-de":
                    return "Microsoft Server Speech Text to Speech Voice (de-DE, Stefan, Apollo)"
                case "en-in":
                    return "Microsoft Server Speech Text to Speech Voice (en-IN, Ravi, Apollo)"
                case "en-gb":
                    return "Microsoft Server Speech Text to Speech Voice (en-GB, George, Apollo)"
                default:
                    return "Microsoft Server Speech Text to Speech Voice (en-US, BenjaminRUS)"
                }
            }
        }
    }

    private static let ttsServiceUri = AzureService.ttsServiceUri

    private static var apiKey = AzureService.apiKey

    func synthesize(text: String,
                    outputFormat: TTSAudioOutputFormat = .riff16Khz16BitMonoPcm,
                    appId: String = "",
                    clientId: String = "",
                    lang: String = "en-US",
                    gender: TTSGender = .male,
                    callback: @escaping (Data) -> ()) {        
        TTSAuthentication.sharedInstace.getAccessToken { (accessToken: String) in
            let message = "<speak version='1.0' xml:lang='\(lang)'><voice xml:lang='\(lang)' xml:gender='\(gender.rawValue)' name='\(gender.getVoiceName(forLacale: lang))'>\(text)</voice></speak>"
            let encoding = String.Encoding.utf8
            let httpRequest = TTSHttpRequest()
            httpRequest.submit(withUrl: TTSSynthesizer.ttsServiceUri,
                               andHeaders: [
                                    "Content-Type": "application/ssml+xml",
                                    "X-Microsoft-OutputFormat": outputFormat.rawValue,
                                    "Authorization": "Bearer " + accessToken,
                                    "X-Search-AppId": appId,
                                    "X-Search-ClientID": clientId,
                                    "User-Agent": "iOS",
                                    "Accept": "*/*",
                                    "content-length": "\(message.lengthOfBytes(using: encoding))"
                                ],
                               andBody: message.data(using: encoding)) { (data, response, error) in
                                    guard let data = data else { return }
                                    callback(data)
            }        
        }
    }
    
}
