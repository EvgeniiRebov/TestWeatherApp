//
//  WeatherUIIntegrationTests.swift
//  WeatherApp
//
//  Created by Evgenii Rebov on 04.06.2023.
//

import XCTest
import CoreLocation
@testable import WeatherApp

class WeatherUIIntegrationTests: XCTestCase {
    func test_viewDidLoad_deliversEmptyHistory() {
        let loader = MockLocalLoader(store: DummyStore())
        loader.retrievalResult = .success([])
        let sut = makeSUT(localLoader: loader)
        
        sut.loadViewIfNeeded()
        
        XCTAssertTrue(sut.history.isEmpty)
        XCTAssertNil(sut.receivedError)
    }
    
    func test_viewDidLoad_deliversNotEmptyHistory() {
        let loader = MockLocalLoader(store: DummyStore())
        let expectedHistory = uniqueWeatherHistory().models
        loader.retrievalResult = .success(expectedHistory)
        let sut = makeSUT(localLoader: loader)
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.history, expectedHistory)
        XCTAssertNil(sut.receivedError)
    }
    
    func test_viewDidLoad_deliversError() {
        let expectedError = anyNSError()
        
        let loader = MockLocalLoader(store: DummyStore())
        loader.retrievalResult = .failure(expectedError)
        let sut = makeSUT(localLoader: loader)
        
        sut.loadViewIfNeeded()
        
        XCTAssertTrue(sut.history.isEmpty)
        XCTAssertNotNil(sut.receivedError)
        XCTAssertEqual((sut.receivedError as? NSError)?.domain, expectedError.domain)
        XCTAssertEqual((sut.receivedError as? NSError)?.code, expectedError.code)
    }
    
    func test_requestWithLocation_deliversErrorOnBeginUpdatingLocation() {
        let locationManager = MockLocationManager()
        locationManager.beginUpdatingLocationResult = anyNSError()
        let sut = makeSUT(locationManager: locationManager)
        
        sut.loadViewIfNeeded()
        _ = sut.locationSearchButton.target?.perform(sut.locationSearchButton.action, with: nil)
        
        XCTAssertNotNil(sut.receivedError)
    }

    func test_requestWithLocation_deliversErrorOnDidReceiveLocation() {
        let locationManager = MockLocationManager()
        locationManager.location = nil
        let sut = makeSUT(locationManager: locationManager)
        
        sut.loadViewIfNeeded()
        _ = sut.locationSearchButton.target?.perform(sut.locationSearchButton.action, with: nil)
        
        XCTAssertNotNil(sut.receivedError)
    }
    
    func test_requestWithLocation_callsLoadWithLocation() {
        let locationManager = MockLocationManager()
        let exprectedLocation = CLLocation(latitude: 43, longitude: 54)
        locationManager.location = exprectedLocation
        let remoteLoader = MockRemoteLoader()
        let sut = makeSUT(remoteLoader: remoteLoader, locationManager: locationManager)
        
        sut.loadViewIfNeeded()
        _ = sut.locationSearchButton.target?.perform(sut.locationSearchButton.action, with: nil)
        
        
        XCTAssertNotNil(remoteLoader.loadCalledWithURL)
        let receivedLocation = receivedLocation(from: remoteLoader.loadCalledWithURL!)
        XCTAssertEqual(receivedLocation?.coordinate.latitude, exprectedLocation.coordinate.latitude)
        XCTAssertEqual(receivedLocation?.coordinate.longitude, exprectedLocation.coordinate.longitude)
    }
    
    func test_requestWithCityName_callsLoadWithName() {
        let remoteLoader = MockRemoteLoader()
        let expectedCity = "Moscow"
        let sut = makeSUT(remoteLoader: remoteLoader)
        
        sut.loadViewIfNeeded()
        sut.searchController.searchBar.text = expectedCity
        sut.searchBarSearchButtonClicked(sut.searchController.searchBar)
        
        XCTAssertNotNil(remoteLoader.loadCalledWithURL)
        let receivedCity = receivedQueryItem(with: URLFactory.cityName, from: remoteLoader.loadCalledWithURL!)
        XCTAssertEqual(receivedCity, expectedCity)
        XCTAssertNil(sut.receivedError)
    }
    
    func test_requestWithCityName_callsReloadDataWithNewItem() {
        let expectedError = anyNSError()
        let remoteLoader = MockRemoteLoader()
        remoteLoader.resultToLoad = .failure(expectedError)
        let sut = makeSUT(remoteLoader: remoteLoader)
        
        sut.loadViewIfNeeded()
        sut.searchController.searchBar.text = "Moscow"
        sut.searchBarSearchButtonClicked(sut.searchController.searchBar)
        
        XCTAssertTrue(sut.history.isEmpty)
        XCTAssertNotNil(sut.receivedError)
        XCTAssertEqual((sut.receivedError as? NSError)?.domain, expectedError.domain)
        XCTAssertEqual((sut.receivedError as? NSError)?.code, expectedError.code)
    }
    
    func test_saveInLocal_deliversErrorOnSavingItem() {
        let expectedError = anyNSError()
        let localLoader = MockLocalLoader(store: DummyStore())
        localLoader.savingResult = .failure(expectedError)
        let sut = makeSUT(localLoader: localLoader)
        
        sut.loadViewIfNeeded()
        sut.searchController.searchBar.text = "Moscow"
        sut.searchBarSearchButtonClicked(sut.searchController.searchBar)
        
        XCTAssertTrue(!sut.history.isEmpty)
        XCTAssertNotNil(sut.receivedError)
        XCTAssertEqual((sut.receivedError as? NSError)?.domain, expectedError.domain)
        XCTAssertEqual((sut.receivedError as? NSError)?.code, expectedError.code)
    }
    
    func test_saveInLocal_deliversNoErrorOnSavingItem() {
        let expectedError = anyNSError()
        let localLoader = MockLocalLoader(store: DummyStore())
        let sut = makeSUT(localLoader: localLoader)
        
        sut.loadViewIfNeeded()
        sut.searchController.searchBar.text = "Moscow"
        sut.searchBarSearchButtonClicked(sut.searchController.searchBar)
        
        XCTAssertTrue(!sut.history.isEmpty)
        XCTAssertNil(sut.receivedError)
    }

    // MARK: - Helpers
    
    func makeSUT(remoteLoader: MockRemoteLoader = .init(),
                 localLoader: LocalHitstoryLoader = MockLocalLoader(store: DummyStore()),
                 locationManager: LocationActions = MockLocationManager(),
                 file: StaticString = #file,
                 line: UInt = #line) -> WeatherViewController {
        return WeatherComposer.compose(remoteLoader: remoteLoader, localLoader: localLoader, locationManager: locationManager)
    }
    
    func receivedQueryItem(with name: String, from url: URL) -> String? {
        guard let url = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            XCTFail("Can't get url components")
            return nil
        }
        return url.queryItems?.first(where: { $0.name == name })?.value
    }
    
    func receivedLocation(from url: URL) -> CLLocation? {
        guard let lat = receivedQueryItem(with: URLFactory.latName, from: url),
              let lon = receivedQueryItem(with: URLFactory.lonName, from: url),
              let latitude = Double(lat),
              let longitude = Double(lon) else {
            XCTFail("Can't get lat and lon")
            return nil
        }
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    class MockRemoteLoader: RemoteLoader {
        var resultToLoad: RemoteLoader.Result = .success(uniqueWeather(in: "Moscow"))
        var loadCalledWithURL: URL?
        
        func load(url: URL, completion: @escaping (RemoteLoader.Result) -> Void) {
            loadCalledWithURL = url
            completion(resultToLoad)
        }
    }
    
    class MockLocationManager: LocationActions {
        var beginUpdatingLocationResult: Error?
        var location: CLLocation?
        
        func beginUpdatingLocation(handler: @escaping ((Error?) -> Void)) {
            handler(beginUpdatingLocationResult)
            if beginUpdatingLocationResult == nil {
                didReceiveLocation?(location)
            }
        }
        
        var didReceiveLocation: ((CLLocation?) -> Void)?
    }
    
    
    class MockLocalLoader: LocalHitstoryLoader {
        var retrievalResult: WeatherLoader.Result = .success([])
        var savingResult: LocalHitstoryLoader.SaveResult = .success(())
        
        override func load(completion: @escaping (WeatherLoader.Result) -> Void) {
            completion(retrievalResult)
        }
        
        override func save(_ items: [WeatherItem], completion: @escaping (LocalHitstoryLoader.SaveResult) -> Void) {
            completion(savingResult)
        }
    }
    
    class DummyStore: WeatherStore {
        func deleteCachedWeather(completion: @escaping DeletionCompletion) {
            
        }
        
        func insert(_ weather: [WeatherApp.LocalWeatherItem], completion: @escaping InsertionCompletion) {
            
        }
        
        func retrieve(completion: @escaping RetrievalCompletion) {
            
        }
    }
}
