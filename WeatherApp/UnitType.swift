//
//  UnitType.swift
//  WeatherApp
//
//  Created by Evgenii Rebov on 31.05.2023.
//

import Foundation

enum UnitType {
    case fahrenheit
    case celsius
    
    var intValue: Int {
        switch self {
        case .fahrenheit:
            return 0
        case .celsius:
            return 1
        }
    }
    
    var short: String {
        switch self {
        case .fahrenheit:
            return "F"
        case .celsius:
            return "C"
        }
    }
    
    init(_ intValue: Int) {
        switch intValue {
        case 0:
            self = .fahrenheit
        case 1:
            self = .celsius
        default:
            self = .fahrenheit
        }
    }
}

enum UnitUserDefaults {
    static private let key = "ApplicationUnitType"
    
    static func setValueIfNeeded(in userDefaults: UserDefaults = .standard) {
        /// Used value instead of integer to pass the check, the first setting of the value
        if userDefaults.value(forKey: key) as? Int == nil {
            setValue(UnitType.fahrenheit.intValue)
        }
    }
    
    static func value(in userDefaults: UserDefaults = .standard) -> UnitType {
        setValueIfNeeded(in: userDefaults)
        let rawValue = userDefaults.integer(forKey: key)
        return UnitType(rawValue)
    }
    
    static func setValue(_ value: Int, userDefaults: UserDefaults = .standard) {
        userDefaults.set(value, forKey: key)
    }
}
