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
        perform { context in
            do {
                let request = NSFetchRequest<ManagedCache>(entityName: ManagedCache.entity().name!)
                request.returnsObjectsAsFaults = false
                if let cache = try ManagedCache.find(in: context) {
                    completion(.found(weather: cache.localHistory))
                } else {
                    completion(.empty)
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func insert(_ weather: [LocalWeatherItem], completion: @escaping InsertionCompletion) {
        perform { context in
            do {
                let managedCache = ManagedCache(context: context)
                managedCache.history = ManagedWeatherItem.items(from: weather, in: context)

                try context.save()
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    func deleteCachedWeather(completion: @escaping DeletionCompletion) {
        perform { context in
            do {
                try ManagedCache.find(in: context).map(context.delete).map(context.save)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    private func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform { action(context) }
    }
}
