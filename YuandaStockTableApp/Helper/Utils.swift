//
//  Utils.swift
//  YuandaStockTableApp
//
//  Created by chenyuchen on 2022/4/20.
//

import Foundation

class Utils: NSObject{
    
    ///金額轉為千分位字串，>500的話小數點後面0位
    static func moneyDot2Formatter(money:Double, isETF: Bool) -> String {
        
        let numberFormatter = NumberFormatter()

        numberFormatter.maximumFractionDigits = 2 //
        numberFormatter.minimumFractionDigits = 2 //小數點後最少2位（不足補0）
        if isETF{
            
        }else{
            if money >= 500 {
                numberFormatter.maximumFractionDigits = 0
                numberFormatter.minimumFractionDigits = 0
            }else if money < 500 && money >= 100{
                numberFormatter.maximumFractionDigits = 1
                numberFormatter.minimumFractionDigits = 1
            }
        }
       
        //格式化
        let format = numberFormatter.string(from: NSNumber(value: money))!
        
        return format
    }
    
    //取日期
    static func getDateString(date: Date, dateFormat: String) -> String{
        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateFormat = dateFormat
        
        return dateFormatter2.string(from: date)
    }
    
    //custom DateString
    static func stringToDateString(_ timeString:String, fromDateFormat: String, toDateFormat: String) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = fromDateFormat
        if timeString == "-" || timeString == ""{
            return "-"
        }
        if let date = dateFormatter.date(from: timeString){
            let dateFormatter2 = DateFormatter()
            dateFormatter2.dateFormat = toDateFormat
            return dateFormatter2.string(from: date)
        }else{
            return "-"
        }
    }
    
    ///get string from userdefault
    static func getStringSet(key:String) -> String? {
        
        return UserDefaults.standard.string(forKey: key)
    }
    
    ///set string in userdefault
    static func setStringSet(value:String?, key:String) {
        
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
    }
}
