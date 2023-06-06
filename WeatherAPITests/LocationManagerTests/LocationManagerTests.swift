//
//  LocationManagerTests.swift
//  WeatherAppTests
//
//  Created by Evgenii Rebov on 03.06.2023.
//

import XCTest
import CoreLocation
@testable import WeatherApp

class LocationManagerTests: XCTestCase {
    typealias StatusError = LocationManager.StatusError

    func test_beginUpdatingLocation_withLocationServiceAuthorizedAlways_returnsWithoutError() {
        let (manager, provider) = makeSUT()
        provider.stubbedAuthorizationStatus = .authorizedAlways

        let exp = self.expectation(description: "Completion handler called")
        var receivedError: Error?

        manager.beginUpdatingLocation { error in
            receivedError = error
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1)
        XCTAssertTrue(provider.startUpdatingLocationCalled)
        XCTAssertNil(receivedError)
    }
    
    func test_beginUpdatingLocation_withLocationServiceAuthorizedWhenInUse_returnsWithoutError() {
        let (manager, provider) = makeSUT()
        provider.stubbedAuthorizationStatus = .authorizedWhenInUse

        let exp = self.expectation(description: "Completion handler called")
        var receivedError: Error?

        manager.beginUpdatingLocation { error in
            receivedError = error
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1)
        XCTAssertTrue(provider.startUpdatingLocationCalled)
        XCTAssertNil(receivedError)
    }
    
    func test_beginUpdatingLocation_withLocationServicesDisabled_returnsError() {
        let (manager, provider) = makeSUT()
        provider.stubbedLocationServicesEnabled = false

        expect(manager, toRetrieve: .common)
    }


    func test_beginUpdatingLocation_withLocationPermissionRestricted_returnsError() {
        let (manager, provider) = makeSUT()
        provider.stubbedAuthorizationStatus = .restricted

        expect(manager, toRetrieve: .restricted)
    }

    func testGetLocation_withLocationPermissionDenied_ReturnsError() {
        let (manager, provider) = makeSUT()
        provider.stubbedAuthorizationStatus = .denied
        
        expect(manager, toRetrieve: .denied)
    }

    func test_beginUpdatingLocation_withLocationPermissionNotDetermined_asksForPermission() {
        let (manager, provider) = makeSUT()
        provider.stubbedAuthorizationStatus = .notDetermined

        let exp = self.expectation(description: "Completion handler called")
        var receivedError: Error?

        manager.beginUpdatingLocation { error in
            receivedError = error
            exp.fulfill()
        }

        XCTAssertTrue(provider.requestWhenInUseAuthorizationCalled)
        XCTAssertFalse(provider.startUpdatingLocationCalled)
        wait(for: [exp], timeout: 1)
        XCTAssertNil(receivedError)
    }

    func test_didUpdateLocations_withValidLocation_returnsLocation() {
        let (manager, provider) = makeSUT()
        
        let location = CLLocation(latitude: 42.6, longitude: 14.9)
        let mockHandler: ((CLLocation?) -> Void) = { received in
            XCTAssertEqual(received?.coordinate.latitude, location.coordinate.latitude)
            XCTAssertEqual(received?.coordinate.longitude, location.coordinate.longitude)
        }
    
        manager.locationManager(provider, didUpdateLocations: [location])
        manager.didReceiveLocation = mockHandler
        provider.delegate?.locationManager!(provider, didUpdateLocations: [location])
    }
    
    // MARK: - Helpers
    
    func makeSUT(mockLocationProvider: MockCLLocationManager = MockCLLocationManager()) -> (LocationManager, MockCLLocationManager) {
        return (LocationManager(mockLocationProvider), mockLocationProvider)
    }
    
    func expect(_ sut: LocationManager, toRetrieve: StatusError, file: StaticString = #file, line: UInt = #line) {
        let exp = self.expectation(description: "Completion handler called")
        var receivedError: StatusError?

        sut.beginUpdatingLocation { error in
            receivedError = error as? StatusError
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1)
        XCTAssertEqual(receivedError?.localizedDescription, toRetrieve.localizedDescription)
    }
}

class MockCLLocationManager: MainCLLocationManager {
        
    var stubbedLocationServicesEnabled = true
    
    var stubbedAuthorizationStatus: CLAuthorizationStatus = .notDetermined
    override var authorizationStatus: CLAuthorizationStatus {
        return stubbedAuthorizationStatus
    }
    
    var requestWhenInUseAuthorizationCalled = false
    override func requestWhenInUseAuthorization() {
        requestWhenInUseAuthorizationCalled = true
    }
    
    var startUpdatingLocationCalled = false
    override func startUpdatingLocation() {
        startUpdatingLocationCalled = true
    }
    
    override func isLocationServicesEnabled() -> Bool {
        return stubbedLocationServicesEnabled
    }
}
