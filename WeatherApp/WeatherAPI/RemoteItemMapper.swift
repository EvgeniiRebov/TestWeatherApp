//
//  RemoteItemsMapper.swift
//  WeatherApp
//
//  Created by Evgenii Rebov on 25.05.2023.
//

import Foundation

struct RemoteWeatherItem: Decodable {
    struct MainTemperature: Decodable {
        let temp: Double
    }
    
    let city: String
    let main: MainTemperature
    
    enum CodingKeys: String, CodingKey {
        case city = "name"
        case main
    }
}

final class RemoteItemMapper {
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> RemoteWeatherItem {
        if response.statusCode == 200 {
            do {
                let item = try JSONDecoder().decode(RemoteWeatherItem.self, from: data)
                return item
            } catch {
                print(error)
                throw RemoteWeatherLoader.NetworkError.invalidData
            }
        } else {
            throw RemoteWeatherLoader.NetworkError.invalidData
        }
    }
}
