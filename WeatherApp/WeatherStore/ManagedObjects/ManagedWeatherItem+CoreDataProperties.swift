//
//  ManagedWeatherItem+CoreDataProperties.swift
//  WeatherApp
//
//  Created by Evgenii Rebov on 28.05.2023.
//
//

import Foundation
import CoreData


extension ManagedWeatherItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedWeatherItem> {
        return NSFetchRequest<ManagedWeatherItem>(entityName: "ManagedWeatherItem")
    }

    @NSManaged public var city: String?
    @NSManaged public var date: Date?
    @NSManaged public var temperature: Double
    @NSManaged public var unit: String?

}

extension ManagedWeatherItem : Identifiable {

}
