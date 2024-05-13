//
//  PoiFetcher.swift
//  SerpApiCalls
//
//  Created by David Kindermann on 11.05.24.
//

import Foundation
import SwiftUI
import OSLog

class PoiFetcher {
    private let apiKey = "0364704b8b7c1a7c6881f9d4f994126ef3239772945861bc3bbfbe40c30aa834"
    private let logger = Logger()
    
    func fetchPoiData(for placeId: String, completion: @escaping (Result<[FetchedPoi], Error>) -> Void) {
        logger.log("Fetching for \(placeId) Started")
        guard let url = createURL(for: placeId) else {
            completion(.failure(PoiFetcherError.invalidUrl))
            return
        }
        logger.log("URL: \(url.absoluteString)")
        fetchData(from: url) { result in
            switch result {
            case .success(let data):
                self.parseData(data: data, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func createURL(for placeId: String) -> URL? {
        logger.log("Creating URL")
        var urlComponents = URLComponents(string: "https://serpapi.com/search.json")
        let queryParams = [
            URLQueryItem(name: "engine", value: "google_maps"),
            URLQueryItem(name: "google_domain", value: "google.com"),
            URLQueryItem(name: "hl", value: "en"),
            URLQueryItem(name: "place_id", value: placeId),
            URLQueryItem(name: "api_key", value: apiKey)
        ]
        
        urlComponents?.queryItems = queryParams
        return urlComponents?.url
    }
    
    private func fetchData(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        logger.log("Creating Shared DataTask")
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(PoiFetcherError.invalidResponse))
                return
            }
            
            guard let data = data else {
                completion(.failure(PoiFetcherError.invalidData))
                return
            }
            
            completion(.success(data))
        }.resume()
    }
    
    private func parseData(data: Data, completion: @escaping (Result<[FetchedPoi], Error>) -> Void) {
        do {
            guard let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                throw PoiFetcherError.invalidData
            }
            
            guard let placeResults = jsonObject["place_results"] as? [String: Any] else {
                throw PoiFetcherError.invalidData
            }
            
            let title = placeResults["title"] as? String ?? ""
            let placeId = placeResults["place_id"] as? String ?? ""
            let dataId = placeResults["data_id"] as? String ?? ""
            let rating = placeResults["rating"] as? Double ?? 0.0
            let typeIds = placeResults["type_ids"] as? [String] ?? []
            let gpsCoordinates = placeResults["gps_coordinates"] as? [String: Double] ?? [:]
            let latitude = gpsCoordinates["latitude"] ?? 0.0
            let longitude = gpsCoordinates["longitude"] ?? 0.0
            let address = placeResults["address"] as? String ?? ""
            let website = placeResults["website"] as? String ?? ""
            let phone = placeResults["phone"] as? String ?? ""
            let thumbnail = placeResults["thumbnail"] as? String ?? ""
            
            let fetchedPoi = FetchedPoi(title: title, placeId: placeId, dataId: dataId, rating: rating, typeIds: typeIds, gpsCoordinates: GPSLocation(latitude: latitude, longitude: longitude), address: address, website: website, phone: phone, thumbnail: thumbnail)
            
            completion(.success([fetchedPoi]))
        } catch {
            completion(.failure(error))
        }
    }
}

enum PoiFetcherError: Error {
    case invalidUrl
    case invalidResponse
    case invalidData
}
