//
//  WeatherComposer.swift
//  WeatherApp
//
//  Created by Evgenii Rebov on 29.05.2023.
//

import UIKit
import CoreData

final class WeatherComposer {
    
    static func compose(remoteLoader: RemoteLoader = RemoteWeatherLoader(client: URLSessionHTTPClient()),
                        localLoader: LocalHitstoryLoader,
                        locationManager: LocationActions) -> WeatherViewController {
        UnitUserDefaults.setValueIfNeeded()
        
        let presenter = WeatherPresenter(remoteLoader: remoteLoader,
                                         locationManager: locationManager,
                                         localLoader: localLoader)
        let vc = WeatherViewController(presenter: presenter)
        presenter.view = vc
        vc.title = String.localize("Weather.Title")
        return vc
    }
} 
