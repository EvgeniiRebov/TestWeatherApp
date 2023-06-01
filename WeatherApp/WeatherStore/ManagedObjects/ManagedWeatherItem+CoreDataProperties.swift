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
    @NSManaged public var date: String
    @NSManaged public var temperature: Double
    @NSManaged public var unit: Int16
    
    var local: LocalWeatherItem {
        return LocalWeatherItem(city: city, temperature: temperature, unit: UnitType(Int(unit)), date: date)
    }
    
    static func items(from localWeather: [LocalWeatherItem], in context: NSManagedObjectContext) -> NSOrderedSet {
        return NSOrderedSet(array: localWeather.map { local in
            let managed = ManagedWeatherItem(context: context)
            managed.city = local.city
            managed.temperature = local.temperature
            managed.unit = Int16(local.unit.intValue)
            managed.date = local.date
            return managed
        })
    }
}

extension ManagedWeatherItem : Identifiable {

}
