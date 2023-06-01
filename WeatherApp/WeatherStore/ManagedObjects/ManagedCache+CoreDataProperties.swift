//
//  ManagedCache+CoreDataProperties.swift
//  WeatherApp
//
//  Created by Evgenii Rebov on 28.05.2023.
//
//

import Foundation
import CoreData


extension ManagedCache {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedCache> {
        return NSFetchRequest<ManagedCache>(entityName: "ManagedCache")
    }

    @NSManaged public var history: NSOrderedSet

    var localHistory: [LocalWeatherItem] {
        return history.compactMap { ($0 as? ManagedWeatherItem)?.local }
    }
    
    static func find(in context: NSManagedObjectContext) throws -> ManagedCache? {
        let request = NSFetchRequest<ManagedCache>(entityName: entity().name!)
        request.returnsObjectsAsFaults = false
        return try context.fetch(request).first
    }
    
    static func newUniqueInstance(in context: NSManagedObjectContext) throws -> ManagedCache {
        try find(in: context).map(context.delete)
        return ManagedCache(context: context)
    }
}

extension ManagedCache : Identifiable {

}
