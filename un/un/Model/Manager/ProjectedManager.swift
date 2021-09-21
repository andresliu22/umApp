//
//  ProjectedManager.swift
//  un
//
//  Created by Andres Liu on 1/20/21.
//

import Foundation

class ProjectedManager {
    static let shared = ProjectedManager()
    var projectedVC = AccountStateProjectedVC()
}

class ProjectedFilterManager {
    static let shared = ProjectedFilterManager()
    var projectedFiltersVC = ProjectedFiltersVC()
}
