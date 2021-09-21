//
//  Motive.swift
//  un
//
//  Created by Andres Liu on 1/25/21.
//

import Foundation

struct Motive {
    var totalInversion: Float
    var totalCurrentScope: Float
    var totalExpectedScope: Float
    var totalCurrentImpressions: Float
    var totalExpectedImpressions: Float
    var totalCPMImpressions: Float
    var totalClicks: Float
    var totalLinkClicks: Float
    var totalCTR: Float
    var totalLinkCTR: Float
    var totalCPC: Float
    var totalLinkCPC: Float
    var videoViews10: Float
    var totalVTR: Float
    var totalCPC10: Float
    var postReactions: Float
    var postComments: Float
    var postShares: Float
}

struct MotiveEle {
    var id: Int
    var name: String
    var imageUrl: String
    var activeValue: Float
}
