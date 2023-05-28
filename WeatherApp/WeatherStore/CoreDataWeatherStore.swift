//
//  CoreDataWeatherStore.swift
//  WeatherApp
//
//  Created by Evgenii Rebov on 28.05.2023.
//

import CoreData

final class CoreDataWeatherStore: WeatherStore {
    private let container: NSPersistentContainer
    
    init(bundle: Bundle = .main) throws {
        container = try NSPersistentContainer.load(modelName: "CDWeatherModel", in: bundle)
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }
    
    func insert(_ weather: [LocalWeatherItem], completion: @escaping InsertionCompletion) {
        
    }
    
    func deleteCachedWeather(completion: @escaping DeletionCompletion) {
        
    }
    
}

private extension NSPersistentContainer {
    enum LoadingError: Error {
        case modelNotFound
        case failedToLoadPersistentStores(Error)
    }

    static func load(modelName name: String, in bundle: Bundle) throws -> NSPersistentContainer {
        guard let model = NSManagedObjectModel.with(name: name, in: bundle) else {
            throw LoadingError.modelNotFound
        }
        
        let container = NSPersistentContainer(name: name, managedObjectModel: model)
        var loadError: Error?
        container.loadPersistentStores { loadError = $1 }
        try loadError.map { throw LoadingError.failedToLoadPersistentStores($0) }
        
        return container
    }
}

private extension NSManagedObjectModel {
    static func with(name: String, in bundle: Bundle) -> NSManagedObjectModel? {
        return bundle
            .url(forResource: name, withExtension: "momd")
            .flatMap { NSManagedObjectModel(contentsOf: $0) }
    }
}
