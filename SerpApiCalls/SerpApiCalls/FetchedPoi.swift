//
//  FetchedPoi.swift
//  SerpApiCalls
//
//  Created by David Kindermann on 11.05.24.
//

import Foundation

struct FetchedPoi: Hashable, Identifiable {
    let title: String
    let placeId: String
    let dataId: String
    let rating: Double
    let typeIds: [String]
    let gpsCoordinates: GPSLocation
    let address: String
    let website: String
    let phone: String
    let thumbnail: String

    var id: String { placeId }
}
