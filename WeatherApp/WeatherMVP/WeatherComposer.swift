//
//  WeatherComposer.swift
//  WeatherApp
//
//  Created by Evgenii Rebov on 29.05.2023.
//

import UIKit
import CoreData

// I think it's better do with reactive programing using MVVM, but I don't have enouth practise with it to make it good and fast, so I chose MVP with delegates and closures.

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
