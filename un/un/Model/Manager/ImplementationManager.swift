//
//  ImplementationManager.swift
//  un
//
//  Created by Andres Liu on 1/18/21.
//

import Foundation

class ImplementationManager {
    static let shared = ImplementationManager()
    var implementationVC = ImplementationVC()
}

class ImplementationFilterManager {
    static let shared = ImplementationFilterManager()
    var implementationFiltersVC = ImplementationFiltersVC()
}
