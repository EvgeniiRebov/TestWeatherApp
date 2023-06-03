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
                self.view?.showAlert()
            }
        })
    }

    func requestWithLocation() {
        locationManager.beginUpdatingLocation { [weak self] error in
            if let error = error {
                self?.view?.showAlert()//add error transition
                print(error.localizedDescription)
            }
        }
        
        locationManager.didReceiveLocation = { [weak self] location in
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
    
    private func loadWithLocation(_ location: CLLocation) {
        guard let url = URLFactory.urlWithCoordinate(lat: String(location.coordinate.latitude),
                                                     lon: String(location.coordinate.longitude)) else {
            view?.showAlert()
            return
        }
        remoteLoader.load(url: url) { result in
            self.handleRemote(result)
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
    
    func saveInLocal(_ history: [WeatherItem]) {
        localLoader.save(history) { [weak self] result in
            switch result {
            case .success():
                break
            case .failure(_):
                self?.view?.showAlert() // показать алерт с дальнейшим вызовом reloadData
            }
        }
    }
    
    private func handleRemote(_ result: RemoteLoader.Result) {
        switch result {
        case let .success(model):
            self.view?.reloadData(model)
        case let .failure(error):
            print(error)
            self.view?.showAlert()
        }
    }
}
