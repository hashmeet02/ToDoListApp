//
//  NetworkManager.swift
//  MyStocks_Hashmeet
//
//  Created by Hashmeet Saini on 2024-08-04.
//
//****************************************
//         BY-     HASHMEET S. SAINI
//         DATE-   AUGUST-5th
// This code has been writte by Hashmeet
//              S. Saini.
//****************************************

import Foundation
import CoreData

//This class stores all the api calls to retreive data from MS Finance
class NetworkManager {
    static let shared = NetworkManager()
    private init() {}

    // Stored headers a property
    private let headers = [
        "x-rapidapi-key": "d4c2a8d472msha0e601434fe2e25p15f7e2jsn0a90c8b3fdaf",
        "x-rapidapi-host": "ms-finance.p.rapidapi.com"
    ]

    //Stored URl session as a property
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10.0
        return URLSession(configuration: config)
    }()

    //Common function for get Resquests
    private func createRequest(urlString: String) -> URLRequest? {
        guard let url = URL(string: urlString) else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        return request
    }

    //This function gets a list of stocks from the api to enable app's search cabilities
    func fetchStocks(query: String, completion: @escaping ([Stock]?) -> Void) {
        guard let request = createRequest(urlString: "https://ms-finance.p.rapidapi.com/market/v2/auto-complete?q=\(query)") else {
            completion(nil)
            return
        }

        session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                completion(nil)
                return
            }

            guard let data = data else {
                print("Error: No data received")
                completion(nil)
                return
            }

            do {
                let result = try JSONDecoder().decode(StockResponse.self, from: data)
                completion(result.results)
            } catch {
                print("Error decoding JSON: \(error)")
                completion(nil)
            }
        }.resume()
    }

    //this function adds a stock to the coredata manager after getting it's latest price.
    func addStock(stock: Stock, isActive: Bool, completion: @escaping (Bool) -> Void) {
        fetchStockPrice(performanceId: stock.performanceId) { price in
            guard let price = price else {
                completion(false)
                return
            }

            DispatchQueue.main.async {
                // Save to Core Data
                let newStock = StockEntity(context: CoreDataManager.shared.context)
                newStock.symbol = stock.ticker
                newStock.name = stock.name
                newStock.price = price
                newStock.isActive = isActive
                newStock.temp = "cold"  // Example default value
                newStock.performanceId = stock.performanceId
                CoreDataManager.shared.saveContext()
                completion(true)
            }
        }
    }

    //This function fetches the latest stock price.
    private func fetchStockPrice(performanceId: String, completion: @escaping (Double?) -> Void) {
        fetchStockDetails(performanceId: performanceId) { stockDetails in
            completion(stockDetails?.lastPrice)
        }
    }

    //this function fetches details of a particular stock from the get-realtime-data api.
    func fetchStockDetails(performanceId: String, completion: @escaping (StockDetails?) -> Void) {
        guard let request = createRequest(urlString: "https://ms-finance.p.rapidapi.com/market/v3/get-realtime-data?performanceIds=\(performanceId)") else {
            completion(nil)
            return
        }

        session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching stock details: \(error)")
                completion(nil)
                return
            }

            guard let data = data else {
                print("No data received")
                completion(nil)
                return
            }

            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let stockData = jsonResponse[performanceId] as? [String: Any],
                   let lowPriceData = stockData["lowPrice"] as? [String: Any],
                   let lowPrice = lowPriceData["value"] as? Double,
                   let highPriceData = stockData["highPrice"] as? [String: Any],
                   let highPrice = highPriceData["value"] as? Double,
                   let lastPriceData = stockData["lastPrice"] as? [String: Any],
                   let lastPrice = lastPriceData["value"] as? Double,
                   let percentNetChangeData = stockData["percentNetChange"] as? [String: Any],
                   let percentNetChange = percentNetChangeData["value"] as? Double {
                    let stockDetails = StockDetails(lowPrice: lowPrice, highPrice: highPrice, lastPrice: lastPrice, percentNetChange: percentNetChange)
                    completion(stockDetails)
                } else {
                    print("Error parsing JSON response")
                    completion(nil)
                }
            } catch {
                print("Error decoding JSON: \(error)")
                completion(nil)
            }
        }.resume()
    }
}

//Struck for stock Details
struct StockDetails {
    let lowPrice: Double
    let highPrice: Double
    let lastPrice: Double
    let percentNetChange: Double
}

