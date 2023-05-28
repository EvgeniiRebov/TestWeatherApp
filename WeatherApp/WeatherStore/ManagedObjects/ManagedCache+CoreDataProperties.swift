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

    @NSManaged public var history: NSOrderedSet?

}

extension ManagedCache : Identifiable {

}
