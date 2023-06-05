//
//  SceneDelegate.swift
//  WeatherApp
//
//  Created by Evgenii Rebov on 25.05.2023.
//

import UIKit
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        do {
            let storeDirectory = NSPersistentContainer.defaultDirectoryURL()
            let url = storeDirectory.appendingPathComponent("WeatherApp.sqlite")
            let store = try CoreDataWeatherStore(storeURL: url)
            let loader = LocalHitstoryLoader(store: store)
            
            let nc = UINavigationController(rootViewController: WeatherComposer.compose(localLoader: loader,
                                                                                        locationManager: LocationManager()))
            nc.view.backgroundColor = .white
            window?.rootViewController = nc
            window?.makeKeyAndVisible()
        } catch {
            print("!!!", error)
            fatalError()
        }
    }
}
