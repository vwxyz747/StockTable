//
//  Infoswift
//  YuandaStockTableApp
//
//  Created by chenyuchen on 2022/4/24.
//

import Foundation
import UIKit
import SpreadsheetView

class InfoCell: Cell{
    
    @IBOutlet weak var barView: UIView!
    
    @IBOutlet weak var yPriceLbl: UILabel!
    @IBOutlet weak var closingPriceLbl: UILabel!
    @IBOutlet weak var updownLbl: UILabel!
    @IBOutlet weak var updownRatioLbl: UILabel!
    @IBOutlet weak var updateTimeLbl: UILabel!
    
    var stockId = ""
    var lastClosingPrice = 0.0
    
    override func prepareForReuse() {
        super.prepareForReuse()
        stockId = ""
        lastClosingPrice = 0.0
        
        yPriceLbl.text = "-"
        closingPriceLbl.text = "-"
        
        updownLbl.text = "-"
        updownRatioLbl.text = "-"
        closingPriceLbl.textColor = UIColor(named: "gray_text_color")
        updownLbl.textColor = closingPriceLbl.textColor
        updownRatioLbl.textColor = closingPriceLbl.textColor
        
        updateTimeLbl.text = "--:--:--"
    }
    
    func setData(data: StockPriceData){
        if stockId == ""{
            stockId = data.stockId
            lastClosingPrice = data.closingPrice
        }else if lastClosingPrice == data.closingPrice{
            //  成交價無更動
            return
        }else{
            lastClosingPrice = data.closingPrice
        }
        
        let isETF = data.stockId.starts(with: "00")
        yPriceLbl.text = Utils.moneyDot2Formatter(money: data.referencePrice, isETF: isETF)
        closingPriceLbl.text = Utils.moneyDot2Formatter(money: data.closingPrice, isETF: isETF)
        
        let updown = data.closingPrice - data.referencePrice
        updownLbl.text = Utils.moneyDot2Formatter(money:updown, isETF: isETF)
        updownRatioLbl.text = String(format: "%.1f%%", updown/data.referencePrice*100)
        if updown > 0{
            closingPriceLbl.textColor = UIColor(named: "red_stock_up")
        }else if updown < 0{
            closingPriceLbl.textColor = UIColor(named: "green_stock_down")
        }else{
            closingPriceLbl.textColor = UIColor(named: "gray_text_color")
        }
        
        updownLbl.textColor = closingPriceLbl.textColor
        updownRatioLbl.textColor = closingPriceLbl.textColor
        
        updateTimeLbl.text = Utils.getDateString(date: data.updateTime!, dateFormat: "HH:mm:ss")
        highlightDataChanged()
    }
    
    //閃動bar
    func highlightDataChanged(){
        barView.backgroundColor = closingPriceLbl.textColor

        UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
            self.barView.backgroundColor = .clear
        })
    }
}
