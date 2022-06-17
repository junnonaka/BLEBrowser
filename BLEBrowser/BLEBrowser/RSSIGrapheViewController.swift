//
//  RSSIGrapheViewController.swift
//  BLEBrowser
//
//  Created by 野中淳 on 2022/06/11.
//

import UIKit


import Foundation
import UIKit
import Charts
import AVFoundation
import Photos
import StatusAlert
import EMTNeumorphicView

protocol RSSIGrapheViewControllerDelegate:AnyObject{
    func dismissView()
}

class RSSIGrapheViewController:UIViewController{
    
    let BLE_CONNECTED_AND_READING = "Connected to BLEDevice and reading RSSI"
    let BLE_CONNECTED_AND_NOT_READING = "Connected to BLEDevice and not reading RSSI."
    let BLE_DISCONNECTED = "disconnected from BLEDevice. Please reconnect or close this page."
    
    let GRAPH_GUIDE_LABEL = "Pinch to zoom in and out."
    
    let stackView = UIStackView()
    let label = UILabel()
    let topview = UIView()
    let bottomView = UIView()
    let deviceNameLabel = UILabel()
    let titleLabel = UILabel()
    let grapheGuideLabel = UILabel()
    let disconnectButton = EMTNeumorphicButton()
    let captureAnimationView = UIView()
    let chartXLabel = UILabel()
    let chartYLabel = UILabel()

    //let statusLabel = UILabel()
    let guideLabel = UILabel()
    let bottomStackView = UIStackView()
    let graphBackground = EMTNeumorphicView()

//    var startStopButton = UIButton(type: .system)
//    var exportButton = UIButton(type: .system)
//    var snapshotButton = UIButton()
    
    var startStopButton = EMTNeumorphicButton()
    var exportButton = EMTNeumorphicButton()
    var snapshotButton = EMTNeumorphicButton()
    
    var rssiChartView = LineChartView()
    var chartDataSet = LineChartDataSet()
    


    // 今回使用するサンプルデータ
    let sampleData = [-88.0, -70.0, -40.0, -50.0, -55.0, -52.0, -58.0, -65.0, 81.0]
    var isChartOn:Bool = true
    var connectedBleDeviceNum = 0
    
    var nowRssi:Int? = nil
    var nowRssiDatas:[Double] = []

    
    //タイマー宣言
    var rssiTimer01: Timer!
    var bluetoothService:BluetoothService!
    var chartCounter = 0

    let disConnectStatusAlert = StatusAlert()
    
    var isBleConnect:Bool = false{
        didSet{
            if isBleConnect{
                isChartOn = true
                //statusLabel.text = "Connected"
                //disconnectButton.setTitle("disconnect", for: .normal)
            }else{
                isChartOn = false
                //statusLabel.text = "Disconnected"
                //disconnectButton.setTitle("close", for: .normal)
                startStopButton.setTitle("Reconnect", for: .normal)
                startStopButton.setImage(UIImage(systemName:"goforward"), for: .normal)
                guideLabel.text = BLE_DISCONNECTED
            }
        }
    }
    
    weak var delegate:RSSIGrapheViewControllerDelegate?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor =  UIColor.appColor
        
        disConnectStatusAlert.image = UIImage(systemName: "xmark")
        disConnectStatusAlert.title = "Disconnected"
        disConnectStatusAlert.appearance.blurStyle = .extraLight
        disConnectStatusAlert.message = ""
        disConnectStatusAlert.canBePickedOrDismissed = false
        
        //BLE関連の初期化
        bluetoothService = BluetoothService.shared
        setObserver()
        style()
        layout()
        
        //displayChart(data: sampleData)
        //print("RSSIChart View DidLoad")
        startTimer()
        
        
    }
    
    func setObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.didDisConnect),
                                               name: .notifyBleDisconnected, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didConnect),
                                               name: .notifyBleConnected, object: nil)
        
    }
    
    @objc func didDisConnect(){
        disConnectStatusAlert.showInKeyWindow()
        
        isBleConnect = false
    }
    @objc func didConnect(){
        isBleConnect = true
        startStopButton.setTitle("pause", for: .normal)
        startStopButton.setImage(UIImage(systemName:"pause.circle"), for: .normal)
        isChartOn = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //delegate?.dismissView()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        bluetoothService.disconnectPeripheral()
        delegate?.dismissView()
    }
    
    
    //1秒タイマー：RSSIは１秒刻みでないと取得できない
    func startTimer() {
        rssiTimer01 = Timer.scheduledTimer(
            timeInterval: 1.0,
            target: self,
            selector: #selector(self.timerCounter),
            userInfo: nil,
            repeats: true)
    }
    
    //1.0秒ごとに呼ばれる。
    @objc func timerCounter() {
        
        if isChartOn{
            nowRssi = bluetoothService.readRssi()
            //nowRssiLabel.text = String(nowRssi!)
            //print(nowRssiDatas)

            if chartCounter < 1{
                chartCounter += 1
            }else{
                chartYLabel.isHidden = false
                chartXLabel.isHidden = false
                
                nowRssiDatas.append(Double(nowRssi!))
                displayChart(data: nowRssiDatas)
                //calcDistance()
//                if rssiSettingOnOffSwitch.isOn == false{
//                    if nowRssiDatas.count == timerOffsettime{
//                        setRssiOffset()
//                    }
//                }

            }
        }
        
        
        
    }
    
    
    func displayChart(data: [Double]) {
        // グラフの範囲を指定する
        //            chartView = LineChartView(frame: CGRect(x: 0, y: 200, width: view.frame.width, height: 400))
        // プロットデータ(y軸)を保持する配列
        var dataEntries = [ChartDataEntry]()
        
        //            for (xValue, yValue) in data.enumerated() {
        //                let dataEntry = ChartDataEntry(x: Double(xValue), y: yValue)
        //                dataEntries.append(dataEntry)
        //            }
        
        
        for i in 0...(data.count - 1) {
            let dataEntry = ChartDataEntry(x: Double(i) * 1.0, y: data[i])
            dataEntries.append(dataEntry)
        }
        
        
        // グラフにデータを適用
        chartDataSet = LineChartDataSet(entries: dataEntries, label: "SampleDataChart")
        chartDataSet.lineWidth = 0.3 // グラフの線の太さを変更
        
        chartDataSet.circleHoleColor = .red
        chartDataSet.circleRadius = 2 //プロットの大きさ
        chartDataSet.drawValuesEnabled = false //各プロットのラベル表示(今回は表示しない)
        //点の色
        chartDataSet.circleColors = [.pointColor]
        //点を結ぶ線の色
        chartDataSet.colors = [NSUIColor.lineColor]
        chartDataSet.mode = .cubicBezier // 滑らかなグラフの曲線にする
        
        //塗りつぶし
        //chartDataSet.fill = Fill(color: .white)
        chartDataSet.drawFilledEnabled = true
        chartDataSet.fillFormatter = DefaultFillFormatter { _,_  -> CGFloat in
            return CGFloat(self.rssiChartView.leftAxis.axisMinimum)
        }
        //chartDataSet.fillAlpha = 0.8
        
        //chartDataSet.drawFilledEnabled = true
        
        rssiChartView.data = LineChartData(dataSet: chartDataSet)
        
        // X軸(xAxis)
        rssiChartView.xAxis.labelPosition = .bottom // x軸ラベルをグラフの下に表示する
        rssiChartView.xAxis.labelTextColor = .white
        
        
        // Y軸(leftAxis/rightAxis)
        rssiChartView.leftAxis.axisMaximum = -20 //y左軸最大値
        rssiChartView.leftAxis.axisMinimum = -90 //y左軸最小値
        rssiChartView.leftAxis.labelCount = 11 // y軸ラベルの数
        rssiChartView.leftAxis.labelTextColor = .white
        
        rssiChartView.rightAxis.enabled = false // 右側の縦軸ラベルを非表示
        
        // その他の変更
        rssiChartView.highlightPerTapEnabled = true // プロットをタップして選択不可
        rssiChartView.legend.enabled = false // グラフ名（凡例）を非表示
        rssiChartView.pinchZoomEnabled = false // ピンチズーム不可
        rssiChartView.doubleTapToZoomEnabled = false // ダブルタップズーム不可
        rssiChartView.highlightPerTapEnabled = false
        rssiChartView.extraTopOffset = 20 // 上から20pxオフセットすることで上の方にある値(99.0)を表示する
        rssiChartView.noDataText = "Keep Waiting" //Noデータ時に表示する文字
        rssiChartView.chartDescription.text = "RSSI Chart"
        rssiChartView.chartDescription.textColor = .white
        
        
        
        
        //chartView.animate(xAxisDuration: 2) // 2秒かけて左から右にグラフをアニメーションで表示する
        
        //view.addSubview(chartView)
    }
    
//    func displayChart(data: [Double]) {
//            // グラフの範囲を指定する
//        //rssiChartView = LineChartView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 100))
//
//            // プロットデータ(y軸)を保持する配列
//            var dataEntries = [ChartDataEntry]()
//
//            for (xValue, yValue) in data.enumerated() {
//                let dataEntry = ChartDataEntry(x: Double(xValue), y: yValue)
//                dataEntries.append(dataEntry)
//            }
//            // グラフにデータを適用
//        chartDataSet = LineChartDataSet(entries: dataEntries, label: "SampleDataChart")
//
//            chartDataSet.lineWidth = 5.0 // グラフの線の太さを変更
//            chartDataSet.mode = .cubicBezier // 滑らかなグラフの曲線にする
//
//        rssiChartView.data = LineChartData(dataSet: chartDataSet)
//
//            // X軸(xAxis)
//        rssiChartView.xAxis.labelPosition = .bottom // x軸ラベルをグラフの下に表示する
//
//            // Y軸(leftAxis/rightAxis)
//        rssiChartView.leftAxis.axisMaximum = 100 //y左軸最大値
//        rssiChartView.leftAxis.axisMinimum = 0 //y左軸最小値
//        rssiChartView.leftAxis.labelCount = 6 // y軸ラベルの数
//        rssiChartView.rightAxis.enabled = false // 右側の縦軸ラベルを非表示
//
//            // その他の変更
//        rssiChartView.highlightPerTapEnabled = false // プロットをタップして選択不可
//        rssiChartView.legend.enabled = false // グラフ名（凡例）を非表示
//        rssiChartView.pinchZoomEnabled = false // ピンチズーム不可
//        rssiChartView.doubleTapToZoomEnabled = false // ダブルタップズーム不可
//        rssiChartView.extraTopOffset = 20 // 上から20pxオフセットすることで上の方にある値(99.0)を表示する
//
//        rssiChartView.animate(xAxisDuration: 2) // 2秒かけて左から右にグラフをアニメーションで表示する
//
//            //view.addSubview(rssiChartView)
//        }
    
}

extension RSSIGrapheViewController{
    
    func style(){
        
        topview.backgroundColor =  UIColor.appColor
        topview.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.backgroundColor = UIColor.appColor
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Welcome"
        label.font = UIFont.preferredFont(forTextStyle: .title1)
        label.textColor = .white
        
        rssiChartView.translatesAutoresizingMaskIntoConstraints = false
        
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        bottomView.backgroundColor =  UIColor.appColor
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .preferredFont(forTextStyle: .title2, compatibleWith: nil)
        titleLabel.text = (bluetoothService.connectPeripheral.name != nil) ? bluetoothService.connectPeripheral.name : "no name"
//        if titleLabel.text!.count > 15 {
//            titleLabel.font = .preferredFont(forTextStyle: .subheadline, compatibleWith: nil)
//        }
        titleLabel.textColor = .white
        
        deviceNameLabel.translatesAutoresizingMaskIntoConstraints = false
        deviceNameLabel.text = "Device Name"
        deviceNameLabel.textColor = .white
        
        
        disconnectButton.translatesAutoresizingMaskIntoConstraints = false
        
        //disconnectButton.setTitle("disconnect", for: .normal)
        disconnectButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        disconnectButton.tintColor = .white
        //disconnectButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        disconnectButton.backgroundColor =  UIColor.appColor
        disconnectButton.setTitleColor(UIColor.white, for: .normal)
        disconnectButton.addTarget(self, action: #selector(disconnectButtonTup), for: .primaryActionTriggered)
        
        
        
        
        
        //statusLabel.translatesAutoresizingMaskIntoConstraints = false
        //statusLabel.text = "Connected"
        
        startStopButton.translatesAutoresizingMaskIntoConstraints = false
        startStopButton.setImage(UIImage(systemName: "pause.circle"), for: .normal)
        startStopButton.tintColor = .white
        startStopButton.setTitle("pause", for: .normal)
        startStopButton.titleLabel?.adjustsFontSizeToFitWidth = true
        startStopButton.addTarget(self, action: #selector(startStopButtonTup), for: .primaryActionTriggered)
        startStopButton.setTitleColor(UIColor.white, for: .normal)
//        startStopButton.imageView?.contentMode = .scaleAspectFit
//        startStopButton.contentHorizontalAlignment = .fill // オリジナルの画像サイズを超えて拡大（水平）
//        startStopButton.contentVerticalAlignment = .fill // オリジナルの画像サイズを超えて拡大(垂
        
        exportButton.translatesAutoresizingMaskIntoConstraints = false
        exportButton.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        exportButton.tintColor = .white
        exportButton.setTitle("Export", for: .normal)
        exportButton.addTarget(self, action: #selector(exportButtonTup), for: .primaryActionTriggered)
        exportButton.setTitleColor(UIColor.white, for: .normal)
//        exportButton.imageView?.contentMode = .scaleAspectFit
//        exportButton.contentHorizontalAlignment = .fill // オリジナルの画像サイズを超えて拡大（水平）
//        exportButton.contentVerticalAlignment = .fill // オリジナルの画像サイズを超えて拡大(垂
        
        snapshotButton.translatesAutoresizingMaskIntoConstraints = false
        snapshotButton.setImage(UIImage(systemName: "camera"), for: .normal)
        snapshotButton.setTitle("Snap", for: .normal)
        snapshotButton.tintColor = .white
        snapshotButton.addTarget(self, action: #selector(snapshotButtonTup), for: .primaryActionTriggered)
        snapshotButton.setTitleColor(UIColor.white, for: .normal)
//        snapshotButton.imageView?.contentMode = .scaleAspectFit
//        snapshotButton.contentHorizontalAlignment = .fill // オリジナルの画像サイズを超えて拡大（水平）
//        snapshotButton.contentVerticalAlignment = .fill // オリジナルの画像サイズを超えて拡大(垂
        
        bottomStackView.translatesAutoresizingMaskIntoConstraints = false
        bottomStackView.axis = .horizontal
        bottomStackView.spacing = 30
        bottomStackView.backgroundColor =  UIColor.appColor
        bottomStackView.distribution = .fillEqually
        
//        startStopButton.backgroundColor =  UIColor.blu2eColor
//        snapshotButton.backgroundColor = UIColor.blu2eColor
//        exportButton.backgroundColor =  UIColor.blu2eColor
        disconnectButton.neumorphicLayer?.elementDepth = 2
        startStopButton.neumorphicLayer?.elementDepth = 2
        snapshotButton.neumorphicLayer?.elementDepth = 2
        exportButton.neumorphicLayer?.elementDepth = 2

        disconnectButton.neumorphicLayer?.elementBackgroundColor = UIColor.appColor.cgColor
        startStopButton.neumorphicLayer?.elementBackgroundColor = UIColor.appColor.cgColor
        snapshotButton.neumorphicLayer?.elementBackgroundColor = UIColor.appColor.cgColor
        exportButton.neumorphicLayer?.elementBackgroundColor = UIColor.appColor.cgColor

        disconnectButton.layer.cornerRadius = 20

        startStopButton.layer.cornerRadius = 25
        snapshotButton.layer.cornerRadius = 25
        exportButton.layer.cornerRadius = 25

     
        guideLabel.text = BLE_CONNECTED_AND_READING
        //guideLabel.text = BLE_DISCONNECTED
        guideLabel.numberOfLines = 0
        guideLabel.translatesAutoresizingMaskIntoConstraints = false
        guideLabel.textAlignment = .center
        guideLabel.textColor = .white
        guideLabel.backgroundColor =  UIColor.appColor
        
        grapheGuideLabel.text = GRAPH_GUIDE_LABEL
        grapheGuideLabel.translatesAutoresizingMaskIntoConstraints = false
        grapheGuideLabel.textAlignment = .center
        grapheGuideLabel.textColor = .lightGray
        grapheGuideLabel.backgroundColor =  UIColor.appColor
        
        captureAnimationView.backgroundColor = .white
        captureAnimationView.isHidden = true
        captureAnimationView.translatesAutoresizingMaskIntoConstraints = false
        
        chartXLabel.translatesAutoresizingMaskIntoConstraints = false
        chartXLabel.text = "[sec]"
        chartXLabel.textColor = .white
        chartXLabel.font = .preferredFont(forTextStyle: .caption1, compatibleWith: nil)
        chartXLabel.isHidden = true
        
        chartYLabel.translatesAutoresizingMaskIntoConstraints = false
        chartYLabel.text = "[dbm]"
        chartYLabel.textColor = .white
        chartYLabel.font = .preferredFont(forTextStyle: .caption1, compatibleWith: nil)
        chartYLabel.isHidden = true

        
        
        graphBackground.translatesAutoresizingMaskIntoConstraints = false
        graphBackground.backgroundColor = .appColor
        graphBackground.layer.cornerRadius = 10
        
        graphBackground.neumorphicLayer?.elementBackgroundColor = graphBackground.backgroundColor!.cgColor
        graphBackground.neumorphicLayer?.cornerRadius = 10
        // set convex or concave.
        graphBackground.neumorphicLayer?.depthType = .convex
        // set elementDepth (corresponds to shadowRadius). Default is 5
        graphBackground.neumorphicLayer?.elementDepth = 2
        
        
    }
    
    @objc func snapshotButtonTup(){
        
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            if PHPhotoLibrary.authorizationStatus() != .authorized{
                // フォトライブラリへのアクセスが許可されていないため、アラートを表示する
                DispatchQueue.main.async {
                let alert = UIAlertController(title: "Permission is not authorised", message: "Please enable PhotoLibraly access Permission to save Screenshot", preferredStyle: .alert)
                let settingsAction = UIAlertAction(title: "Settings", style: .default, handler: { (_) -> Void in
                    guard let settingsURL = URL(string: UIApplication.openSettingsURLString ) else {
                        return
                    }
                    UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
                })
                let closeAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                alert.addAction(settingsAction)
                alert.addAction(closeAction)
                self.present(alert, animated: true, completion: nil)
                }
            }else{
                AudioServicesPlaySystemSound(1108);
                DispatchQueue.main.async {
                    self.captureAnimationView.isHidden = false
                    self.captureAnimationView.alpha = 1
                    UIView.animate(withDuration: 0.5) {
                        self.captureAnimationView.alpha = 0
                    } completion: { Bool in
                        self.captureAnimationView.isHidden = true
                    }
                    
                    //キャプチャ取得.変数screenshotにUIImageが保存されます
                    let layer = UIApplication.shared.keyWindow!.layer
                    let scale = UIScreen.main.scale
                    UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale);
                    
                    layer.render(in: UIGraphicsGetCurrentContext()!)
                    let screenshot = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext();
                    
                    //キャプチャ画像をフォトアルバムへ保存
                    UIImageWriteToSavedPhotosAlbum(screenshot!, nil, nil, nil);
                    
                }
            }
        }
    }
    
    @objc func exportButtonTup(){
        let alertController = UIAlertController(title:"Save File Name", message:"Prease input csv file name", preferredStyle: UIAlertController.Style.alert)
        
        alertController.addTextField()
        if let textField = alertController.textFields?.first {
            textField.text?.append(titleLabel.text!)
            
            let dt = Date()
            let dateFormatter = DateFormatter()
            // DateFormatter を使用して書式とロケールを指定する
            dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yMMMdHms", options: 0, locale: Locale(identifier: Locale.preferredLanguages.first!))

            print(dateFormatter.string(from: dt))
            textField.text?.append("_")
            textField.text?.append(dateFormatter.string(from: dt))
        }
        
        let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { (action: UIAlertAction) in
            if let textField = alertController.textFields?.first {
                //self.myLabel.text = textField.text
                self.createFile(fileName: textField.text!, fileArrData: self.nowRssiDatas)
                
            }
        }
        alertController.addAction(okButton)
        
        let cancelButton = UIAlertAction(title: "cancel", style: UIAlertAction.Style.cancel, handler:nil)
        alertController.addAction(cancelButton)
        
        present(alertController, animated:true, completion: nil)
        
    }
    @objc func disconnectButtonTup(sender:UIButton){
        dismiss(animated: true)
    }
    
    @objc func startStopButtonTup(sender:UIButton){
        
        switch sender.titleLabel!.text {
        case "start":
            startStopButton.setTitle("pause", for: .normal)
            startStopButton.setImage(UIImage(systemName:"pause.circle"), for: .normal)
            guideLabel.text = BLE_CONNECTED_AND_READING
            isChartOn = true
        case "pause":
            startStopButton.setTitle("start", for: .normal)
            startStopButton.setImage(UIImage(systemName:"play.circle"), for: .normal)
            guideLabel.text = BLE_CONNECTED_AND_NOT_READING
            isChartOn = false
        case "Reconnect":
            bluetoothService.reconnectPeripheral()

        default :
            print("start stopButton tup exception")
        }
        
        
    }
    
    //多次元配列からDocuments下にCSVファイルを作る
    func createFile(fileName : String, fileArrData : [Double]){
        
        let dt = Date()
        let dateFormatter = DateFormatter()

        // DateFormatter を使用して書式とロケールを指定する
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yMMMdHms", options: 0, locale: Locale(identifier: Locale.preferredLanguages.first!))

        
        //let filePath = NSHomeDirectory() + "/Documents/" + fileName + "_\(dateFormatter.string(from: dt))" + ".csv"
        let filePath = NSHomeDirectory() + "/Documents/" + fileName + ".csv"
        print(filePath)
        var fileStrData:String = ""
        
        fileStrData += "time(sec)"
        fileStrData += ","
        fileStrData += "dbm"
//        if let offset = rssiOffset{
//            fileStrData += ","
//            fileStrData += "オフセットRSSI:\(offset)dbm"
//
//            //if let delta = startPedometerDeltaRssi{
//                fileStrData += ","
//                fileStrData += "デルタRSSI:\(startPedometerDeltaRssi)dbm"
//                fileStrData += ","
//                fileStrData += "切断閾値RSSI:\(offset + startPedometerDeltaRssi)dbm"
//
//            //}
//
//        }
       
//        if timerTimingTups.count > 0{
//            var count = 1
//            for timing in timerTimingTups{
//                fileStrData += ","
//                fileStrData += "時間記録\(count)回目:\(timing)秒"
//                count += 1
//            }
//        }
        

        
        
        fileStrData += "\n"

        
        
        //StringのCSV用データを準備
        for count in 0...fileArrData.count{
            if count < fileArrData.count{
                fileStrData += "\(count + 1)"
                fileStrData += ","
                fileStrData += String(fileArrData[count])
                fileStrData += "\n"
            }
        }
        print(fileStrData)
        
        do{
            try fileStrData.write(toFile: filePath, atomically: true, encoding: String.Encoding.utf8)
            print("Success to Wite the File")
            
            //ファイルの共有はUIActivityViewControllerでやる
            print("filePath:\(filePath)")
            sendFile(fileURL: URL.init(fileURLWithPath: filePath))
            
        }catch let error as NSError{
            print("Failure to Write File\n\(error)")
        }
    }
    
    func sendFile(fileURL: URL) {
        let activityViewController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }
    
    func layout(){
        
        //topview.addSubview(titleLabel)
        topview.addSubview(deviceNameLabel)
        //topview.addSubview(disconnectButton)
        
       
        //topview.addSubview(statusLabel)
        
        bottomView.addSubview(bottomStackView)
        bottomView.addSubview(guideLabel)
        bottomStackView.addArrangedSubview(startStopButton)
        bottomStackView.addArrangedSubview(snapshotButton)
        bottomStackView.addArrangedSubview(exportButton)
        
        stackView.addArrangedSubview(topview)
        //stackView.addArrangedSubview(rssiChartView)
        stackView.addArrangedSubview(graphBackground)
        graphBackground.addSubview(rssiChartView)
        
        stackView.addArrangedSubview(bottomView)
        
        view.addSubview(stackView)
        view.addSubview(disconnectButton)
        view.addSubview(titleLabel)
        view.addSubview(grapheGuideLabel)
        
        view.addSubview(chartXLabel)
        view.addSubview(chartYLabel)
        
        view.addSubview(captureAnimationView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalToSystemSpacingBelow: view.topAnchor, multiplier: 1),
            stackView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 1),
            view.trailingAnchor.constraint(equalToSystemSpacingAfter: stackView.trailingAnchor, multiplier: 1),
            stackView.bottomAnchor.constraint(equalToSystemSpacingBelow: view.bottomAnchor, multiplier: 1),
        
        ])
        
        NSLayoutConstraint.activate([
            topview.heightAnchor.constraint(equalToConstant: 44),
            topview.topAnchor.constraint(equalTo: stackView.topAnchor),
            topview.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            topview.rightAnchor.constraint(equalTo: stackView.rightAnchor)
            
        ])
        
//        NSLayoutConstraint.activate([
//            rssiChartView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
//            rssiChartView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor)
//        ])
        
        NSLayoutConstraint.activate([
            graphBackground.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            graphBackground.trailingAnchor.constraint(equalTo: stackView.trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            rssiChartView.topAnchor.constraint(equalToSystemSpacingBelow: graphBackground.topAnchor, multiplier: 1),
            rssiChartView.leadingAnchor.constraint(equalToSystemSpacingAfter: graphBackground.leadingAnchor, multiplier: 1),
            graphBackground.trailingAnchor.constraint(equalToSystemSpacingAfter: rssiChartView.trailingAnchor, multiplier: 1),
            graphBackground.bottomAnchor.constraint(equalToSystemSpacingBelow: rssiChartView.bottomAnchor, multiplier: 2)
            
            
//            rssiChartView.topAnchor.constraint(equalTo: graphBackground.topAnchor),
//            rssiChartView.bottomAnchor.constraint(equalTo: graphBackground.bottomAnchor),
//            rssiChartView.leadingAnchor.constraint(equalTo: graphBackground.leadingAnchor),
//            rssiChartView.trailingAnchor.constraint(equalTo: graphBackground.trailingAnchor),
        ])
        
        
        
        
        
        NSLayoutConstraint.activate([
            bottomView.heightAnchor.constraint(equalToConstant: 120),
            bottomView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor)
        ])
        
        //topView関連
        NSLayoutConstraint.activate([
            //disconnectButton.centerYAnchor.constraint(equalTo: topview.centerYAnchor),
            disconnectButton.topAnchor.constraint(equalToSystemSpacingBelow: view.topAnchor, multiplier: 1 ),
            disconnectButton.leadingAnchor.constraint(equalToSystemSpacingAfter: topview.leadingAnchor, multiplier: 0.5),
            
            disconnectButton.widthAnchor.constraint(equalToConstant: 40),
            disconnectButton.heightAnchor.constraint(equalToConstant: 40)

        ])
        
        NSLayoutConstraint.activate([
            //deviceNameLabel.centerYAnchor.constraint(equalTo: topview.centerYAnchor),
            deviceNameLabel.topAnchor.constraint(equalToSystemSpacingBelow: topview.topAnchor, multiplier:0 ),
            deviceNameLabel.centerXAnchor.constraint(equalTo: topview.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalToSystemSpacingBelow: deviceNameLabel.bottomAnchor, multiplier: 0.5),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
        
        NSLayoutConstraint.activate([
            grapheGuideLabel.topAnchor.constraint(equalToSystemSpacingBelow: titleLabel.bottomAnchor, multiplier: 2),
            grapheGuideLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
        
        
        NSLayoutConstraint.activate([
            chartXLabel.topAnchor.constraint(equalTo: rssiChartView.bottomAnchor),
            view.trailingAnchor.constraint(equalToSystemSpacingAfter: chartXLabel.trailingAnchor, multiplier: 2)
        ])
        
        NSLayoutConstraint.activate([
            chartYLabel.topAnchor.constraint(equalToSystemSpacingBelow: rssiChartView.topAnchor, multiplier: 0),
            chartYLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 1.5)
        ])
        
        
        NSLayoutConstraint.activate([
            bottomStackView.topAnchor.constraint(equalTo: bottomView.topAnchor),
            bottomStackView.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor),
            bottomStackView.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor),
            bottomStackView.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        NSLayoutConstraint.activate([
            guideLabel.topAnchor.constraint(equalToSystemSpacingBelow: bottomStackView.bottomAnchor, multiplier: 1),
            guideLabel.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor),
            guideLabel.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor),
            //guideLabel.bottomAnchor.constraint(equalTo: bottomView.bottomAnchor),
        ])
        
        NSLayoutConstraint.activate([
            captureAnimationView.topAnchor.constraint(equalTo: view.topAnchor),
            captureAnimationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            captureAnimationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            captureAnimationView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
    }
    
}



