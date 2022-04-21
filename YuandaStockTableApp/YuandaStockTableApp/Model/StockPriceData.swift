//
//  StockPriceData.swift
//  YuandaStockTableApp
//
//  Created by chenyuchen on 2022/4/20.
//

import Foundation

class StockPriceData: NSObject{
    
    var stockId: String = ""
    var stockName: String = ""
    var referencePrice: Double = 0.0
    var closingPrice: Double = 0.0
    var updown: Double = 0.0
    var updownRatio: Double = 0.0
    var updateTime: Date?


    convenience init(model: StockPriceModel) {
        self.init()
        stockId = model.stockId
        stockName = model.stockName ?? "無名稱"
        referencePrice = Double(model.closingPrice ?? "") ?? 0.0
        closingPrice = Double(model.closingPrice ?? "") ?? 0.0
        updateTime = Date()
    }
}
