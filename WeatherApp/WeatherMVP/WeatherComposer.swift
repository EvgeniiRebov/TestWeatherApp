//
//  WeatherComposer.swift
//  WeatherApp
//
//  Created by Evgenii Rebov on 29.05.2023.
//

import UIKit

final class WeatherComposer {
    static func compose() -> UINavigationController {
        UnitUserDefaults.setValueIfNeeded()
        let remoteLoader = RemoteWeatherLoader(client: URLSessionHTTPClient())
        let presenter = WeatherPresenter(remoteLoader: remoteLoader, locationManager: LocationManager())
        let vc = WeatherViewController(presenter: presenter)
        presenter.view = vc
        vc.title = String.localize("Weather.Title")
        let nc = UINavigationController(rootViewController: vc)
        nc.view.backgroundColor = .white
        return nc
    }
}
