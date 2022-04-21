//
//  ViewController.swift
//  YuandaStockTableApp
//
//  Created by chenyuchen on 2022/4/20.
//

import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet weak var dateTitleLbl: UILabel!
    @IBOutlet weak var stockInfoTableview: UITableView!
    
    var stockPriceList: [StockPriceData]?

    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        setTitle()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if stockPriceList == nil{
            //  初始化股票列表-> 開啟跑報價
            PriceManager.shared.initPriceList(successComplete: {
                list in
                self.stockPriceList = list
                DispatchQueue.main.async {
                    self.stockInfoTableview.reloadData()
                    PriceManager.shared.run(handler: { [self]
                        list in
                        self.stockPriceList = list
                        updateTableCells()
                    })
                }
            }, failComplete: {
                msg in
            })
        }else{
            //  從設定頁返回，更新list
            stockPriceList = PriceManager.shared.getFiltedPriceList()
            self.stockInfoTableview.reloadData()
            //  開啟跑報價
            PriceManager.shared.run(handler: { [self]
                list in
                self.stockPriceList = list
                updateTableCells()
            })
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        PriceManager.shared.stop()
    }
    
    
    func initView(){
        stockInfoTableview.delegate = self
        stockInfoTableview.dataSource = self
    }
    
    //日期標題
    func setTitle(){
        let today = Date()
        let year = (Int(Utils.getDateString(date: today, dateFormat:"yyyy")) ?? 1911) - 1911

        dateTitleLbl.text = String(year) + Utils.getDateString(date: today, dateFormat: "年MM月dd日 當日\n日成交資訊(股)")
    }
    
    //更新cell
    func updateTableCells(){
        for cell in stockInfoTableview.visibleCells{
            if let cell = cell as? StockInfoTableCell, let newData = stockPriceList?.first(where: {$0.stockId == cell.stockId}){
                cell.setData(data: newData)
            }
        }
    }
    
    //  同步按鈕
    @IBAction func syncronizeBtnOnTaped(_ sender: Any) {
        //  更新日期
        setTitle()
        //  強制初始化股票列表-> 開始跑報價
        PriceManager.shared.initPriceList(successComplete: {
            list in
            self.stockPriceList = list
            DispatchQueue.main.async {
                self.stockInfoTableview.reloadData()
                PriceManager.shared.run(handler: { [self]
                    list in
                    self.stockPriceList = list
                   updateTableCells()
                })
            }
        }, failComplete: {
            msg in
            print("->> \(msg)")
        })
    }
    
    //  設定鈕
    @IBAction func settingBtnOnTaped(_ sender: Any) {
        let settingVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SettingViewController") as! SettingViewController
        settingVC.hidesBottomBarWhenPushed = true
        settingVC.modalPresentationStyle = .fullScreen
        self.present(settingVC, animated: true, completion: nil)
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stockPriceList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "StockInfoTableCell") as? StockInfoTableCell{
            if let stock = stockPriceList?.get(indexPath.row){
                cell.setData(data: stock)
                return cell
            }else{
                return cell
            }
        }
        
        return UITableViewCell()
    }
}

class StockInfoTableCell: UITableViewCell{
    
    @IBOutlet weak var stockNameLbl: UILabel!
    @IBOutlet weak var yesterdayPriceLbl: UILabel!
    @IBOutlet weak var currentPriceLbl: UILabel!
    @IBOutlet weak var updownLbl: UILabel!
    @IBOutlet weak var updownRatioLbl: UILabel!
    @IBOutlet weak var updateTimeLbl: UILabel!
    
    @IBOutlet weak var bottomHighlightLineView: UIView!
    
    var stockId = ""
    var lastClosingPrice = 0.0
    
    override func prepareForReuse() {
        super.prepareForReuse()
        stockId = ""
        lastClosingPrice = 0.0
        
        stockNameLbl.text = "-"
        yesterdayPriceLbl.text = "-"
        currentPriceLbl.text = "-"
        
        updownLbl.text = "-"
        updownRatioLbl.text = "-"
        currentPriceLbl.textColor = UIColor(named: "gray_text_color")
        updownLbl.textColor = currentPriceLbl.textColor
        updownRatioLbl.textColor = currentPriceLbl.textColor
        
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
        
        stockNameLbl.text = data.stockName

        let isETF = data.stockId.starts(with: "00")
        yesterdayPriceLbl.text = Utils.moneyDot2Formatter(money: data.referencePrice, isETF: isETF)
        currentPriceLbl.text = Utils.moneyDot2Formatter(money: data.closingPrice, isETF: isETF)
        
        let updown = data.closingPrice - data.referencePrice
        updownLbl.text = Utils.moneyDot2Formatter(money:updown, isETF: isETF)
        updownRatioLbl.text = String(format: "%.1f%%", updown/data.referencePrice*100)
        if updown > 0{
            currentPriceLbl.textColor = UIColor(named: "red_stock_up")
        }else if updown < 0{
            currentPriceLbl.textColor = UIColor(named: "green_stock_down")
        }else{
            currentPriceLbl.textColor = UIColor(named: "gray_text_color")
        }
        
        updownLbl.textColor = currentPriceLbl.textColor
        updownRatioLbl.textColor = currentPriceLbl.textColor
        
        updateTimeLbl.text = Utils.getDateString(date: data.updateTime!, dateFormat: "HH:mm:ss")
        
        highlightDataChanged()
    }
    
    //閃動bar
    func highlightDataChanged(){
        bottomHighlightLineView.backgroundColor = currentPriceLbl.textColor

        UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
            self.bottomHighlightLineView.backgroundColor = .clear
        })
    }
}
