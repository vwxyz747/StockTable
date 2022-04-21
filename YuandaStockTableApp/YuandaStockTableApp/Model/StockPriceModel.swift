//
//  StockPriceModel.swift
//  YuandaStockTableApp
//
//  Created by chenyuchen on 2022/4/20.
//

import Foundation

struct StockPriceModel: Codable{
    var stockId: String
    var stockName: String?
    var closingPrice: String?
    
    enum CodingKeys: String, CodingKey {
        case stockId = "Code"
        case stockName = "Name"
        case closingPrice = "ClosingPrice"
    }
}
