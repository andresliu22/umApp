//
//  ContractManager.swift
//  un
//
//  Created by Andres Liu on 1/21/21.
//

import Foundation

class ContractManager {
    static let shared = ContractManager()
    var contractVC = AccountStateContractVC()
}

class ContractFilterManager {
    static let shared = ContractFilterManager()
    var contractFiltersVC = ContractFilterVC()
}
