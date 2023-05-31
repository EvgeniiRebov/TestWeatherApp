//
//  WeatherPresenter.swift
//  WeatherApp
//
//  Created by Evgenii Rebov on 29.05.2023.
//

import Foundation
    
protocol PresenterProtocol {
    func viewDidLoad()
    func requestWithLocation()
    func requestWith(cityName: String)
}

class WeatherPresenter: PresenterProtocol {
    weak var view: ViewProtocol?
    let remoteLoader: RemoteLoader
    var locationManager: Location
    var localLoader: WeatherLoader?
    
    init(remoteLoader: RemoteLoader, locationManager: Location) {
        self.remoteLoader = remoteLoader
        self.locationManager = locationManager
    }
    
    func viewDidLoad() {
        localLoader?.load(completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(history):
                self.view?.reloadData(history)
            case let .failure(error):
                print(error)
                self.view?.showAlert()
            }
        })
    }

    func requestWithLocation() {
        locationManager.getCurrentLocation() { [weak self] error in
            if let error = error {
                self?.view?.showAlert()//add error transition
                print(error.localizedDescription)
            }
        }
        
        locationManager.didUpdateLocation = { [weak self] location in
            guard let self = self else { return }
            guard let url = URLFactory.urlWithCoordinate(lat: String(location.coordinate.latitude),
                                                         lon: String(location.coordinate.longitude)) else {
                self.view?.showAlert()
                return
            }
            self.remoteLoader.load(url: url) { result in
                self.handleRemote(result)
            }
        }
    }

    func requestWith(cityName: String) {
        guard let url = URLFactory.urlWithCityName(cityName) else {
            view?.showAlert()
            return
        }
        remoteLoader.load(url: url) { [weak self] result in
            guard let self = self else { return }
            self.handleRemote(result)
        }
    }
    
    private func handleRemote(_ result: RemoteLoader.Result) {
        switch result {
        case let .success(model):
            view?.reloadData(model)
        case let .failure(error):
            print(error)
            self.view?.showAlert()
        }
    }
}
