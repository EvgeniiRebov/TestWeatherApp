//
//  DateFormatter+Extension.swift
//  WeatherApp
//
//  Created by Evgenii Rebov on 30.05.2023.
//

import Foundation

extension DateFormatter {
    static func mainFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        return formatter
    }
}
