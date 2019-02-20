//
//  CitiBikes.swift
//  CitiBike NYC
//
//  Created by Neethu G on 2/16/19.
//  Copyright © 2019 Neethu G. All rights reserved.
//

import Foundation

struct Station: Decodable {
    var id: Int
    var stationName: String
    var availableDocks: Int
    var totalDocks: Int
    var latitude: Double
    var longitude: Double
    var statusValue: String
    var statusKey: Int
    var availableBikes: Int
    var stAddress1: String
    var stAddress2: String?
    var city: String?
    var postalCode: String?
    var location: String?
    var laltitude: String?
    var testStation: Bool
    var lastCommunicationTime: String?
    var landMark: String?
}


struct CitiBikes: Decodable {
    var executionTime: String
    var stationBeanList:[Station]
}
