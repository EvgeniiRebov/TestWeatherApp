//
//  URLFactory.swift
//  WeatherApp
//
//  Created by Evgenii Rebov on 30.05.2023.
//

import Foundation

enum URLFactory {
    private static let key = "872299f35680fe2abfbf46a4154275b5"
    private static let baseUrl = "https://api.openweathermap.org/data/2.5/weather"
    
    private static let commonQuery = [
        URLQueryItem(name: "units", value: "Imperial"),
        URLQueryItem(name: "appid", value: key)
    ]
    
    static func urlWithCityName(_ name: String) -> URL? {
        var url = URLComponents(string: baseUrl)
        url?.queryItems = [
            URLQueryItem(name: "q", value: name)
        ]
        url?.queryItems?.append(contentsOf: commonQuery)
        return url?.url
    }
    
    static func urlWithCoordinate(lat: String, lon: String) -> URL? {
        var url = URLComponents(string: baseUrl)
        url?.queryItems = [
            URLQueryItem(name: "lat", value: lat),
            URLQueryItem(name: "lon", value: lon),
        ]
        url?.queryItems?.append(contentsOf: commonQuery)
        return url?.url
    }
}
