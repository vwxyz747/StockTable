//
//  SettingViewController.swift
//  YuandaStockTableApp
//
//  Created by chenyuchen on 2022/4/20.
//

import Foundation
import UIKit

class SettingViewController: UIViewController{
    
    @IBOutlet weak var syncronizrTimeMillsTextField: UITextField!
    @IBOutlet weak var selectAllBtn: UIButton!
    @IBOutlet weak var stockListTableview: UITableView!
    
    let allStockIdList = PriceManager.shared.getDefaultPriceList()
    var selectedStockList: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedStockList = PriceManager.shared.selectedList
        initView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        stockListTableview.reloadData()
    }
    
    func initView(){
        stockListTableview.delegate = self
        stockListTableview.dataSource = self
        syncronizrTimeMillsTextField.text = String(PriceManager.shared.syncronizeTimeMills)
    }
    
    @IBAction func selectAllBtnOnTaped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected{
            selectedStockList = allStockIdList.map({$0.stockId})
            stockListTableview.reloadData()
        }
    }
    
    //全不選
    @IBAction func selectNoneBtnOnTaped(_ sender: UIButton) {
        selectedStockList.removeAll()
        stockListTableview.reloadData()
    }
    
    @IBAction func backBtnOnTaped(_ sender: Any) {
        PriceManager.shared.replaceSelectedId(list: selectedStockList)
        Utils.setStringSet(value: selectedStockList.joined(separator: ","), key: SELECTED_STOCK_ID)
        PriceManager.shared.setTimeMills(ms: Int(syncronizrTimeMillsTextField.text ?? "1000") ?? 1000)

        self.dismiss(animated: true, completion: nil)
    }
}

extension SettingViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allStockIdList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "StockIdTableCell") as? StockIdTableCell{
            if let stock = allStockIdList.get(indexPath.row){
                cell.stockIdBtn.isSelected = selectedStockList.contains(stock.stockId)
                cell.stockIdBtn.setTitle(stock.stockId, for: .normal)
                cell.stockIdBtn.setTitle(stock.stockId, for: .selected)

                cell.clicker = { [self]
                    isSelected in
                    if isSelected{
                        selectedStockList.append(cell.stockIdBtn.titleLabel!.text!)
                    }else{
                        selectedStockList.removeAll(where: {$0 == cell.stockIdBtn.titleLabel!.text!})
                    }
                }
            }
            cell.selectionStyle = .none
            return cell
        }
        return UITableViewCell()
    }
    
    
}

class StockIdTableCell: UITableViewCell{
    
    @IBOutlet weak var stockIdBtn: UIButton!
    var clicker: ((Bool)->())?
    
    override func prepareForReuse() {
        stockIdBtn.setTitle("----", for: .normal)
    }
    
    @IBAction func btnOnTaped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        clicker?(sender.isSelected)
    }
}
