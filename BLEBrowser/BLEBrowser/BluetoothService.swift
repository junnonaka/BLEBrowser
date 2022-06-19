//
//  BluetoothService.swift
//  ble_test_app
//
//  Created by 野中淳 on 2021/03/27.
//  Copyright © 2021 野中淳. All rights reserved.
//

import Foundation
import CoreBluetooth
import UIKit

//外部から参照出来る用にNSObjectを継承
class BluetoothService: NSObject {
    
    static let shared = BluetoothService()
    
    private var isInitBluetooth = false
    private var centralManager:CBCentralManager!
    var connectPeripheral:CBPeripheral!
    private var isUpdatePeripheral = false
    
    private var bleScanTimer:Timer!
    
    var isScaning = false

    
    var bleDevices:[BLEDevice]!
    
    private var readedRssi = 0

    
    override init() {
        self.centralManager = CBCentralManager()
        
    }
    
    func setupBluetooth(){
        centralManager = CBCentralManager(delegate: self, queue: nil, options: nil)
        isInitBluetooth = true
    }
    
    func isInitBluetoothfunc()->Bool{
        return isInitBluetooth    }
    
    /// 該当のペリフェラルを探索スキャン開始
    func startBluetoothScanTimer() {
        isScaning = true
        print("スキャン開始")
        bleScanTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { timer in
            self.stopBluetoothScan()
            self.blutoothScan()
        }
    }
    
    func stopBluetoothScanTimer(){
        isScaning = false
        bleScanTimer.invalidate()
        stopBluetoothScan()
    }
    
    //スキャン開始
    func blutoothScan(){
        if self.centralManager.isScanning == false {
            self.centralManager.scanForPeripherals(withServices: nil, options: nil)
        }
    }
    
    
    /// スキャン停止
    func stopBluetoothScan() {
        self.centralManager.stopScan()
    }
    
    /// 機器に接続
    func connectPeripheral(num:Int) {
        connectPeripheral = bleDevices[num].peripheral
        self.centralManager.connect(connectPeripheral, options: nil)
    }
    
    
    func cancelConect(){
        self.centralManager.cancelPeripheralConnection(connectPeripheral)
    }
    /// 機器に切断
    func disconnectPeripheral() {
        self.centralManager.cancelPeripheralConnection(connectPeripheral)
    }
    
    func reconnectPeripheral(){
        self.centralManager.connect(connectPeripheral, options: nil)
    }
    
    func readRssi()->Int{
        connectPeripheral.readRSSI()
        return readedRssi
    }
    
}

extension BluetoothService:CBCentralManagerDelegate{
    
    /// Bluetoothのステータスを取得する(CBCentralManagerの状態が変わる度に呼び出される)
    ///
    /// - Parameter central: CBCentralManager
    //BLEの電源ONが通知されるメソッドに使用
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        switch central.state {
        //centralManagerの初期化時にPoweredOnが呼ばれる
        //スキャン開始はPoweredOnの後である必要がある
        case CBManagerState.poweredOn:
            print("Bluetooth PowerON")
            // 通知を送りたい箇所でこのように記述
            NotificationCenter.default.post(name: .notifyBlePowerOn, object: nil)
            //self.startBluetoothScanTimer()
            break
        case CBManagerState.poweredOff:
            print("Bluetooth PoweredOff")
            break
        case CBManagerState.resetting:
            print("Bluetooth resetting")
            break
        case CBManagerState.unauthorized:
            print("Bluetooth unauthorized")
            break
        case CBManagerState.unknown:
            print("Bluetooth unknown")
            break
        case CBManagerState.unsupported:
            print("Bluetooth unsupported")
            break
        @unknown default:
            fatalError("Blutooth is Broken")
        }
    }
    
    /// スキャン結果取得
    ///
    /// - Parameters:
    ///   - central: CBCentralManager
    ///   - peripheral: CBPeripheral
    ///   - advertisementData: アドバタイズしたデータを含む辞書型
    ///   - RSSI: 周辺機器の現在の受信信号強度インジケータ（RSSI）（デシベル単位）
    /// ペリフェラルを発見すると呼ばれる
    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {
        //peripheralの内容確認
        //print("uuid",peripheral.identifier)
        
        if bleDevices == nil {
            bleDevices = [BLEDevice(peripheral: peripheral, rssi: RSSI,advertisementData: advertisementData)]
        }else{
            for num in 0...bleDevices.count - 1{
                if bleDevices[num].peripheral.identifier.uuidString == peripheral.identifier.uuidString{
                    bleDevices[num].rssi = RSSI
                    isUpdatePeripheral = true
                    //print("update peripheral")
                    NotificationCenter.default.post(name: .notifyBlePeripheralUpdate, object: nil,userInfo: ["bleDeviceCount":num])
                }
            }
            if isUpdatePeripheral == false{
                bleDevices.append(BLEDevice(peripheral: peripheral, rssi: RSSI,advertisementData: advertisementData))
                NotificationCenter.default.post(name: .notifyBlePeripheralCountUpdate, object: nil)

            }
            isUpdatePeripheral = false
        }
        // 通知を送りたい箇所でこのように記述
        NotificationCenter.default.post(name: .notifyBleScanFinded, object: nil,userInfo: ["RSSI":RSSI])
        
    }
    
    /// 接続成功時
    ///
    /// - Parameters:
    ///   - central: CBCentralManager
    ///   - peripheral: CBPeripheral
    /// 接続されると呼ばれる
    func centralManager(_ central: CBCentralManager,
                        didConnect peripheral: CBPeripheral) {
        
        
        print("Connected")
        peripheral.delegate = self
//        print("接続後サービスUUIDの検索")
//        
//        print("uuid",peripheral.identifier)
//        print("name:",peripheral.name)
//        print("services:",peripheral.services)
//        print("prripheral:",peripheral)
//        print("state:",peripheral.state)
//        print("UUID:",peripheral.identifier)
//        print("delegate:",peripheral.delegate)
        
        // 通知を送りたい箇所でこのように記述
        NotificationCenter.default.post(name: .notifyBleConnected, object: nil)
        self.stopBluetoothScan()
    }
    /// 接続切断時
    ////
    /// - Parameters:
    ///   - central: CBCentralManager
    ///   - peripheral: CBPeripheral
    ///   - error: Error
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
        print("接続切断：\(String(describing: error))")
        // 通知を送りたい箇所でこのように記述
        NotificationCenter.default.post(name: .notifyBleDisconnected, object: nil)
    }
}

extension BluetoothService:CBPeripheralDelegate{
    //RSSIの取得
    func peripheral(_ peripheral: CBPeripheral,didReadRSSI RSSI: NSNumber,error: Error?){
        print("RSSI",RSSI.intValue)
        readedRssi = RSSI.intValue
        
    }
    
}
extension Notification.Name {
    static let notifyBleConnected = Notification.Name("notifyBleConnected")
    static let notifyBleDisconnected = Notification.Name("notifyBleDisconnected")
    static let notifyBleDataReceived = Notification.Name("notifyBleDataReceived")
    static let notifyBleScanFinded = Notification.Name("notifyBleScanFined")
    static let notifyBlePowerOn = Notification.Name("notifyBlePowerOn")
    static let notifyBlePeripheralCountUpdate = Notification.Name("notifyBlePeripheralCountUpdate")
    static let notifyBlePeripheralUpdate = Notification.Name("notifyBlePeripheralUpdate")

}
