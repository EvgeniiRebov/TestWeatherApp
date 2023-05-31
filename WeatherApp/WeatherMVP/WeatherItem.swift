//
//  WeatherItem.swift
//  WeatherApp
//
//  Created by Evgenii Rebov on 25.05.2023.
//

import Foundation

class WeatherItem {
    var city: String
    var temperature: Double
    var unit: String {
        didSet {
            guard oldValue != unit else { return }
            if unit == "F" {
                temperature = (temperature * 9/5) + 32
            } else {
                temperature = (temperature - 32) * 5/9
            }
        }
    }
    
    var date: String
    
    init(city: String, temperature: Double, unit: String, date: String) {
        self.city = city
        self.temperature = temperature
        self.unit = unit
        self.date = date
    }
}

extension WeatherItem: Equatable {
    static func == (lhs: WeatherItem, rhs: WeatherItem) -> Bool {
        return lhs.unit == rhs.unit &&
        lhs.temperature == rhs.temperature &&
        lhs.city == rhs.city &&
        lhs.date == rhs.date
    }
}
