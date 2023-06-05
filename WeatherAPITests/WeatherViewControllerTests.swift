//
//  WeatherViewControllerTests.swift
//  WeatherApp
//
//  Created by Evgenii Rebov on 05.06.2023.
//

import XCTest
@testable import WeatherApp

class WeatherViewControllerTests: XCTestCase {
    
    func test_viewDidLoad_rendersTableView() {
        let presenter = MockPresenter()
        let model = uniqueWeather(in: "Moscow")
        presenter.history = [model]
        let expectedTopText = model.city + " " + String(Int(model.temperature)) + "°" + model.unit.short
        let expectedBottomText = model.date
        let sut = mackSUT(presenter: presenter)
        
        sut.loadViewIfNeeded()
        
        let cell = sut.tableView.cell(at: 0) as? HistoryCell
        XCTAssertEqual(cell?.topLabel.text, expectedTopText)
        XCTAssertEqual(cell?.bottomLabel.text, expectedBottomText)
    }
    
    func test_viewDidLoad_rendersInfoViewWithModel() {
        let presenter = MockPresenter()
        let history = uniqueWeatherHistory().models
        presenter.history = history
        let sut = mackSUT(presenter: presenter)
        
        sut.loadViewIfNeeded()
        
        let cell = sut.tableView.cell(at: 0) as? HistoryCell
        XCTAssertTrue((cell?.topLabel.text ?? "").contains(history[0].city))
        XCTAssertEqual(sut.infoView.cityLabel.text, history[0].city)
        XCTAssertTrue((sut.infoView.valueLabel.text ?? "").contains(String(Int(history[0].temperature))))
        XCTAssertFalse(sut.infoView.switchView.isHidden)
    }
    
    func test_viewDidLoad_rendersInfoViewAndTableViewWithoutModel() {
        let presenter = MockPresenter()
        presenter.history = []
        let sut = mackSUT(presenter: presenter)
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.tableView.numberOfRows(inSection: 0), 0)
        XCTAssertTrue(sut.infoView.switchView.isHidden)
        XCTAssertNil(sut.infoView.valueLabel.text)
        XCTAssertNil(sut.infoView.cityLabel.text)
    }
    
    func test_changeUnit_inHistoryView_changesUnit() {
        let presenter = MockPresenter()
        let model = uniqueWeather(in: "Moscow")
        presenter.history = [model]
        let sut = mackSUT(presenter: presenter)
        let old = UnitUserDefaults.value()
        let oldTempreture = String(Int(model.temperature))
        
        sut.loadViewIfNeeded()

        XCTAssertTrue(((sut.tableView.cell(at: 0) as? HistoryCell)?.topLabel.text ?? "").contains(oldTempreture))
        XCTAssertTrue((sut.infoView.valueLabel.text ?? "").contains(oldTempreture))
        switch model.unit {
        case .celsius:
            XCTAssertTrue(sut.infoView.measureSwitch.isOn)
            sut.infoView.measureSwitch.setOn(false, animated: false)
        case .fahrenheit:
            XCTAssertFalse(sut.infoView.measureSwitch.isOn)
            sut.infoView.measureSwitch.setOn(true, animated: false)
        }
        sut.infoView.measureSwitch.sendActions(for: .valueChanged)
        
        XCTAssertNotEqual(old, UnitUserDefaults.value())
        XCTAssertFalse(((sut.tableView.cell(at: 0) as? HistoryCell)?.topLabel.text ?? "").contains(oldTempreture))
        XCTAssertFalse((sut.infoView.valueLabel.text ?? "").contains(oldTempreture))
    }
    
    // MARK: - Helpers
    
    func mackSUT(presenter: MockPresenter) -> WeatherViewController {
        let sut = WeatherViewController(presenter: presenter)
        presenter.view = sut
        return sut
    }
    
    class MockPresenter: PresenterProtocol {
        var view: WeatherApp.ViewProtocol?
        var history = [WeatherItem]()
        
        func viewDidLoad() {
            view?.reloadData(history)
        }
        
        func requestWithLocation() {
            
        }
        
        func requestWith(cityName: String) {
            
        }
        
        func saveInLocal(_ history: [WeatherApp.WeatherItem]) {
            
        }
    }
}

private extension UITableView {
    func cell(at row: Int) -> UITableViewCell? {
        dataSource?.tableView(self, cellForRowAt: IndexPath(row: row, section: 0))
    }
}
