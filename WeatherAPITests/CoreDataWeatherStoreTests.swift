//
//  CoreDataWeatherStoreTests.swift
//  WeatherApp
//
//  Created by Evgenii Rebov on 28.05.2023.
//

import XCTest
@testable import WeatherApp

class CoreDataWeatherStoreTests: XCTestCase {
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        expect(sut, toRetrieve: .empty)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        expect(sut, toRetrieveTwice: .empty)
    }
    
    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
        let sut = makeSUT()
        let history = uniqueWeatherHistory()
        
        insert(history, to: sut)
        
        expect(sut, toRetrieve: .found(weather: history))
    }

    // - MARK: Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> WeatherStore {
        let storeBundle = Bundle(for: CoreDataWeatherStore.self)
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataWeatherStore(storeURL: storeURL, bundle: storeBundle)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    @discardableResult
    func insert(_ history: [LocalWeatherItem], to sut: WeatherStore) -> Error? {
        let exp = expectation(description: "Wait for cache insertion")
        var insertionError: Error?
        sut.insert(history) { receivedInsertionError in
            insertionError = receivedInsertionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return insertionError
    }
    
    func expect(_ sut: WeatherStore, toRetrieveTwice expectedResult: RetrieveCachedWeatherResult, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
    }
    
    func expect(_ sut: WeatherStore, toRetrieve expectedResult: RetrieveCachedWeatherResult, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for cache retrieval")
        
        sut.retrieve { retrievedResult in
            switch (expectedResult, retrievedResult) {
            case (.empty, .empty),
                 (.failure, .failure):
                break
                
            case let (.found(expected), .found(retrieved)):
                XCTAssertEqual(retrieved, expected, file: file, line: line)
                
            default:
                XCTFail("Expected to retrieve \(expectedResult), got \(retrievedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
}

func testFormatter() -> DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
    return formatter
}

func uniqueWeather(in city: String) -> WeatherItem {
    return WeatherItem(city: city, temperature: 24, unit: "F", date: "03.04.2023 12:43:24")
}

func uniqueWeatherHistory() -> [LocalWeatherItem] {
    let models = [uniqueWeather(in: "Moscow"), uniqueWeather(in: "SPb")]
    let local = models.map { LocalWeatherItem(city: $0.city,
                                              temperature: $0.temperature,
                                              unit: $0.unit,
                                              date: testFormatter().date(from: $0.date) ?? Date()) }
    return local
}
