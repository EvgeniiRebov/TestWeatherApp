//
//  CoreDataWeatherStore.swift
//  WeatherApp
//
//  Created by Evgenii Rebov on 28.05.2023.
//

import CoreData

final class CoreDataWeatherStore: WeatherStore {
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext

    public init(storeURL: URL, bundle: Bundle = .main) throws {
        container = try NSPersistentContainer.load(modelName: "CDWeatherModel", url: storeURL, in: bundle)
        context = container.newBackgroundContext()
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        let context = self.context
        context.perform {
            do {
                let request = NSFetchRequest<ManagedCache>(entityName: ManagedCache.entity().name!)
                request.returnsObjectsAsFaults = false
                if let cache = try context.fetch(request).first {
                    completion(.found(
                        weather: cache.history
                            .compactMap { ($0 as? ManagedWeatherItem) }
                            .map { LocalWeatherItem(city: $0.city, temperature: $0.temperature, unit: $0.unit, date: $0.date) }
                    ))
                } else {
                    completion(.empty)
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func insert(_ weather: [LocalWeatherItem], completion: @escaping InsertionCompletion) {
        let context = self.context
        context.perform {
            do {
                let managedCache = ManagedCache(context: context)
                managedCache.history = NSOrderedSet(array: weather.map { local in
                    let managed = ManagedWeatherItem(context: context)
                    managed.city = local.city
                    managed.temperature = local.temperature
                    managed.unit = local.unit
                    managed.date = local.date
                    return managed
                })

                try context.save()
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    func deleteCachedWeather(completion: @escaping DeletionCompletion) {
        
    }
    
}

private extension NSPersistentContainer {
    enum LoadingError: Error {
        case modelNotFound
        case failedToLoadPersistentStores(Error)
    }

    static func load(modelName name: String, url: URL, in bundle: Bundle) throws -> NSPersistentContainer {
        guard let model = NSManagedObjectModel.with(name: name, in: bundle) else {
            throw LoadingError.modelNotFound
        }
        
        let description = NSPersistentStoreDescription(url: url)
        let container = NSPersistentContainer(name: name, managedObjectModel: model)
        container.persistentStoreDescriptions = [description]

        var loadError: Swift.Error?
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
