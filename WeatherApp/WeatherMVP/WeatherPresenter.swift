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
    func viewDidLoad() {
        view?.reloadData([WeatherItem(city: "Moscow", temperature: 26, unit: "C", date: "21.04.2023 21:43:14")])

    }

    func requestWithLocation() {
        view?.reloadData(WeatherItem(city: "New-York", temperature: 14, unit: "C", date: "21.04.2023 21:43:14"))
    }
    
    func requestWith(cityName: String) {
    }
}
