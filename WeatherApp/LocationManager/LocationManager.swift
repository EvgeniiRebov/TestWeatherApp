//
//  LocationManager.swift
//  WeatherApp
//
//  Created by Evgenii Rebov on 30.05.2023.
//

import CoreLocation

protocol LocationActions {
    func beginUpdatingLocation(handler: @escaping ((Error?) -> Void))
    var didReceiveLocation: ((CLLocation?) -> Void)? { get set }
}

class LocationManager: NSObject, LocationActions, CLLocationManagerDelegate {
    enum StatusError: Error, LocalizedError {
        case denied
        case restricted
        case common
        
        var errorDescription: String? {
            switch self {
            case .denied:
                return String.localize("Location.Error.Denied")
            case .restricted:
                return String.localize("Location.Error.Restricted")
            case .common:
                return String.localize("Location.Error.Common")
            }
        }
    }
                                            
    private var locationProvider: MainCLLocationManager
        
    var didReceiveLocation: ((CLLocation?) -> Void)?
    
    init(_ locationProvider: MainCLLocationManager = MainCLLocationManager()) {
        self.locationProvider = locationProvider
        super.init()
        self.locationProvider.delegate = self
        self.locationProvider.requestWhenInUseAuthorization()
    }

    func beginUpdatingLocation(handler: @escaping ((Error?) -> Void)) {
        DispatchQueue.global().async {
            var error: Error?
            if self.locationProvider.isLocationServicesEnabled() {
                switch self.locationProvider.authorizationStatus {
                case .authorizedWhenInUse, .authorizedAlways:
                    self.locationProvider.startUpdatingLocation()
                case .notDetermined:
                    self.locationProvider.requestWhenInUseAuthorization()
                case .denied:
                    error = StatusError.denied
                case .restricted:
                    error = StatusError.restricted
                @unknown default:
                    error = StatusError.common
                }
            } else {
                error = StatusError.common
            }
            DispatchQueue.main.async {
                handler(error)
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        DispatchQueue.main.async { [weak self] in
            self?.didReceiveLocation?(locations.first)
        }
    }
}
