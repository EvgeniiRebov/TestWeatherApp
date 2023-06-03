//
//  TestHelperMethods.swift
//  WeatherAppTests
//
//  Created by Evgenii Rebov on 02.06.2023.
//

import Foundation

func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
}

func anyURL() -> URL {
    return URL(string: "http://any-url.com")!
}
