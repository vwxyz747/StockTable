//
//  ApiHelper.swift
//  YuandaStockTableApp
//
//  Created by chenyuchen on 2022/4/20.
//

import Foundation

class ApiHelper{
    
    static let instance = ApiHelper()

    typealias successData = ((_ successData: Codable) -> ())
    typealias failData = ((_ failData:Codable?, _ errorMsg:String, _ errorCode:String) -> ())
    
    //  全部個股昨日收盤價url
    let STOCK_PRICE_API_URL = "https://openapi.twse.com.tw/v1/exchangeReport/STOCK_DAY_AVG_ALL"
    
    func getStockReferencePriceApi(successComplete:(successData)?, failComplete:(failData)?){
        getApi(url: STOCK_PRICE_API_URL, successComplete: {successData in
            let decoder = JSONDecoder()
            // decode 從 json 解碼，返回一個指定類型的值，這個類型必須符合 Decodable 協議
            
            if let stockData = try? decoder.decode([StockPriceModel].self, from: successData) {
                successComplete?(stockData)
            }
        }, failComplete: {errorMsg in
            
        })
    }
   
    
   private func getApi(url: String, successComplete:((Data)->())?, failComplete:((String)->())?){
        if let url = URL(string: url){
            // GET
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                // 假如錯誤存在，則印出錯誤訊息（ 例如：網路斷線等等... ）
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    // 取得 response 和 data
                } else if let data = data {
                    
                    successComplete?(data)
                }
            }.resume()
        }
    }
}
