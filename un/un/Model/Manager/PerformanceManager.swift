//
//  PerformanceManager.swift
//  un
//
//  Created by Andres Liu on 1/25/21.
//

import Foundation

class PerformanceManager {
    static let shared = PerformanceManager()
    var performanceVC = DigitalPerformanceVC()
}

class PerformanceFilterManager {
    static let shared = PerformanceFilterManager()
    var performanceFiltersVC = PerformanceFilterVC()
}
