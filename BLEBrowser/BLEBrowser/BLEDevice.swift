//
//  BLEDevice.swift
//  BLEBrowser
//
//  Created by 野中淳 on 2022/06/10.
//

import Foundation
import CoreBluetooth
struct BLEDevice{
    let peripheral:CBPeripheral
    var rssi:NSNumber
    var advertisementData:[String:Any]
    var isReaded:Bool = false
}
