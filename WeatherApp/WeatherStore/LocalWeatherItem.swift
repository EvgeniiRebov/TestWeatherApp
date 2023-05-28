//
//  LocalWeatherItem.swift
//  WeatherApp
//
//  Created by Evgenii Rebov on 28.05.2023.
//

import Foundation

struct LocalWeatherItem: Equatable {
    var city: String
    var temperature: Double
    var unit: String
    var date: Date
}
