//
//  GoogleAPI.swift
//  insight
//
//  Created by Petar Petrov on 03/06/2021.
//

import Foundation

private enum GoogleAPIStrings {
    static let apiKey = "AIzaSyD5biGZkfEAZU8IkM_H1t7HCv_7s5Qim68"
    static let baseURLString = "https://maps.googleapis.com"
    static let geocodingPath = "/maps/api/geocode/json"
    static let geocodingQueryParameter = "?address=%@&key=%@"
    static let ttsAPIUrl = "https://texttospeech.googleapis.com/v1beta1/text:synthesize"
    static let sttAPIUrl = "https://speech.googleapis.com/v1p1beta1/speech:recognize"
}

enum GoogleAPI {
    static func getGeocode(for address: String,
                           completion: @escaping (Result<GoogleResults<Geocode>, Error>) -> Void) {
        let handler = GoogleHandler.geocode(address)
        NetworkManager.shared.request(handler: handler, completion: completion)
    }
    
    static func postTextToSpeech(_ text: String,
                                 voiceType: VoiceType,
                                 completion: @escaping (Result<Data?, Error>) -> Void) {
        let handler = GoogleHandler.textToSpeech(text, voiceType)
        NetworkManager.shared.request(handler: handler) { (result: Result<TextToSpeech, Error>) -> Void in
            let mappedResult = result.map { Data(base64Encoded: $0.audioContent)}
            completion(mappedResult)
        }
    }
    
    static func postSpeechToText(voiceData: Data,
                                 voiceType: VoiceType,
                                 completion: @escaping (Result<GoogleResults<SpeechRecognition>, Error>) -> Void) {
        let handler = GoogleHandler.speechToText(voiceData, voiceType)
        NetworkManager.shared.request(handler: handler, completion: completion)
    }
}

enum GoogleHandler {
    case geocode(String)
    case textToSpeech(String, VoiceType)
    case speechToText(Data, VoiceType)
}

extension GoogleHandler: RequestHandlable {
    func makeRequest() throws -> URLRequest {
        switch self {
        case .geocode(let address):
            let addr = address.replacingOccurrences(of: " ", with: "+")
            let parameters = String(format: GoogleAPIStrings.geocodingQueryParameter,
                                    addr,
                                    GoogleAPIStrings.apiKey)
            let urlString = [GoogleAPIStrings.baseURLString,
                             GoogleAPIStrings.geocodingPath,
                             parameters]
                .reduce("", { result, component in result + component })
            
            return try URLRequest.makeEncodedRequest(urlString: urlString)
        case .textToSpeech(let text, let voiceType):
            var request = try URLRequest.makeEncodedRequest(urlString: GoogleAPIStrings.ttsAPIUrl)
            request.httpMethod = "POST"
            request.httpBody = buildPostData(text: text, voiceType: voiceType)
            request.addValue(GoogleAPIStrings.apiKey, forHTTPHeaderField: "X-Goog-Api-Key")
            request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            return request
        case .speechToText(let data, let voiceType):
            var request = try URLRequest.makeEncodedRequest(urlString: GoogleAPIStrings.sttAPIUrl)
            request.httpMethod = "POST"
            request.httpBody = buildSpeechToTextPostData(voiceData: data, voiceType: voiceType)
            request.addValue(GoogleAPIStrings.apiKey, forHTTPHeaderField: "X-Goog-Api-Key")
            request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            return request
        }
    }
    
    var decoder: JSONDecoder {
        return JSONDecoder()
    }
}

private extension GoogleHandler {
    func buildSpeechToTextPostData(voiceData: Data, voiceType: VoiceType) -> Data {
        let audioString = voiceData.base64EncodedString()
        
        let params: [String: Any] = [
            "audio": [
                "content": audioString
            ],
            "config": [
                "enableAutomaticPunctuation": true,
                "encoding": "MP3",
                "languageCode": "bg-BG",
                "model": "default",
                "sampleRateHertz": 16000
            ]
        ]

        // Convert the Dictionary to Data
        let data = try! JSONSerialization.data(withJSONObject: params)
        return data
    }
    
    func buildPostData(text: String, voiceType: VoiceType) -> Data {
        
        var voiceParams: [String: Any] = [
            // All available voices here: https://cloud.google.com/text-to-speech/docs/voices
            "languageCode": "bg-BG"
        ]
        
        if voiceType != .undefined {
            voiceParams["name"] = voiceType.rawValue
        }
        
        let params: [String: Any] = [
            "input": [
                "text": text
            ],
            "voice": voiceParams,
            "audioConfig": [
                // All available formats here: https://cloud.google.com/text-to-speech/docs/reference/rest/v1beta1/text/synthesize#audioencoding
                "audioEncoding": "LINEAR16",
                "pitch": 0,
                "speakingRate": 1
            ]
        ]

        // Convert the Dictionary to Data
        let data = try! JSONSerialization.data(withJSONObject: params)
        return data
    }
}

struct TextToSpeech: Decodable {
    let audioContent: String
}

struct SpeechRecognition: Decodable {
    let alternatives: [Alternative]?
    let languageCode: String?
}

extension SpeechRecognition {
    struct Alternative: Decodable {
        let transcript: String
        let confidence: Double
    }
}
