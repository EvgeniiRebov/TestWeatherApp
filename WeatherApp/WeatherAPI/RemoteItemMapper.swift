//
//  RemoteItemsMapper.swift
//  WeatherApp
//
//  Created by Evgenii Rebov on 25.05.2023.
//

import Foundation

struct RemoteWeatherItem: Decodable {
    let city: String
    let temp: String
}

final class RemoteItemMapper {
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> RemoteWeatherItem {
        guard response.statusCode == 200,
              let item = try? JSONDecoder().decode(RemoteWeatherItem.self, from: data) else {
            throw RemoteWeatherLoader.NetworkError.invalidData
        }
        return item
    }
}