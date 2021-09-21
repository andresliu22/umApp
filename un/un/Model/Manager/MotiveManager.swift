//
//  MotiveManager.swift
//  un
//
//  Created by Andres Liu on 1/25/21.
//

import Foundation

class MotiveManager {
    static let shared = MotiveManager()
    var motiveListVC = MotiveListVC()
}

class MotiveFilterManager {
    static let shared = MotiveFilterManager()
    var motiveListFiltersVC = MotiveListFilterVC()
}
