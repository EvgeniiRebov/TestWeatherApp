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
        expect(sut, toRetrieve: .success(.none))
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        expect(sut, toRetrieveTwice: .success(.none))
    }
    
    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
        let sut = makeSUT()
        let history = uniqueWeatherHistory()
        
        insert(history.local, to: sut)
        
        expect(sut, toRetrieve: .success(history.local))
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        let history = uniqueWeatherHistory()
        
        insert(history.local, to: sut)
        
        expect(sut, toRetrieveTwice: .success(history.local))
    }
    
    func test_insert_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()

        let insertionError = insert(uniqueWeatherHistory().local, to: sut)
        
        XCTAssertNil(insertionError, "Expected to insert cache successfully")
    }

    func test_insert_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        
        insert(uniqueWeatherHistory().local, to: sut)
        
        let insertionError = insert(uniqueWeatherHistory().local, to: sut)

        XCTAssertNil(insertionError, "Expected to override cache successfully")
    }

    func test_insert_overridesPreviouslyInsertedCacheValues() {
        let sut = makeSUT()

        insert(uniqueWeatherHistory().local, to: sut)
        
        let latestHistory = uniqueWeatherHistory()
        insert(uniqueWeatherHistory().local, to: sut)
        
        expect(sut, toRetrieve: .success(latestHistory.local))
    }

    func test_delete_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()

        let deletionError = deleteCache(from: sut)
        
        XCTAssertNil(deletionError, "Expected empty cache deletion to succeed")
    }

    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()

        deleteCache(from: sut)
        
        expect(sut, toRetrieve: .success(.none))
    }

    func test_delete_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()

        insert(uniqueWeatherHistory().local, to: sut)
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNil(deletionError, "Expected non-empty cache deletion to succeed")
    }

    func test_delete_emptiesPreviouslyInsertedCache() {
        let sut = makeSUT()

        insert(uniqueWeatherHistory().local, to: sut)
        deleteCache(from: sut)
        
        expect(sut, toRetrieve: .success(.none))
    }
    
    func test_storeSideEffects_runSerially() {
        let sut = makeSUT()

        var completedOperationsInOrder = [XCTestExpectation]()
        
        let op1 = expectation(description: "Operation 1")
        sut.insert(uniqueWeatherHistory().local) { _ in
            completedOperationsInOrder.append(op1)
            op1.fulfill()
        }
        
        let op2 = expectation(description: "Operation 2")
        sut.deleteCachedWeather() { _ in
            completedOperationsInOrder.append(op2)
            op2.fulfill()
        }
        
        let op3 = expectation(description: "Operation 3")
        sut.insert(uniqueWeatherHistory().local) { _ in
            completedOperationsInOrder.append(op3)
            op3.fulfill()
        }
        
        waitForExpectations(timeout: 5.0)
        
        XCTAssertEqual(completedOperationsInOrder, [op1, op2, op3], "Expected side-effects to run serially but operations finished in the wrong order")
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
        sut.insert(history) { result in
            if case let Result.failure(error) = result { insertionError = error }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return insertionError
    }
    
    @discardableResult
    func deleteCache(from sut: WeatherStore) -> Error? {
        let exp = expectation(description: "Wait for cache deletion")
        var deletionError: Error?
        sut.deleteCachedWeather() { result in
            if case let Result.failure(error) = result { deletionError = error }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return deletionError
    }
    
    func expect(_ sut: WeatherStore, toRetrieveTwice expectedResult: WeatherStore.RetrievalResult,
                file: StaticString = #file, line: UInt = #line) {
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
    }
    
    func expect(_ sut: WeatherStore, toRetrieve expectedResult: WeatherStore.RetrievalResult,
                file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for cache retrieval")
        
        sut.retrieve { retrievedResult in
            switch (expectedResult, retrievedResult) {
            case (.success(.none), .success(.none)),
                 (.failure, .failure):
                break
                
            case let (.success(.some(expected)), .success(.some(retrieved))):
                XCTAssertEqual(retrieved, expected, file: file, line: line)
                
            default:
                XCTFail("Expected to retrieve \(expectedResult), got \(retrievedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
}

func uniqueWeather(in city: String) -> WeatherItem {
    let weather = WeatherItem(city: city, temperature: 24, unit: .celsius, date: "03.04.2023 12:43:24")
    weather.unit = UnitUserDefaults.value()
    return weather
}

func uniqueWeatherHistory() -> (models: [WeatherItem], local: [LocalWeatherItem]) {
    let models = [uniqueWeather(in: "Moscow"), uniqueWeather(in: "SPb")]
    let local = models.map { LocalWeatherItem(city: $0.city,
                                              temperature: $0.temperature,
                                              unit: $0.unit,
                                              date: $0.date) }
    return (models, local)
}
