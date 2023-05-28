//
//  RemoteWeatherLoader.swift
//  WeatherApp
//
//  Created by Evgenii Rebov on 25.05.2023.
//

import Foundation

class RemoteWeatherLoader: WeatherLoader {
    private let url: URL
    private let client: HTTPClient
    
    enum NetworkError: Error {
        case invalidData
        case connectivity
        case unexpectedValues
    }
    
    typealias Result = WeatherLoader.Result
    
    init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    func load(completion: @escaping (Result) -> Void) {
        client.get(from: url, completion: { [weak self] result in
            guard self != nil else { return }
            switch result {
            case let .success((data, response)):
                completion(RemoteWeatherLoader.map(data, from: response))
            case .failure:
                completion(.failure(NetworkError.connectivity))
            }
        })
    }
    
    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let item = try RemoteItemMapper.map(data, from: response)
            return .success(item.toModelsArray())
        } catch {
            return .failure(error)
        }
    }
}

private extension RemoteWeatherItem {
     func toModelsArray() -> [WeatherItem] {
         return [WeatherItem(city: city, temperature: temperature, unit: unit, date: date)]
    }
}
