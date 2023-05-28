//
//  WeatherStore.swift
//  WeatherApp
//
//  Created by Evgenii Rebov on 28.05.2023.
//

import Foundation

enum RetrieveCachedWeatherResult {
    case empty
    case found(weather: [LocalWeatherItem])
    case failure(Error)
}

protocol WeatherStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    typealias RetrievalCompletion = (RetrieveCachedWeatherResult) -> Void

    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func deleteCachedWeather(completion: @escaping DeletionCompletion)
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func insert(_ weather: [LocalWeatherItem], completion: @escaping InsertionCompletion)
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func retrieve(completion: @escaping RetrievalCompletion)
}
