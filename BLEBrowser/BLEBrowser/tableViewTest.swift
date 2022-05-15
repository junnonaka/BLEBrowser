//
//  tableViewTest.swift
//  BLEBrowser
//
//  Created by 野中淳 on 2022/05/15.
//

import Foundation
import UIKit



class tableViewTest:UITableViewController{
    
    var filterCellSettings: [(filterType: String, imageAlpha: Double,selected:Bool)] = [
                ("No filter",0,false),
                ("RSSI > -62",1,false),
                ("RSSI > -74",0.7,false),
                ("RSSI > -86",0.5,false)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        style()
        layout()
    }
    
}

extension tableViewTest{
    
    func setupTableView(){
        tableView.backgroundColor = .systemOrange
        //delegateとdatasourceにセット
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(FilterCell.self, forCellReuseIdentifier: FilterCell.reuseID)

    }
    
    func style(){
        
    }
    
    func layout(){
        
        
        
        NSLayoutConstraint.activate([
            
        ])
        
    }
}
extension tableViewTest{
    //datasource
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FilterCell.reuseID, for: indexPath) as! FilterCell
        cell.selectionStyle = .none
        cell.tag = indexPath.row
        cell.delegate = self
        
        cell.label.text = filterCellSettings[indexPath.row].filterType
        cell.RSSIImageView.alpha = filterCellSettings[indexPath.row].imageAlpha
        cell.selectedImageView.isHidden = !filterCellSettings[indexPath.row].selected
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterCellSettings.count
    }
    
    //delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}

extension tableViewTest:FilterCellDelegate{
    func didTapButton(cell: FilterCell) {
        print("did tup cell \(cell.tag)")
        
        for num in 0...filterCellSettings.count - 1{
            if num == cell.tag{
                filterCellSettings[num].selected = true
            }else{
                filterCellSettings[num].selected = false
            }
        }
        tableView.reloadData()
    }
}
