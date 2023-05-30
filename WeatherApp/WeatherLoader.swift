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
    
    func requestWithLocation(lat: String, long: String, completion: @escaping (Result) -> Void)
    func requestWith(_ cityName: String, completion: @escaping (Result) -> Void)
}
