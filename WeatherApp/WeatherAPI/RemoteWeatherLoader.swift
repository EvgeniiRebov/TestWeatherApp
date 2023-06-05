//
//  RemoteWeatherLoader.swift
//  WeatherApp
//
//  Created by Evgenii Rebov on 25.05.2023.
//

import Foundation

class RemoteWeatherLoader: RemoteLoader {
    private let client: HTTPClient
    private let dateFormatter: DateFormatter
    
    enum NetworkError: Error, LocalizedError {
        case invalidData
        case connectivity
        case unexpectedValues
        
        var errorDescription: String? {
            switch self {
            case .connectivity:
                return String.localize("Network.Error.Connectivity")
            case .unexpectedValues, .invalidData:
                return String.localize("CommonError.Description")
            }
        }
    }
    
    typealias Result = RemoteLoader.Result
    
    init(client: HTTPClient, dateFormatter: DateFormatter = .mainFormatter()) {
        self.client = client
        self.dateFormatter = dateFormatter
    }
    
    func load(url: URL, completion: @escaping (Result) -> Void) {
        self.client.get(from: url, completion: { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case let .success((data, response)):
                    completion(self.map(data, from: response))
                case .failure:
                    completion(.failure(NetworkError.connectivity))
                }
            }
        })
    }
    
    private func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let item = try RemoteItemMapper.map(data, from: response)
            let date = dateFormatter.string(from: Date())
            return .success(item.toModel(date: date))
        } catch {
            return .failure(error)
        }
    }
}

private extension RemoteWeatherItem {
    func toModel(date: String) -> WeatherItem {
        let item = WeatherItem(city: city, temperature: main.temp, unit: UnitUserDefaults.value(), date: date)
        item.unit = UnitUserDefaults.value()
        return item
    }
}
