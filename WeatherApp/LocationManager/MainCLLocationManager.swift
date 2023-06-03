//
//  MainLocationManager.swift
//  WeatherApp
//
//  Created by Evgenii Rebov on 03.06.2023.
//

import CoreLocation

class MainCLLocationManager: CLLocationManager {
    func isLocationServicesEnabled() -> Bool {
        return CLLocationManager.locationServicesEnabled()
    }
}
