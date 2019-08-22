//
//  GoogleCloudOCR.swift
//  GoogleCloudVisionOCRExample
//
//  Created by Paul Oprea on 20/08/2019.
//  Copyright © 2019 Paul Oprea. All rights reserved.
//

import Foundation
import Alamofire

class GoogleCloudOCR {
    private let apiKey = API_KEY
    private var apiURL: URL {
        return URL(string: "https://vision.googleapis.com/v1/images:annotate?key=\(apiKey)")!
    }
    
    func detect(from image: UIImage, completion: @escaping (OCRResult?) -> Void) {
        guard let base64Image = base64EncodeImage(image) else {
            print("Error while base64 encoding image")
            completion(nil)
            return
        }
        callGoogleVisionAPI(with: base64Image, completion: completion)
    }
    
    private func callGoogleVisionAPI(
        with base64EncodedImage: String,
        completion: @escaping (OCRResult?) -> Void) {
        let parameters: Parameters = [
            "requests": [
                [
                    "image": [
                        "content": base64EncodedImage
                    ],
                    "features": [
                        [
                            "type": "TEXT_DETECTION"
                        ]
                    ]
                ]
            ]
        ]
        let headers: HTTPHeaders = [
            "X-Ios-Bundle-Identifier": Bundle.main.bundleIdentifier ?? "",
        ]
        Alamofire.request(
            apiURL,
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default,
            headers: headers)
            .responseJSON { response in
                if response.result.isFailure {
                    completion(nil)
                    return
                }
                //print(response.result.debugDescription)
                guard let _ = response.result.value else {
                    completion(nil)
                    return
                }
                // Decode the JSON data into a `GoogleCloudOCRResponse` object.
                let ocrResponse = try? JSONDecoder().decode(GoogleCloudOCRResponse.self, from: response.data!)  //(GoogleCloudOCRResponse.self, from: data as! Data)
                completion(ocrResponse?.responses[0])
        }
    }
    
    private func base64EncodeImage(_ image: UIImage) -> String? {
        return image.pngData()?.base64EncodedString(options: .endLineWithCarriageReturn)
    }
}
