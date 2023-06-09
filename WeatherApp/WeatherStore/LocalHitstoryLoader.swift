//
//  LocalHitstoryLoader.swift
//  WeatherApp
//
//  Created by Evgenii Rebov on 01.06.2023.
//

import Foundation

class LocalHitstoryLoader: WeatherLoader {
    private let store: WeatherStore
    
    init(store: WeatherStore) {
        self.store = store
    }
    typealias LoadResult = WeatherLoader.Result
    
    func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve {  result in
            DispatchQueue.main.async {
                switch result {
                case let .failure(error):
                    completion(.failure(error))
                    
                case let .success(.some(cache)):
                    completion(.success(cache.toModels()))
                    
                case .success:
                    completion(.success([]))
                }
            }
        }
    }

    typealias SaveResult = Result<Void, Error>

    func save(_ items: [WeatherItem], completion: @escaping (SaveResult) -> Void) {
        backgroundSave(items, completion: { result in
            DispatchQueue.main.async {
                completion(result)
            }
        })
    }
    
    private func backgroundSave(_ items: [WeatherItem], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedWeather { [weak self] deletionResult in
            guard let self = self else { return }
            
            switch deletionResult {
            case .success:
                self.cache(items, with: completion)
                
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    private func cache(_ items: [WeatherItem], with completion: @escaping (SaveResult) -> Void) {
        store.insert(items.toLocal()) { [weak self] insertionResult in
            guard self != nil else { return }
            
            completion(insertionResult)
        }
    }
}

private extension Array where Element == WeatherItem {
    func toLocal() -> [LocalWeatherItem] {
        return map { LocalWeatherItem(city: $0.city, temperature: $0.temperature, unit: $0.unit, date: $0.date) }
    }
}

private extension Array where Element == LocalWeatherItem {
    func toModels() -> [WeatherItem] {
        return map { local in
            let item = WeatherItem(city: local.city, temperature: local.temperature, unit: local.unit, date: local.date)
            item.unit = UnitUserDefaults.value()
            return item
        }
    }
}
