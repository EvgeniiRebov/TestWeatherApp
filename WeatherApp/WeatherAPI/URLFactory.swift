//
//  URLFactory.swift
//  WeatherApp
//
//  Created by Evgenii Rebov on 30.05.2023.
//

import Foundation

enum URLFactory {
    private static let key = "872299f35680fe2abfbf46a4154275b5"
    static let latName = "lat"
    static let lonName = "lon"
    static let cityName = "q"
    
    private static func commonQuery() -> [URLQueryItem] {
        return [
            URLQueryItem(name: "appid", value: key),
            URLQueryItem(name: "units", value: UnitUserDefaults.value().unitsQuery)
        ]
    }
    
    static func url(baseUrl: String = "https://api.openweathermap.org/data/2.5/weather", name: String) -> URL? {
        var url = URLComponents(string: baseUrl)
        url?.queryItems = [
            URLQueryItem(name: cityName, value: name)
        ]
        url?.queryItems?.append(contentsOf: commonQuery())
        return url?.url
    }
    
    static func url(baseUrl: String = "https://api.openweathermap.org/data/2.5/weather", lat: String, lon: String) -> URL? {
        var url = URLComponents(string: baseUrl)
        url?.queryItems = [
            URLQueryItem(name: latName, value: lat),
            URLQueryItem(name: lonName, value: lon)
        ]
        url?.queryItems?.append(contentsOf: commonQuery())
        return url?.url
    }
}

private extension UnitType {
    var unitsQuery: String {
        switch self {
        case .celsius:
            return "Metric"
        case .fahrenheit:
            return "Imperial"
        }
    }
}
