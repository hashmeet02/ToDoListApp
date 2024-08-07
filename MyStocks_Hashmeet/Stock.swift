//
//  Stock.swift
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

//struct defining the received data from the auto-complete api.
struct StockResponse: Codable {
    let count: Int
    let pages: Int
    let results: [Stock]
}

//Struct defining attributes needed from the api when a stock is selected.
struct Stock: Codable {
    let id: String
    let name: String
    let exchange: String
    let ticker: String
    let securityType: String
    let performanceId: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case exchange
        case ticker
        case securityType
        case performanceId
    }
}
