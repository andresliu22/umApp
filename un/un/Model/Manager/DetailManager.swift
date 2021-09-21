//
//  DetailManager.swift
//  un
//
//  Created by Andres Liu on 1/24/21.
//

import Foundation

class DetailManager {
    static let shared = DetailManager()
    var detailVC = BillingDetailVC()
}

class DetailFilterManager {
    static let shared = DetailFilterManager()
    var detailFiltersVC = DetailFilterVC()
}
