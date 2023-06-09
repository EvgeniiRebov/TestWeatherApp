//
//  WeatherLoader.swift
//  WeatherApp
//
//  Created by Evgenii Rebov on 25.05.2023.
//

import Foundation

protocol WeatherLoader {
    typealias Result = Swift.Result<[WeatherItem], Error>
    
    func load(completion: @escaping (Result) -> Void)
}

protocol RemoteLoader {
    typealias Result = Swift.Result<WeatherItem, Error>
    
    func load(url: URL, completion: @escaping (Result) -> Void)
}
