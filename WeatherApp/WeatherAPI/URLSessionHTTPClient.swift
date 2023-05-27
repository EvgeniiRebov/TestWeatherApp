//
//  URLSessionHTTPClient.swift
//  WeatherApp
//
//  Created by Evgenii Rebov on 25.05.2023.
//

import Foundation

class URLSessionHTTPClient: HTTPClient {

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
        session.dataTask(with: url, completionHandler: { data, response, error in
            completion(Result {
                if let error = error {
                    throw error
                } else if let data = data, let response = response as? HTTPURLResponse {
                    return (data, response)
                } else {
                    throw RemoteWeatherLoader.NetworkError.unexpectedValues
                }
            })
        }).resume()
    }
}
