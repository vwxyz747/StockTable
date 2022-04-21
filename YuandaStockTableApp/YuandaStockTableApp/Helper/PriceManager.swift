//
//  PriceManager.swift
//  YuandaStockTableApp
//
//  Created by chenyuchen on 2022/4/20.
//

import Foundation

class PriceManager: NSObject{
    
    static let shared = PriceManager()
    
    //報價秒數
    var syncronizeTimeMills: Int = 500
    
    //  勾選股號
    var selectedList: [String] = Utils.getStringSet(key: SELECTED_STOCK_ID)?.components(separatedBy: ",") ?? MARKET50_LIST
    
    //  原始股票列表
    private var stockPriceList: [StockPriceData] = []
    //  選取的股票列表
    private var filtedStockPriceList: [StockPriceData] = []

    var timer: Timer?
    
    func getDefaultPriceList()-> [StockPriceData]{
        return stockPriceList
    }
    
    func getFiltedPriceList()-> [StockPriceData]{
        return filtedStockPriceList
    }
    
    //  產生新報價
    func getNewPriceList()-> [StockPriceData]{
        filtedStockPriceList.forEach({
            stock in
            if Int.random(in: 0...1) == 1{
                let newPrice = stock.referencePrice + getTickPrice(z: stock.referencePrice) * Double(Int.random(in: -100...100))
                if newPrice <= stock.referencePrice * 1.1 && newPrice >= stock.referencePrice * 0.9{
                    stock.closingPrice = newPrice
                    stock.updateTime = Date()
                }
            }
        })
        return filtedStockPriceList
    }
    
    //1 tick多少元
    func getTickPrice(z: Double)-> Double{
        var range = 0.0
        if z < 10 {
            range = 0.01
        } else if z < 50 {
            range = 0.05
        } else if z < 100 {
            range = 0.1
        } else if z < 500 {
            range = 0.5
        } else if z < 1000 {
            range = 1
        } else {
            range = 5
        }
        return range
    }
    
    //  初始化股票列表
    func initPriceList(successComplete: (([StockPriceData])-> ())?, failComplete: ((String)-> ())?){
        stockPriceList.removeAll()
        filtedStockPriceList.removeAll()

        ApiHelper.instance.getStockReferencePriceApi(successComplete: { [self]
            data in
            if let list = data as? [StockPriceModel]{
               
                for id in MARKET50_LIST{
                    if let model = list.first(where: {$0.stockId == id}){
                        stockPriceList.append(StockPriceData(model:model))
                    }
                }
                filtedStockPriceList = stockPriceList.filter({selectedList.contains($0.stockId)})
                
                successComplete?(filtedStockPriceList)
            }else{
                failComplete?("無法取得股票列表")
            }
        }, failComplete: {
            _, msg,_  in
            failComplete?(msg)
        })
    }
    
    func run(handler: @escaping (([StockPriceData])->())){
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(Double(syncronizeTimeMills)/1000), repeats: true, block: {
            timer in
            //  丟回有新價格的股票列表
            handler(self.getNewPriceList())
        })
    }
    
    func stop(){
        timer?.invalidate()
    }
    
    //  設定頁更動選擇清單
    func replaceSelectedId(list: [String]){
        selectedList = list
        filtedStockPriceList = stockPriceList.filter({selectedList.contains($0.stockId)})
    }
    
    //  設定頁更動秒數
    func setTimeMills(ms: Int){
        syncronizeTimeMills = ms
    }
}

