//
//  ViewController.swift
//  YuandaStockTableApp
//
//  Created by chenyuchen on 2022/4/20.
//

import UIKit
import SpreadsheetView

class MainViewController: UIViewController {
    
    
    @IBOutlet weak var dateTitleLbl: UILabel!
    @IBOutlet weak var spreadsheetView: SpreadsheetView!

    var stockPriceList: [StockPriceData]?
        
    let TITLE_LIST = ["昨收價", "成交價", "漲跌", "幅度", "更新時間"]
    ///表格顏色
    var rowTextColor: UIColor =  UIColor(named: "gray_text_color") ?? .lightText
    var rowColorDefault: UIColor = UIColor(named: "background_color") ?? .gray
    
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
                    self.spreadsheetView.reloadData()
                    PriceManager.shared.runTimerForNewList(handler: { [self]
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
            self.spreadsheetView.reloadData()
            //  開啟跑報價
            PriceManager.shared.runTimerForNewList(handler: { [self]
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
        PriceManager.shared.stopTimer()
    }
    
    
    func initView(){
        
        spreadsheetView.dataSource = self
        spreadsheetView.delegate = self
        spreadsheetView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 1, right: 0)
        spreadsheetView.indicatorStyle = .default
        spreadsheetView.showsHorizontalScrollIndicator = false
        spreadsheetView.bounces = false//關閉overscroll
        spreadsheetView.tintColor = .clear

        spreadsheetView.register(UINib.init(nibName: "InfoCell", bundle: nil), forCellWithReuseIdentifier: "InfoCell")
        spreadsheetView.register(UINib.init(nibName: "RowTitleCell", bundle: nil), forCellWithReuseIdentifier: "RowTitleCell")

        spreadsheetView.gridStyle = .solid(width: 1, color: #colorLiteral(red: 0.2605174184, green: 0.2605243921, blue: 0.260520637, alpha: 1))
        
    }
    
    //日期標題
    func setTitle(){
        let today = Date()
        let year = (Int(Utils.getDateString(date: today, dateFormat:"yyyy")) ?? 1911) - 1911

        dateTitleLbl.text = String(year) + Utils.getDateString(date: today, dateFormat: "年MM月dd日 當日\n日成交資訊(股)")
    }
    
    //更新cell
    func updateTableCells(){
        
//        for cell in stockInfoTableview.visibleCells{
//            if let cell = cell as? StockInfoTableCell, let newData = stockPriceList?.first(where: {$0.stockId == cell.stockId}){
//                cell.setData(data: newData)
//            }
//        }
        for cell in spreadsheetView.visibleCells{
            if let cell = cell as? RowTitleCell{
                
            }else if let cell = cell as? InfoCell, let newData = stockPriceList?.first(where: {$0.stockId == cell.stockId}){
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
                self.spreadsheetView.reloadData()
                PriceManager.shared.runTimerForNewList(handler: { [self]
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

extension MainViewController: SpreadsheetViewDataSource, SpreadsheetViewDelegate{
    
    
    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return 1 + 5
    }
    
    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        return 1 + (stockPriceList?.count ?? 0)
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
        if column == 0{
            return SCREEN_WIDTH / 4 - 15
        }
        return SCREEN_WIDTH / 4 - 5
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow row: Int) -> CGFloat {
        return 50
    }
    
    func frozenRows(in spreadsheetView: SpreadsheetView) -> Int {
        return 1
    }
    
    func frozenColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return 1
    }
    
    func mergedCells(in spreadsheetView: SpreadsheetView) -> [CellRange] {
        var list: [CellRange] = []
        if stockPriceList == nil{
            return []
        }
        for i in 1 ... (stockPriceList?.count ?? 0){
            list.append(CellRange(from: (i, 1), to: (i, 5)))
        }
        return list
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {
        switch (indexPath.column, indexPath.row) {
        case (0, 0):
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "RowTitleCell", for: indexPath) as! RowTitleCell
            cell.valueLbl.text = "商品名稱"
            cell.valueLbl.textAlignment = .left
            cell.backgroundColor = rowColorDefault
            cell.gridlines.left = .none
            cell.gridlines.right = .none
            cell.gridlines.bottom = .none
            cell.gridlines.top = .none
            return cell
        case (1...5, 0):
            //標題
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "RowTitleCell", for: indexPath) as! RowTitleCell
            
            cell.valueLbl.text = TITLE_LIST[indexPath.column-1]
            cell.valueLbl.textAlignment = .right
            cell.backgroundColor = rowColorDefault
            cell.gridlines.left = .none
            cell.gridlines.right = .none
            cell.gridlines.bottom = .none
            cell.gridlines.top = .none

            return cell
        case (0, 0 ... stockPriceList!.count):
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "RowTitleCell", for: indexPath) as! RowTitleCell
            
            if let data = stockPriceList?.get(indexPath.row - 1){
                cell.valueLbl.text = data.stockName
            }
            cell.valueLbl.textAlignment = .left
            cell.backgroundColor = rowColorDefault
            cell.gridlines.left = .none
            cell.gridlines.right = .none
            cell.gridlines.bottom = .none
            cell.gridlines.bottom = .default

            return cell
        case (1...4, 1 ... stockPriceList!.count):
            //資料
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: "InfoCell", for: indexPath) as! InfoCell
            if let data = stockPriceList?.get(indexPath.row - 1){
                
                cell.setData(data: data)
            }
            cell.backgroundColor = rowColorDefault
            cell.gridlines.left = .none
            cell.gridlines.right = .none
            cell.gridlines.bottom = .default

            return cell
            
        default:
            return nil
        }
            
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return false
    }
}

