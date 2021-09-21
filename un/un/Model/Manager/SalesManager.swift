//
//  SalesManager.swift
//  un
//
//  Created by Andres Liu on 1/25/21.
//

import Foundation

class SalesManager {
    static let shared = SalesManager()
    var salesVC = DigitalSalesVC()
}

class SalesFilterManager {
    static let shared = SalesFilterManager()
    var salesFilterVC = SalesFilterVC()
}
