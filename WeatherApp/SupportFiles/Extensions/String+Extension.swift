//
//  String+Extension.swift
//  WeatherApp
//
//  Created by Evgenii Rebov on 29.05.2023.
//

import Foundation

extension String {
    static func localize(_ key: String) -> String {
        return NSLocalizedString(key, comment: "")
    }
}
