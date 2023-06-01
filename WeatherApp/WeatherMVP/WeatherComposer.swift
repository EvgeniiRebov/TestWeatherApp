//
//  WeatherComposer.swift
//  WeatherApp
//
//  Created by Evgenii Rebov on 29.05.2023.
//

import UIKit
import CoreData

final class WeatherComposer {
    static func compose() -> UINavigationController {
        UnitUserDefaults.setValueIfNeeded()
        let remoteLoader = RemoteWeatherLoader(client: URLSessionHTTPClient())
        
        let storeDirectory = NSPersistentContainer.defaultDirectoryURL()
        let url = storeDirectory.appendingPathComponent("WeatherApp.sqlite")
        do {
            let loader = try LocalHitstoryLoader(store: CoreDataWeatherStore(storeURL: url))
            
            let presenter = WeatherPresenter(remoteLoader: remoteLoader,
                                             locationManager: LocationManager(),
                                             localLoader: loader)
            let vc = WeatherViewController(presenter: presenter)
            presenter.view = vc
            vc.title = String.localize("Weather.Title")
            let nc = UINavigationController(rootViewController: vc)
            nc.view.backgroundColor = .white
            return nc
        } catch {
            print("!!!", error)
            fatalError()
        }
    }
}
