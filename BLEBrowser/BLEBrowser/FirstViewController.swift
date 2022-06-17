//
//  FirstViewController.swift
//  BLEBrowser
//
//  Created by 野中淳 on 2022/05/12.
//

import Foundation
import UIKit
import CoreBluetooth
import StatusAlert

class FirstViewController:UIViewController{
    
    //Filterのセル情報
    var filterCellSettings: [(filterType: String, imageAlpha: Double,selected:Bool)] = [
        ("No filter",0,true),
        ("RSSI > -62",1,false),
        ("RSSI > -74",0.7,false),
        ("RSSI > -86",0.5,false)]
    //Sortのセル情報
    var sortCellSettings: [(sortType: String,selected:Bool)] = [
        ("No sort",true),
        ("RSSI sort(Descending)",false),
        ("Name sort(Descending)",false)]
    
    
    //Alert内に表示するtableView
    var filterAlertlCustumTableView  = UITableView()
    var sortAlertlCustumTableView  = UITableView()
    
    //Mainに表示するtableView
    //var bluetoothTableView = UITableView()
    var menuButtonItem = UIBarButtonItem()
    var bluetoothDetailTableView = UITableView()
    
    // 開いているセクション保持
    var expandSectionSet = Set<Int>()
    
    var bluetoothService:BluetoothService!
    
    //グルグル
    var activityIndicatorView = UIActivityIndicatorView()
    
    //タイマー宣言
    var connectTimeoutTimer01: Timer!
    
    var testView = UIView()
    
    lazy var leftImageButtonItem:UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(image: UIImage(systemName: "antenna.radiowaves.left.and.right"), style: .plain, target: self, action: #selector(leftbarButtonItemTup))
        barButtonItem.tintColor = .white
        return barButtonItem
    }()
    
    
    
    let stackView = UIStackView()
    let label = UILabel()
    
    var localName = "no data"
    var manufactureData = "no data"
    var serviceData = "no data"
    var serviceUUIDs = "no data"
    var overflowServiceUUIDs = "no data"
    var txPowerLevel = "no data"
    var isConnectable = "no data"
    var solicitedServiceUUIDs = "no data"
    
    let connectStatusAlert = StatusAlert()
    
    let refreshControl = UIRefreshControl()

    //let scrollView = UIScrollView()
    
    var contentView = UIView()
    
    var isConnecting = false
    
    var cellHeight = BluetoothCell.rowHeight
    
    //Haptic Feedbackの準備
    private let feedbackGenerator: Any? = {
        if #available(iOS 10.0, *) {
            let generator: UINotificationFeedbackGenerator = UINotificationFeedbackGenerator()
            generator.prepare()
            return generator
        } else {
            return nil
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //BLE関連の初期化
        bluetoothService = BluetoothService.shared
        bluetoothService.setupBluetooth()
        
        connectStatusAlert.image = UIImage(systemName: "checkmark")
        connectStatusAlert.title = "Connected"
        connectStatusAlert.appearance.blurStyle = .extraLight
        connectStatusAlert.message = ""
        connectStatusAlert.canBePickedOrDismissed = false
        

        
        style()
        layout()
        
  
        NotificationCenter.default.addObserver(self, selector: #selector(updateTableView),
                                               name: .notifyBlePeripheralCountUpdate, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateRow),
                                               name: .notifyBlePeripheralUpdate, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(bleConnected),
                                               name: .notifyBleConnected, object: nil)
        
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        // ステータスバーを黒く
        return UIStatusBarStyle.lightContent;
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bluetoothService.bleDevices = nil
        //bluetoothDetailTableView.reloadData()
        bluetoothService.startBluetoothScanTimer()
    }
    
    @objc func updateTableView(){
        bluetoothDetailTableView.reloadData()
        if bluetoothDetailTableView.refreshControl!.isRefreshing{
            self.bluetoothDetailTableView.refreshControl?.endRefreshing()
        }
    }
    
    @objc func leftbarButtonItemTup(){
        if bluetoothService.isScaning{
            bluetoothService.stopBluetoothScanTimer()
            navigationItem.leftBarButtonItem?.image = UIImage(systemName: "antenna.radiowaves.left.and.right.slash")
        }else{
            bluetoothService.startBluetoothScanTimer()
            self.navigationItem.leftBarButtonItem?.image = UIImage(systemName: "antenna.radiowaves.left.and.right")
        }
    }
    
    @objc func updateRow(notification: NSNotification?){
        let count = notification!.userInfo!["bleDeviceCount"]  as! Int
        //bluetoothDetailTableView.reloadSections([count], with: .automatic)
        
        if let cell = bluetoothDetailTableView.cellForRow(at: IndexPath(row: count, section: 0)) as? BluetoothCell{
            var alpha = 0.0
            if Int(bluetoothService.bleDevices[count].rssi) > -40 {
                alpha = 1.0
            }else if Int(bluetoothService.bleDevices[count].rssi) > -60{
                alpha = 0.6
            }else if Int(bluetoothService.bleDevices[count].rssi) > -80{
                alpha = 0.4
            }else{
                alpha = 0.2
            }
            cell.RSSIImageView.alpha = alpha
            //headerView.RSSILabel.text = bluetoothService.bleDevices[count].rssi.stringValue
            
            if(bluetoothService.bleDevices[count].rssi.stringValue == "127"){
                print("127")
            }else{
                cell.RSSILabel.text = bluetoothService.bleDevices[count].rssi.stringValue
            }
            
            var isConnect = false
            if let connectalbe = bluetoothService.bleDevices[count].advertisementData[CBAdvertisementDataIsConnectable] as? Int{
                isConnect = connectalbe == 1 ? true : false
                
                if !isConnect{
                    cell.connectImageView.image = UIImage(systemName: "clear")
                    cell.connectImageView.tintColor = .redColor
                }else{
                    cell.connectImageView.image = UIImage(systemName: "play.circle")
                    cell.connectImageView.tintColor = .blueColor
                }
                
            }
            
        }
            
        
        if let headerView = bluetoothDetailTableView.headerView(forSection: count) as? BluetoothTableHeaderView{
            var alpha = 0.0
            if Int(bluetoothService.bleDevices[count].rssi) > -40 {
                alpha = 1.0
            }else if Int(bluetoothService.bleDevices[count].rssi) > -60{
                alpha = 0.6
            }else if Int(bluetoothService.bleDevices[count].rssi) > -80{
                alpha = 0.4
            }else{
                alpha = 0.2
            }
            headerView.RSSIImageView.alpha = alpha
            //headerView.RSSILabel.text = bluetoothService.bleDevices[count].rssi.stringValue
            
            if(bluetoothService.bleDevices[count].rssi.stringValue == "127"){
                print("127")
            }else{
                headerView.RSSILabel.text = bluetoothService.bleDevices[count].rssi.stringValue
            }
            
            var isConnect = false
            if let connectalbe = bluetoothService.bleDevices[count].advertisementData[CBAdvertisementDataIsConnectable] as? Int{
                isConnect = connectalbe == 1 ? true : false
                
                if !isConnect{
                    headerView.connectImageView.image = UIImage(systemName: "clear")
                    headerView.connectImageView.tintColor = .redColor
                }else{
                    headerView.connectImageView.image = UIImage(systemName: "play.circle")
                    headerView.connectImageView.tintColor = .blueColor
                }
                
            }
            
        }

    }
    
    @objc func bleConnected(){
        connectTimeoutTimer01.invalidate()
        activityIndicatorView.stopAnimating()
        connectStatusAlert.showInKeyWindow()
        var nextModalVC = RSSIGrapheViewController()
        nextModalVC.delegate = self
        //Haptic Feedbackで成功を知らせる
        if #available(iOS 10.0, *), let generator = feedbackGenerator as? UINotificationFeedbackGenerator {
            generator.notificationOccurred(.success)
        }
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { timer in
            self.present(nextModalVC, animated: true)
        }
    }
    
    
}

extension FirstViewController{
    
    func style(){
        
        //bluetoothDetailTableView = UITableView(frame: view.frame, style: .insetGrouped)
        bluetoothDetailTableView = UITableView(frame: view.frame, style: .grouped)

        configureMenuButton()
        setNavigationBar()
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 20
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Welcome"
        label.font = UIFont.preferredFont(forTextStyle: .title1)
        
        //        bluetoothTableView.translatesAutoresizingMaskIntoConstraints = false
        //        bluetoothTableView.backgroundColor = .systemBackground
        //        bluetoothTableView.delegate = self
        //        bluetoothTableView.dataSource = self
        //        bluetoothTableView.register(BluetoothCell.self, forCellReuseIdentifier: BluetoothCell.reuseID)
        //
        //        bluetoothTableView.tag = 2
        
        
        bluetoothDetailTableView.translatesAutoresizingMaskIntoConstraints = false
        
        //bluetoothDetailTableView.backgroundColor = .white
        bluetoothDetailTableView.backgroundColor = .eagleColor

        
        bluetoothDetailTableView.delegate = self
        bluetoothDetailTableView.dataSource = self
        bluetoothDetailTableView.register(BluetoothDetailCell.self, forCellReuseIdentifier: BluetoothDetailCell.reuseID)
        bluetoothDetailTableView.register(BluetoothTableHeaderView.self, forHeaderFooterViewReuseIdentifier: BluetoothTableHeaderView.reuseID)
        bluetoothDetailTableView.register(BluetoothCell.self, forCellReuseIdentifier: BluetoothCell.reuseID)

        bluetoothDetailTableView.tag = 3
        bluetoothDetailTableView.separatorColor = .clear
        bluetoothDetailTableView.showsHorizontalScrollIndicator = true
        bluetoothDetailTableView.indicatorStyle = .black
        
        //bluetoothDetailTableView.estimatedRowHeight = bluetoothDetailTableView.rowHeight
        bluetoothDetailTableView.automaticallyAdjustsScrollIndicatorInsets = false
        
//        bluetoothDetailTableView.rowHeight = UITableView.automaticDimension
//        bluetoothDetailTableView.estimatedRowHeight = bluetoothDetailTableView.rowHeight
        
        bluetoothDetailTableView.rowHeight = UITableView.automaticDimension
        bluetoothDetailTableView.estimatedRowHeight = 60
        bluetoothDetailTableView.sectionHeaderHeight = UITableView.automaticDimension
        bluetoothDetailTableView.estimatedSectionHeaderHeight = 60
        bluetoothDetailTableView.isScrollEnabled = true
        
        
        //bluetoothDetailTableView.bounds = CGRect(x: 0, y: 0, width: view.bounds.width, height: 1500)
        
        
        
//        scrollView.translatesAutoresizingMaskIntoConstraints = false
//        scrollView.backgroundColor = .blue
//        scrollView.isScrollEnabled = true
//
//        scrollView.contentSize = CGSize(width: view.bounds.width, height: 10000)
        
        //scrollView.contentOffset = CGPoint(x: 0, y: 0 )

    
        
//        testView.translatesAutoresizingMaskIntoConstraints = false
//        testView.bounds = CGRect(x: 0, y: 0, width: 5000, height: 5000)
//        testView.backgroundColor = .red
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = .red
        
        setupRefreshControl()
        
    }
    
    private func setupRefreshControl(){
        refreshControl.tintColor = UIColor.appColor
        refreshControl.addTarget(self, action: #selector(refreshContent), for: .valueChanged)
        
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.appColor]
        let attributedTitle = NSAttributedString(string: "reload", attributes: attributes)
        refreshControl.attributedTitle = attributedTitle
        
        bluetoothDetailTableView.refreshControl = refreshControl
    }
    
    @objc func refreshContent(){
        print("refresh")
        bluetoothService.stopBluetoothScanTimer()
        bluetoothService.bleDevices = nil
        bluetoothDetailTableView.reloadData()
        expandSectionSet.removeAll()
        bluetoothService.startBluetoothScanTimer()
        
    }
    
    func layout(){
        
        //view.addSubview(bluetoothDetailTableView)
        activityIndicatorView.center = view.center
        activityIndicatorView.style = .large
        activityIndicatorView.color = .blueColor
        view.addSubview(bluetoothDetailTableView)
        view.addSubview(activityIndicatorView)
        //view.addSubview(scrollView)
        //scrollView.addSubview(bluetoothDetailTableView)
        
        //scrollView.addSubview(testView)
        
      
        //bluetoothTableView
        NSLayoutConstraint.activate([
            bluetoothDetailTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            //Navigationにレイアウトをかける時はsafeAriaLayoutGuideらしい
            bluetoothDetailTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            bluetoothDetailTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bluetoothDetailTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//            bluetoothDetailTableView.heightAnchor.constraint(equalToConstant: 10000),

//            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            //Navigationにレイアウトをかける時はsafeAriaLayoutGuideらしい
//            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//            //scrollView.heightAnchor.constraint(equalToConstant: 10000),



        ])
        
        
        NSLayoutConstraint.activate([
            //bluetoothDetailTableView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            //Navigationにレイアウトをかける時はsafeAriaLayoutGuideらしい
            //bluetoothDetailTableView.topAnchor.constraint(equalTo: scrollView.topAnchor),
//            bluetoothDetailTableView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
//            bluetoothDetailTableView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
//            bluetoothDetailTableView.heightAnchor.constraint(equalToConstant: 10000),
        ])
        
//        NSLayoutConstraint.activate([
//            bluetoothDetailTableView.leadingAnchor.constraint(equalTo: bluetoothDetailTableView.superview!.leadingAnchor),
//            //Navigationにレイアウトをかける時はsafeAriaLayoutGuideらしい
//            bluetoothDetailTableView.topAnchor.constraint(equalTo: bluetoothDetailTableView.superview!.topAnchor),
//            bluetoothDetailTableView.trailingAnchor.constraint(equalTo: bluetoothDetailTableView.superview!.trailingAnchor),
//            //bluetoothDetailTableView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
//            bluetoothDetailTableView.heightAnchor.constraint(equalToConstant: 10000),
//        ])
//        NSLayoutConstraint.activate([
//
//            bluetoothDetailTableView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
//            //Navigationにレイアウトをかける時はsafeAriaLayoutGuideらしい
//            bluetoothDetailTableView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
//            bluetoothDetailTableView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
//            bluetoothDetailTableView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
//
//            //bluetoothDetailTableView.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor),
//            //bluetoothDetailTableView.heightAnchor.constraint(equalToConstant: bluetoothDetailTableView.bounds.height),
//            bluetoothDetailTableView.heightAnchor.constraint(equalTo: bluetoothDetailTableView.heightAnchor),
//
//            bluetoothDetailTableView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
//        ])
        
        
        
    }
    
}
extension FirstViewController{
    
    //NavigationBar
    private func setNavigationBar(){
        //UINavigationBarAppearanceをインスタンス化
        let appearance = UINavigationBarAppearance()
        //configureWithOpaqueBackgroundで以前までの設定を全てリセット
        appearance.configureWithOpaqueBackground()
        //背景色の設定
        appearance.backgroundColor = UIColor.appColor
        //titleの装飾：AttributeTextでする必要がある
        appearance.titleTextAttributes = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .title2),
                                          .foregroundColor: UIColor.white]
        //backgroundEffectはブラーとかを選べる。単色であればNone
        appearance.backgroundEffect = .none
        //適用する:ScrollEdgeAppearanceに設定しているが、これは複数あるが、navigation全体の背景色の変更はscrollEdgeAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        //スクロールされた時のナビゲーションは以下でセット
        navigationController?.navigationBar.standardAppearance = appearance

        title = "BLE RSSI Graph"
        
        //right bar item
        navigationItem.rightBarButtonItem = menuButtonItem
        
        
        //left bar item
        navigationItem.leftBarButtonItem = leftImageButtonItem
        
        
        UIView.animate(withDuration: 1.0, delay: 1, options: [.repeat,.curveEaseInOut], animations: {
            self.navigationItem.leftBarButtonItem?.image?.withTintColor(.green)
        }, completion: nil)
        
    
        
    }
    
    //MenuBottnにUIMenuをセット
    private func configureMenuButton(){
        var actions = [UIMenuElement]()
        // Filter
//        actions.append(UIAction(title: "Filter", image: nil, state: .off,
//                                handler: { (_) in
//            let alert: UIAlertController = UIAlertController(title: "Select filter type", message: "\n\n\n\n\n\n\n\n\n\n\n", preferredStyle:  .alert)
//            
//            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: .default, handler:{
//                // ボタンが押された時の処理を書く（クロージャ実装）
//                (action: UIAlertAction!) -> Void in
//                print("OK")
//            })
//            let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler:{
//                // ボタンが押された時の処理を書く（クロージャ実装）
//                (action: UIAlertAction!) -> Void in
//                print("Cancel")
//            })
//            alert.addAction(cancelAction)
//            alert.addAction(defaultAction)
//            
//            self.filterAlertlCustumTableView.tag = 0
//            self.filterAlertlCustumTableView.dataSource = self
//            self.filterAlertlCustumTableView.backgroundColor = UIColor.clear
//            self.filterAlertlCustumTableView.register(FilterCell.self, forCellReuseIdentifier: FilterCell.reuseID)
//            self.filterAlertlCustumTableView.rowHeight = FilterCell.rowHeight
//            self.filterAlertlCustumTableView.isScrollEnabled = false
//            self.filterAlertlCustumTableView.separatorColor = .clear
//            
//            alert.view.addSubview(self.filterAlertlCustumTableView)
//            self.filterAlertlCustumTableView.translatesAutoresizingMaskIntoConstraints = false
//            NSLayoutConstraint.activate([
//                self.filterAlertlCustumTableView.leftAnchor.constraint(equalTo: alert.view.leftAnchor),
//                self.filterAlertlCustumTableView.rightAnchor.constraint(equalTo: alert.view.rightAnchor),
//                self.filterAlertlCustumTableView.bottomAnchor.constraint(equalTo: alert.view.bottomAnchor, constant: -50),
//                self.filterAlertlCustumTableView.heightAnchor.constraint(equalToConstant: FilterCell.rowHeight * CGFloat(self.filterCellSettings.count))
//            ])
//            
//            self.present(alert, animated: true, completion: nil)
//            
//        }))
//        // Sort
//        actions.append(UIAction(title: "Sort", image: nil, state: .off,
//                                handler: { (_) in
//            
//            let alert: UIAlertController = UIAlertController(title: "Select sort type", message: "\n\n\n\n\n\n\n\n", preferredStyle:  .alert)
//            
//            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: .default, handler:{
//                // ボタンが押された時の処理を書く（クロージャ実装）
//                (action: UIAlertAction!) -> Void in
//                print("OK")
//            })
//            let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler:{
//                // ボタンが押された時の処理を書く（クロージャ実装）
//                (action: UIAlertAction!) -> Void in
//                print("Cancel")
//            })
//            alert.addAction(cancelAction)
//            alert.addAction(defaultAction)
//            
//            self.sortAlertlCustumTableView.tag = 1
//            self.sortAlertlCustumTableView.dataSource = self
//            self.sortAlertlCustumTableView.backgroundColor = UIColor.clear
//            self.sortAlertlCustumTableView.register(SortCell.self, forCellReuseIdentifier: SortCell.reuseID)
//            self.sortAlertlCustumTableView.rowHeight = SortCell.rowHeight
//            self.sortAlertlCustumTableView.isScrollEnabled = false
//            self.sortAlertlCustumTableView.separatorColor = .clear
//            
//            alert.view.addSubview(self.sortAlertlCustumTableView)
//            self.sortAlertlCustumTableView.translatesAutoresizingMaskIntoConstraints = false
//            NSLayoutConstraint.activate([
//                self.sortAlertlCustumTableView.leftAnchor.constraint(equalTo: alert.view.leftAnchor),
//                self.sortAlertlCustumTableView.rightAnchor.constraint(equalTo: alert.view.rightAnchor),
//                self.sortAlertlCustumTableView.bottomAnchor.constraint(equalTo: alert.view.bottomAnchor, constant: -50),
//                self.sortAlertlCustumTableView.heightAnchor.constraint(equalToConstant: SortCell.rowHeight * CGFloat(self.sortCellSettings.count))
//            ])
//            
//            self.present(alert, animated: true, completion: nil)
//            
//            
//            
//        }))
        //Bluetooth Settings
        //設定アプリを開く
        actions.append(UIAction(title: "Bluetooth Settings", image: nil, state: .off,
                                handler: { (_) in
            //let url = URL(string: "app-settings:")
            let url = URL(string: UIApplication.openSettingsURLString)!
            UIApplication.shared.open(url)
        }))
        
        //Version information
        actions.append(UIAction(title: "Version Information", image: nil, state: .off,
                                handler: { (_) in
            
            let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
            //alert表示
            let alert: UIAlertController = UIAlertController(title: "Version Information",
                                                             message: "BLE Browser\n Version: \(version!)", preferredStyle:  .alert)
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: .default, handler:{
                // ボタンが押された時の処理を書く（クロージャ実装）
                (action: UIAlertAction!) -> Void in
                print("OK")
            })
            alert.addAction(defaultAction)
            self.present(alert, animated: true, completion: nil)
            
        }))
        // UIButtonにUIMenuを設定
        let menu = UIMenu(title: "", options: .displayInline, children: actions)
        menuButtonItem = UIBarButtonItem(title: "Menu", menu: menu)
        menuButtonItem.tintColor = .white
    }
}
extension FirstViewController:UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView.tag{
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: FilterCell.reuseID, for: indexPath) as! FilterCell
            cell.selectionStyle = .none
            cell.tag = indexPath.row
            cell.delegate = self
            cell.label.text = filterCellSettings[indexPath.row].filterType
            cell.RSSIImageView.alpha = filterCellSettings[indexPath.row].imageAlpha
            cell.selectedImageView.isHidden = !filterCellSettings[indexPath.row].selected
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: SortCell.reuseID, for: indexPath) as! SortCell
            cell.selectionStyle = .none
            cell.tag = indexPath.row
            cell.delegate = self
            cell.label.text = sortCellSettings[indexPath.row].sortType
            cell.selectedImageView.isHidden = !sortCellSettings[indexPath.row].selected
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: BluetoothCell.reuseID, for: indexPath) as! BluetoothCell
            return cell
        case 3:
            
//            let cell = tableView.dequeueReusableCell(withIdentifier: BluetoothDetailCell.reuseID, for: indexPath) as! BluetoothDetailCell
//
//
//            if let name = bluetoothService.bleDevices[indexPath.section].peripheral.name {
//                localName = name
//            }else{
//                localName = "no data"
//            }
//            print("section \(indexPath.section)")
//            if let manufacture = bluetoothService.bleDevices[indexPath.section].advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data{
//                var manufactureSpecificInt:[UInt8] = [UInt8()]
//                var manufactureSpecificString:[String] = [String()]
//                var manuString:String = ""
//                for i in 0 ..< manufacture.count {
//                    manufactureSpecificInt.append(manufacture[i].byteSwapped)
//                    manufactureSpecificString.append(String(manufactureSpecificInt[i], radix: 16))
//                    manuString.append(manufactureSpecificString[i])
//                }
//
//                manufactureData = manuString
//            }else{
//                manufactureData = "no data"
//            }
//
//            if let connectalbe = bluetoothService.bleDevices[indexPath.section].advertisementData[CBAdvertisementDataIsConnectable] as? Int{
//                isConnectable = connectalbe == 1 ? "Yes" : "No"
//
//            }else{
//                isConnectable = "no data"
//            }
//
//            if let txPower = bluetoothService.bleDevices[indexPath.section].advertisementData[CBAdvertisementDataTxPowerLevelKey] as? Int{
//                txPowerLevel = txPower.description
//
//            }else{
//                txPowerLevel = "no data"
//            }
//
//            //servicedata
//            if let serviceDataRow = bluetoothService.bleDevices[indexPath.section].advertisementData[CBAdvertisementDataServiceDataKey] as? Data{
//                var serviceDataInt:[UInt8] = [UInt8()]
//                var serviceDataString:[String] = [String()]
//                var serviceString:String = ""
//                for i in 0 ..< serviceDataRow.count {
//                    serviceDataInt.append(serviceDataRow[i].byteSwapped)
//                    serviceDataString.append(String(serviceDataInt[i], radix: 16))
//                    serviceString.append(serviceDataString[i])
//                }
//
//                serviceData = serviceString
//            }else{
//                serviceData = "no data"
//            }
//
//            if bluetoothService.bleDevices[indexPath.section].advertisementData[CBAdvertisementDataServiceUUIDsKey] != nil{
//                print(bluetoothService.bleDevices[indexPath.section].advertisementData[CBAdvertisementDataServiceUUIDsKey])
//            }
//
//            //servicUUIDS
//            if let serviceUUIDRow = bluetoothService.bleDevices[indexPath.section].advertisementData[CBAdvertisementDataServiceUUIDsKey] as? NSArray {
//                if serviceUUIDRow.count > 0{
//                    print("serviceUUID",serviceUUIDRow)
//                    print("serviceUUID",serviceUUIDRow[0])
//
//                    //型を明示してキャストする必要がある
//                    if let array2 : [CBUUID] = serviceUUIDRow as? [CBUUID] { // オプショナル構文
//                        print("here")
//                        serviceUUIDs = ""
//                        for obj in array2{
//                            serviceUUIDs.append(obj.uuidString)
//                        }
//                    }
//                }
//            }else{
//                serviceUUIDs = "no data"
//            }
//
//            //overFrowservicUUIDS
//            if let overFrowserviceUUIDRow = bluetoothService.bleDevices[indexPath.section].advertisementData[CBAdvertisementDataOverflowServiceUUIDsKey] as? NSArray {
//                if overFrowserviceUUIDRow.count > 0{
//                print("serviceUUID",overFrowserviceUUIDRow)
//                print("serviceUUID",overFrowserviceUUIDRow[0])
//
//                //型を明示してキャストする必要がある
//                if let array2 : [CBUUID] = overFrowserviceUUIDRow as? [CBUUID] { // オプショナル構文
//                    print("here")
//                    overflowServiceUUIDs = ""
//                    for obj in array2{
//                        overflowServiceUUIDs.append(obj.uuidString)
//                    }
//                }
//                }
//            }else{
//                overflowServiceUUIDs = "no data"
//            }
//
//            //solicitedServiceUUIDs
//            if let solicitedserviceUUIDRow = bluetoothService.bleDevices[indexPath.section].advertisementData[CBAdvertisementDataSolicitedServiceUUIDsKey] as? NSArray {
//                if solicitedserviceUUIDRow.count > 0{
//                print("serviceUUID",solicitedserviceUUIDRow)
//                print("serviceUUID",solicitedserviceUUIDRow[0])
//
//                //型を明示してキャストする必要がある
//                if let array2 : [CBUUID] = solicitedserviceUUIDRow as? [CBUUID] { // オプショナル構文
//                    print("here")
//                    solicitedServiceUUIDs = ""
//                    for obj in array2{
//                        solicitedServiceUUIDs.append(obj.uuidString)
//                    }
//                }
//                }
//            }else{
//                solicitedServiceUUIDs = "no data"
//            }
//
//            cell.dataTextView.text = ""
//            cell.dataTextView.text.append(contentsOf: "LocalName: \(localName)\n")//OK
//            cell.dataTextView.text.append(contentsOf: "ManufactureData: \(manufactureData)\n")//OK
//            cell.dataTextView.text.append(contentsOf: "Service Data: \(serviceData)\n")
//            cell.dataTextView.text.append(contentsOf: "Service UUIDs: \(serviceUUIDs)\n")//OK
//            cell.dataTextView.text.append(contentsOf: "Overflow Service UUIDs: \(overflowServiceUUIDs)\n")//ok
//            cell.dataTextView.text.append(contentsOf: "TxPower Level: \(txPowerLevel)\n")//ok
//            cell.dataTextView.text.append(contentsOf: "Is connectable: \(isConnectable)\n")//ok
//            cell.dataTextView.text.append(contentsOf: "Solicited Service UUIDs: \(solicitedServiceUUIDs)\n")//ok
//
//            bluetoothService.bleDevices[indexPath.section].isReaded = true
//
//            localName = "no data"
            
            let cell = tableView.dequeueReusableCell(withIdentifier: BluetoothCell.reuseID, for: indexPath) as! BluetoothCell
            
            cell.row = indexPath.row
            cell.delegate = self
            cell.selectionStyle = .none
            
            if expandSectionSet.contains(indexPath.row) {
                    cell.dataTextView.isHidden = false
                
                //cell.dataTextView.isHidden = false
                
            }else{
                    cell.dataTextView.isHidden = true
                

            }
            
            //header
            //view.section = section
            //view.delegate = self
            //var headerview = view
            cell.localNameLabel.text = (bluetoothService.bleDevices[indexPath.row].peripheral.name != nil) ? bluetoothService.bleDevices[indexPath.row].peripheral.name : "no name"
            cell.uuidLabel.text = bluetoothService.bleDevices[indexPath.row].peripheral.identifier.uuidString
            cell.RSSILabel.text = bluetoothService.bleDevices[indexPath.row].rssi.stringValue
            var alpha = 0.0
            if Int(bluetoothService.bleDevices[indexPath.row].rssi) > -40 {
                alpha = 1.0
            }else if Int(bluetoothService.bleDevices[indexPath.row].rssi) > -60{
                alpha = 0.6
            }else if Int(bluetoothService.bleDevices[indexPath.row].rssi) > -80{
                alpha = 0.4
            }else{
                alpha = 0.2
            }
            cell.RSSIImageView.alpha = alpha
            var isConnect = false
            if let connectalbe = bluetoothService.bleDevices[indexPath.row].advertisementData[CBAdvertisementDataIsConnectable] as? Int{
                isConnect = connectalbe == 1 ? true : false
                
                if !isConnect{
                    cell.NumoButton.setImage(UIImage(systemName: "xmark"), for: .normal)
                    cell.connectImageView.image = UIImage(systemName: "clear")
                    cell.NumoButton.tintColor = .redColor
                    
                }else{
                    cell.NumoButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
                    cell.connectImageView.image = UIImage(systemName: "play.circle")
                    cell.NumoButton.tintColor = .blueColor
                    
                }
            }
            
            //ここからDetail
            
            if let name = bluetoothService.bleDevices[indexPath.row].peripheral.name {
                localName = name
            }else{
                localName = "no data"
            }
            if let manufacture = bluetoothService.bleDevices[indexPath.row].advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data{
                var manufactureSpecificInt:[UInt8] = [UInt8()]
                var manufactureSpecificString:[String] = [String()]
                var manuString:String = ""
                for i in 0 ..< manufacture.count {
                    manufactureSpecificInt.append(manufacture[i].byteSwapped)
                    manufactureSpecificString.append(String(manufactureSpecificInt[i], radix: 16))
                    manuString.append(manufactureSpecificString[i])
                }
                
                manufactureData = manuString
            }else{
                manufactureData = "no data"
            }
            
            if let connectalbe = bluetoothService.bleDevices[indexPath.row].advertisementData[CBAdvertisementDataIsConnectable] as? Int{
                isConnectable = connectalbe == 1 ? "Yes" : "No"
                
            }else{
                isConnectable = "no data"
            }
            
            if let txPower = bluetoothService.bleDevices[indexPath.row].advertisementData[CBAdvertisementDataTxPowerLevelKey] as? Int{
                txPowerLevel = txPower.description
                
            }else{
                txPowerLevel = "no data"
            }
            
            //servicedata
            if let serviceDataRow = bluetoothService.bleDevices[indexPath.row].advertisementData[CBAdvertisementDataServiceDataKey] as? Data{
                var serviceDataInt:[UInt8] = [UInt8()]
                var serviceDataString:[String] = [String()]
                var serviceString:String = ""
                for i in 0 ..< serviceDataRow.count {
                    serviceDataInt.append(serviceDataRow[i].byteSwapped)
                    serviceDataString.append(String(serviceDataInt[i], radix: 16))
                    serviceString.append(serviceDataString[i])
                }
                
                serviceData = serviceString
            }else{
                serviceData = "no data"
            }
            
            if bluetoothService.bleDevices[indexPath.row].advertisementData[CBAdvertisementDataServiceUUIDsKey] != nil{
                print(bluetoothService.bleDevices[indexPath.row].advertisementData[CBAdvertisementDataServiceUUIDsKey])
            }
            
            //servicUUIDS
            if let serviceUUIDRow = bluetoothService.bleDevices[indexPath.row].advertisementData[CBAdvertisementDataServiceUUIDsKey] as? NSArray {
                if serviceUUIDRow.count > 0{
                    print("serviceUUID",serviceUUIDRow)
                    print("serviceUUID",serviceUUIDRow[0])
                    
                    //型を明示してキャストする必要がある
                    if let array2 : [CBUUID] = serviceUUIDRow as? [CBUUID] { // オプショナル構文
                        print("here")
                        serviceUUIDs = ""
                        for obj in array2{
                            serviceUUIDs.append(obj.uuidString)
                        }
                    }
                }
            }else{
                serviceUUIDs = "no data"
            }
            
            //overFrowservicUUIDS
            if let overFrowserviceUUIDRow = bluetoothService.bleDevices[indexPath.row].advertisementData[CBAdvertisementDataOverflowServiceUUIDsKey] as? NSArray {
                if overFrowserviceUUIDRow.count > 0{
                    print("serviceUUID",overFrowserviceUUIDRow)
                    print("serviceUUID",overFrowserviceUUIDRow[0])
                    
                    //型を明示してキャストする必要がある
                    if let array2 : [CBUUID] = overFrowserviceUUIDRow as? [CBUUID] { // オプショナル構文
                        print("here")
                        overflowServiceUUIDs = ""
                        for obj in array2{
                            overflowServiceUUIDs.append(obj.uuidString)
                        }
                    }
                }
            }else{
                overflowServiceUUIDs = "no data"
            }
            
            //solicitedServiceUUIDs
            if let solicitedserviceUUIDRow = bluetoothService.bleDevices[indexPath.row].advertisementData[CBAdvertisementDataSolicitedServiceUUIDsKey] as? NSArray {
                if solicitedserviceUUIDRow.count > 0{
                    print("serviceUUID",solicitedserviceUUIDRow)
                    print("serviceUUID",solicitedserviceUUIDRow[0])
                    
                    //型を明示してキャストする必要がある
                    if let array2 : [CBUUID] = solicitedserviceUUIDRow as? [CBUUID] { // オプショナル構文
                        print("here")
                        solicitedServiceUUIDs = ""
                        for obj in array2{
                            solicitedServiceUUIDs.append(obj.uuidString)
                        }
                    }
                }
            }else{
                solicitedServiceUUIDs = "no data"
            }
            
            cell.dataTextView.text = ""
            cell.dataTextView.text.append(contentsOf: "LocalName: \(localName)\n")//OK
            cell.dataTextView.text.append(contentsOf: "ManufactureData: \(manufactureData)\n")//OK
            cell.dataTextView.text.append(contentsOf: "Service Data: \(serviceData)\n")
            cell.dataTextView.text.append(contentsOf: "Service UUIDs: \(serviceUUIDs)\n")//OK
            cell.dataTextView.text.append(contentsOf: "Overflow Service UUIDs: \(overflowServiceUUIDs)\n")//ok
            cell.dataTextView.text.append(contentsOf: "TxPower Level: \(txPowerLevel)\n")//ok
            cell.dataTextView.text.append(contentsOf: "Is connectable: \(isConnectable)\n")//ok
            cell.dataTextView.text.append(contentsOf: "Solicited Service UUIDs: \(solicitedServiceUUIDs)\n")//ok
            
            bluetoothService.bleDevices[indexPath.row].isReaded = true
            
            
            
            
            
            
            
            
            
            
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: SortCell.reuseID, for: indexPath) as! SortCell
            return cell
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var count = 0
        switch tableView.tag{
        case 0:
            count = filterCellSettings.count
        case 1:
            count = sortCellSettings.count
        case 2:
            count = 2
        case 3:
            //count = expandSectionSet.contains(section) ? 1 : 0
            
            count = (bluetoothService.bleDevices != nil) ? bluetoothService.bleDevices.count : 0
        default:
            count = 2
        }
        
        
        return count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableView.tag{
        case 0:
            print("tap1")
        case 1:
            print("tap2")
        case 2:
            print("tap3")
        case 3:
            print("tap4")
            
            
            if expandSectionSet.contains(indexPath.row) {
                expandSectionSet.remove(indexPath.row)
                bluetoothDetailTableView.beginUpdates()
                //cellHeight = BluetoothCell.rowHeight
                
                //bluetoothDetailTableView.reloadRows(at: [indexPath], with: .automatic)
                bluetoothDetailTableView.endUpdates()
                
            } else {
                expandSectionSet.insert(indexPath.row)
                bluetoothDetailTableView.beginUpdates()
                //bluetoothDetailTableView.reloadRows(at: [indexPath], with: .automatic)
                bluetoothDetailTableView.endUpdates()
            }
            //bluetoothDetailTableView.reloadRows(at: [indexPath], with: .automatic)
            
            
            
            //tableView.beginUpdates()
            //cellHeight = (cellHeight == BluetoothCell.rowHeight ? 100.0 : BluetoothCell.rowHeight)

            //tableView.endUpdates()
            
        default:
            print("tap")
            
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.5
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var height = 0.0
        switch tableView.tag{
        case 0:
            height = 0
        case 1:
            height = 0
        case 2:
            height = 0
        case 3:
            //height = BluetoothTableHeaderView.viewHeight
            height = 0
        default:
            height = 44
        }
        return height
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        var view = UIView()
        view.backgroundColor = .systemGray
        return view
    }
    
    
    
}

extension FirstViewController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height = 0.0
        switch tableView.tag{
        case 0:
            height = FilterCell.rowHeight
        case 1:
            height = SortCell.rowHeight
        case 2:
            height = BluetoothCell.rowHeight
        case 3:
//            height = BluetoothDetailCell.rowHeight
//            height = UITableView.automaticDimension
//            tableView.estimatedRowHeight = BluetoothDetailCell.rowHeight
//            tableView.rowHeight = BluetoothDetailCell.rowHeight
            
//            tableView.rowHeight = UITableView.automaticDimension
//            tableView.estimatedRowHeight = 10000
//            height = UITableView.automaticDimension
            
            
            
            tableView.rowHeight = UITableView.automaticDimension
            tableView.estimatedRowHeight = 60
            tableView.sectionHeaderHeight = UITableView.automaticDimension
            tableView.estimatedSectionHeaderHeight = 60
            
            if expandSectionSet.contains(indexPath.row) {

                height = BluetoothCell.allRowHeight
                if let cell = tableView.cellForRow(at: indexPath) as? BluetoothCell{
                    cell.dataTextView.isHidden = false
                }

                //cell.dataTextView.isHidden = false

            }else{
                //cell.dataTextView.isHidden = true
                height = BluetoothCell.rowHeight
                if let cell = tableView.cellForRow(at: indexPath) as? BluetoothCell{
                    cell.dataTextView.isHidden = true
                }


            }
            
            //height = 300
            
//            tableView.rowHeight = UITableView.automaticDimension
//            tableView.estimatedRowHeight = bluetoothDetailTableView.rowHeight
            //height = cellHeight
            
            //height = tableView.estimatedRowHeight
            
        default:
            height = 44
        }
        return height
    }
    
    
    // UITableViewDelegate
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var headerview:UIView? = nil
        switch tableView.tag{
        case 0:
            headerview = nil
        case 1:
            headerview = nil
        case 2:
            headerview = nil
        case 3:
            
            var view = tableView.dequeueReusableHeaderFooterView(withIdentifier: BluetoothTableHeaderView.reuseID) as! BluetoothTableHeaderView
            view.section = section
            view.delegate = self
            headerview = view
            view.localNameLabel.text = (bluetoothService.bleDevices[section].peripheral.name != nil) ? bluetoothService.bleDevices[section].peripheral.name : "no name"
            view.uuidLabel.text = bluetoothService.bleDevices[section].peripheral.identifier.uuidString
            view.RSSILabel.text = bluetoothService.bleDevices[section].rssi.stringValue
            var alpha = 0.0
            if Int(bluetoothService.bleDevices[section].rssi) > -40 {
                alpha = 1.0
            }else if Int(bluetoothService.bleDevices[section].rssi) > -60{
                alpha = 0.6
            }else if Int(bluetoothService.bleDevices[section].rssi) > -80{
                alpha = 0.4
            }else{
                alpha = 0.2
            }
            view.RSSIImageView.alpha = alpha
            var isConnect = false
            if let connectalbe = bluetoothService.bleDevices[section].advertisementData[CBAdvertisementDataIsConnectable] as? Int{
                isConnect = connectalbe == 1 ? true : false
                
                if !isConnect{
                    view.connectImageView.image = UIImage(systemName: "clear")
                    view.connectImageView.tintColor = .redColor
                }else{
                    view.connectImageView.image = UIImage(systemName: "play.circle")
                    view.connectImageView.tintColor = .blueColor
                }
            }
            
            headerview = nil

        default:
            headerview = nil
        }        
        return headerview
    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        var num = 1
        switch tableView.tag{
        case 0:
            print("1")
        case 1:
            print("2")
        case 2:
            print("3")
        case 3:
            num = (bluetoothService.bleDevices != nil) ? bluetoothService.bleDevices.count : 0
            
            num = 1
            
        default:
            print("tap")
        }
        
        return num
    }
}

extension FirstViewController:FilterCellDelegate{
    func didTapButton(cell: FilterCell) {
        print("did tup cell \(cell.tag)")
        
        for num in 0...filterCellSettings.count - 1{
            if num == cell.tag{
                filterCellSettings[num].selected = true
            }else{
                filterCellSettings[num].selected = false
            }
        }
        filterAlertlCustumTableView.reloadData()
    }
}

extension FirstViewController:SortCelllDelegate{
    func didTapButton(cell: SortCell) {
        print("did tup cell \(cell.tag)")
        
        for num in 0...sortCellSettings.count - 1{
            if num == cell.tag{
                sortCellSettings[num].selected = true
            }else{
                sortCellSettings[num].selected = false
            }
        }
        sortAlertlCustumTableView.reloadData()
    }
    
}
extension FirstViewController:BluetoothTableHeaderViewDelegate{
    
    //HeaderViewTap
    func BluetoothTableHeaderViewTap(_ header: BluetoothTableHeaderView, section: Int) {
        print("headerview tap section \(section)")
        
//        if expandSectionSet.contains(section) {
//            expandSectionSet.remove(section)
//            //bluetoothDetailTableView.isScrollEnabled = false
//            //bluetoothDetailTableView.beginUpdates()
//            //bluetoothDetailTableView.deleteRows(at: [IndexPath(row: 0, section: section)], with: .automatic)
//            //bluetoothDetailTableView.endUpdates()
////            Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { timer in
////                self.bluetoothDetailTableView.isScrollEnabled = true
////            }
//        } else {
//            expandSectionSet.insert(section)
//            //bluetoothDetailTableView.isScrollEnabled = false
//            bluetoothDetailTableView.beginUpdates()
//            bluetoothDetailTableView.insertRows(at: [IndexPath(row: 0, section: section)], with: .automatic)
//            bluetoothDetailTableView.endUpdates()
////            Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { timer in
////                self.bluetoothDetailTableView.isScrollEnabled = true
////            }
//
//
//
//        }
        
    
        // section reload
        //bluetoothDetailTableView.beginUpdates()
        //bluetoothDetailTableView.reloadSections([section], with: .automatic)
        //bluetoothDetailTableView.bounds = CGRect(x: 0, y: 0, width: view.bounds.width, height:bluetoothDetailTableView.contentSize.height)

        //bluetoothDetailTableView.endUpdates()
        
       
        let sectionHeaderRect = bluetoothDetailTableView.rectForHeader(inSection: section)

        if bluetoothDetailTableView.bounds.contains(sectionHeaderRect) {
            bluetoothDetailTableView.scrollRectToVisible(sectionHeaderRect, animated: true)
        }
        
        
    }
    //ConnectImageViewTap
    func connectImageViewTap(_ header: BluetoothTableHeaderView, section: Int) {
        
        if isConnecting{
            
        }else{
            
            
            if let connectalbe = bluetoothService.bleDevices[section].advertisementData[CBAdvertisementDataIsConnectable] as? Int{
                
                if (connectalbe == 1){
                    
                    isConnecting = true
                    print("ImageViewTap section\(section)")
                    bluetoothService.stopBluetoothScanTimer()
                    activityIndicatorView.startAnimating()
                    //statusAlert.showInKeyWindow()
                    //left bar item
                    navigationItem.leftBarButtonItem?.image = UIImage(systemName: "antenna.radiowaves.left.and.right.slash")
                    bluetoothService.connectPeripheral(num: section)
                    connectTimeoutTimer01 = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false, block: { timer in
                        self.bluetoothService.cancelConect()
                        self.activityIndicatorView.stopAnimating()
                        self.isConnecting = false
                        self.bluetoothService.startBluetoothScanTimer()
                        self.navigationItem.leftBarButtonItem?.image = UIImage(systemName: "antenna.radiowaves.left.and.right")
                    })
                    
                }else{
                    
                }
                
                
                
            }
            
            
            
            
            
            
    //        var nextModalVC = RSSIGrapheViewController()
    //        nextModalVC.delegate = self
    //        self.present(nextModalVC, animated: true)
        }

    }
    
}

extension FirstViewController:RSSIGrapheViewControllerDelegate{
    func dismissView() {
        isConnecting = false
        print("dismiss PresentView")
        bluetoothService.startBluetoothScanTimer()
        navigationItem.leftBarButtonItem?.image = UIImage(systemName: "antenna.radiowaves.left.and.right")
    }
}

extension FirstViewController:BluetoothCellDelegate{
    func HeaderViewTap(_ cell: BluetoothCell, row: Int) {
        print("headerview tap row \(row)")
        
        if expandSectionSet.contains(row) {
            expandSectionSet.remove(row)
            bluetoothDetailTableView.beginUpdates()
            //cellHeight = BluetoothCell.rowHeight
            
            //bluetoothDetailTableView.reloadRows(at: [indexPath], with: .automatic)
            bluetoothDetailTableView.endUpdates()
            
        } else {
            expandSectionSet.insert(row)
            bluetoothDetailTableView.beginUpdates()
            //bluetoothDetailTableView.reloadRows(at: [indexPath], with: .automatic)
            bluetoothDetailTableView.endUpdates()
        }
        
        
    }
    
    func connectImageViewTap(_ cell: BluetoothCell, row: Int) {
        print("connectView tap row \(row)")
        
        if isConnecting{
            
        }else{
            if let connectalbe = bluetoothService.bleDevices[row].advertisementData[CBAdvertisementDataIsConnectable] as? Int{
                
                if (connectalbe == 1){
                    
                    isConnecting = true
                    print("ImageViewTap section\(row)")
                    bluetoothService.stopBluetoothScanTimer()
                    activityIndicatorView.startAnimating()
                    //statusAlert.showInKeyWindow()
                    //left bar item
                    navigationItem.leftBarButtonItem?.image = UIImage(systemName: "antenna.radiowaves.left.and.right.slash")
                    bluetoothService.connectPeripheral(num: row)
                    connectTimeoutTimer01 = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false, block: { timer in
                        self.bluetoothService.cancelConect()
                        self.activityIndicatorView.stopAnimating()
                        self.isConnecting = false
                        self.bluetoothService.startBluetoothScanTimer()
                        self.navigationItem.leftBarButtonItem?.image = UIImage(systemName: "antenna.radiowaves.left.and.right")
                    })
                    
                }else{
                    
                }
            }
            
            
            
            
            
            
    //        var nextModalVC = RSSIGrapheViewController()
    //        nextModalVC.delegate = self
    //        self.present(nextModalVC, animated: true)
        }
        
    }
    
    
}
