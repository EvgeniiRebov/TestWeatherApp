//
//  WeatherPresenter.swift
//  WeatherApp
//
//  Created by Evgenii Rebov on 29.05.2023.
//

import Foundation
import CoreLocation
    
protocol PresenterProtocol {
    func viewDidLoad()
    func requestWithLocation()
    func requestWith(cityName: String)
    func saveInLocal(_ history: [WeatherItem])
}

class WeatherPresenter: PresenterProtocol {
    weak var view: ViewProtocol?
    let remoteLoader: RemoteLoader
    let localLoader: LocalHitstoryLoader
    var locationManager: LocationActions
    
    init(remoteLoader: RemoteLoader, locationManager: LocationActions, localLoader: LocalHitstoryLoader) {
        self.remoteLoader = remoteLoader
        self.locationManager = locationManager
        self.localLoader = localLoader
    }
    
    func viewDidLoad() {
        localLoader.load(completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(history):
                self.view?.reloadData(history)
            case let .failure(error):
                print(error)
                self.view?.showAlert(with: error)
            }
        })
    }

    func requestWithLocation() {
        locationManager.didReceiveLocation = { [weak self] location in
            guard let self = self else { return }
            self.loadWithLocation(location)
        }
        
        locationManager.beginUpdatingLocation { [weak self] error in
            if let error = error {
                print(error.localizedDescription)
                self?.view?.showAlert(with: error)
            }
        }
    }
    
    private func loadWithLocation(_ location: CLLocation?) {
        guard let location = location,
              let url = URLFactory.url(lat: String(location.coordinate.latitude),
                                                     lon: String(location.coordinate.longitude)) else {
            view?.showAlert(with: RemoteWeatherLoader.NetworkError.unexpectedValues)
            return
        }
        remoteLoader.load(url: url) { result in
            self.handleRemote(result)
        }
    }

    func requestWith(cityName: String) {
        guard let url = URLFactory.url(name: cityName) else {
            view?.showAlert(with: RemoteWeatherLoader.NetworkError.unexpectedValues)
            return
        }
        remoteLoader.load(url: url) { [weak self] result in
            guard let self = self else { return }
            self.handleRemote(result)
        }
    }
    
    func saveInLocal(_ history: [WeatherItem]) {
        localLoader.save(history) { [weak self] result in
            switch result {
            case .success():
                break
            case let .failure(error):
                self?.view?.showAlert(with: error) // сделать после алерта релоад
            }
        }
    }
    
    private func handleRemote(_ result: RemoteLoader.Result) {
        switch result {
        case let .success(model):
            self.view?.reloadData(model)
        case let .failure(error):
            print(error)
            self.view?.showAlert(with: error)
        }
    }
}
