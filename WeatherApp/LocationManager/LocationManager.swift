//
//  LocationManager.swift
//  WeatherApp
//
//  Created by Evgenii Rebov on 30.05.2023.
//

import CoreLocation

protocol Location {
    func getCurrentLocation(handler: @escaping ((Error?) -> Void))
    var didUpdateLocation: ((CLLocation) -> Void)? { get set }
}

class LocationManager: NSObject, Location, CLLocationManagerDelegate {
    private enum StatusError: Error {
        case denied
        case restricted
        case common
        
        var localizedDescription: String {
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
                                            
    private let locationManager = CLLocationManager()
    var didUpdateLocation: ((CLLocation) -> Void)?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }

    func getCurrentLocation(handler: @escaping ((Error?) -> Void)) {
        DispatchQueue.global().async {
            var error: Error?
            if CLLocationManager.locationServicesEnabled() {
                switch self.locationManager.authorizationStatus {
                case .authorizedWhenInUse, .authorizedAlways:
                    self.locationManager.startUpdatingLocation()
                case .notDetermined:
                    self.locationManager.requestWhenInUseAuthorization()
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
        guard let location = locations.first else { return }
        didUpdateLocation?(location)
        locationManager.stopUpdatingLocation()
    }
}
