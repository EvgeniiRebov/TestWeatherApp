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

    @NSManaged public var city: String
    @NSManaged public var date: Date
    @NSManaged public var temperature: Double
    @NSManaged public var unit: String
    
    static func items(from localWeather: [LocalWeatherItem], in context: NSManagedObjectContext) -> NSOrderedSet {
        return NSOrderedSet(array: localWeather.map { local in
            let managed = ManagedWeatherItem(context: context)
            managed.city = local.city
            managed.temperature = local.temperature
            managed.unit = local.unit
            managed.date = local.date
            return managed
        })
    }
    
    var local: LocalWeatherItem {
        return LocalWeatherItem(city: city, temperature: temperature, unit: unit, date: date)
    }
}

extension ManagedWeatherItem : Identifiable {

}
