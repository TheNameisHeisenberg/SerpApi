//
//  PoiDataView.swift
//  SerpApiCalls
//
//  Created by David Kindermann on 11.05.24.
//

import Foundation
import SwiftUI
import OSLog

struct PoiDataView: View {
    @State private var isLoading = false
    @State private var error: Error?
    @State private var placeIdInput: String = ""
    @State private var fetchedPois: [FetchedPoi] = []
    private let logger = Logger()

    var body: some View {
        VStack {
            TextField("Enter Place ID", text: $placeIdInput)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("Search") {
                fetchPoiData()
            }
            .padding()
            .foregroundColor(.white)
            .background(Color.blue)
            .cornerRadius(8)
            
            if isLoading {
                ProgressView()
                    .padding()
            } else if let error = error {
                Text("Error: \(error.localizedDescription)")
                    .foregroundColor(.red)
                    .padding()
            } else {
                List(fetchedPois) { poi in
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Title: \(poi.title)")
                        Text("Place ID: \(poi.placeId)")
                        Text("Data ID: \(poi.dataId)")
                        Text("Rating: \(String(format: "%.1f", poi.rating))")
                        Text("Type IDs: \(poi.typeIds.joined(separator: ", "))")
                        Text("GPS Coordinates: \(poi.gpsCoordinates.latitude), \(poi.gpsCoordinates.longitude)")
                        Text("Address: \(poi.address)")
                        Text("Website: \(poi.website)")
                        Text("Phone: \(poi.phone)")
                        Text("Thumbnail: \(poi.thumbnail)")
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            fetchPoiData()
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(16)
        .shadow(radius: 4)
    }
    
    func fetchPoiData() {
        guard !placeIdInput.isEmpty else {
            print("Place ID is empty. Cannot fetch data.")
            return
        }
        
        isLoading = true
        
        let poiFetcher = PoiFetcher()
        poiFetcher.fetchPoiData(for: placeIdInput) { result in
            DispatchQueue.main.async {
                isLoading = false
                
                switch result {
                case .success(let fetchedPois):
                    self.fetchedPois = fetchedPois
                    print("Fetched POIs: \(fetchedPois)")
                case .failure(let error):
                    self.error = error
                    print("Error fetching POI data: \(error)")
                }
            }
        }
    }
}
