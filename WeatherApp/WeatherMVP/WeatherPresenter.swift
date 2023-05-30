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
    var localLoader: WeatherLoader?
    
    init(remoteLoader: RemoteLoader) {
        self.remoteLoader = remoteLoader
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
        guard let url = URLFactory.urlWithCoordinate(lat: "", lon: "") else {
            view?.showAlert()
            return
        }
        remoteLoader.load(url: url) { [weak self] result in
            guard let self = self else { return }
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
