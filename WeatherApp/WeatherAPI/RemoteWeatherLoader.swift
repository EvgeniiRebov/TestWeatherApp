//
//  RemoteWeatherLoader.swift
//  WeatherApp
//
//  Created by Evgenii Rebov on 25.05.2023.
//

import Foundation

class RemoteWeatherLoader: RemoteLoader {
    private let client: HTTPClient
    
    enum NetworkError: Error {
        case invalidData
        case connectivity
        case unexpectedValues
    }
    
    typealias Result = RemoteLoader.Result
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func load(url: URL, completion: @escaping (Result) -> Void) {
        client.get(from: url, completion: { [weak self] result in
            guard let self = self else { return }
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
            return .success(item.toModel())
        } catch {
            return .failure(error)
        }
    }
}

private extension RemoteWeatherItem {
     func toModel() -> WeatherItem {
         return WeatherItem(city: city, temperature: temperature, unit: unit, date: date)
    }
}
