//
//  ViewController.swift
//  HR Monitor App
//
//  Created by Zackarin Necesito on 3/4/19.
//  Copyright © 2019 Zack Necesito. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CoreBluetooth
let heartRateServiceCBUUID = CBUUID(string: "0x180D")
let heartRateMeasurementCharacteristicCBUUID = CBUUID(string: "2A37")
let bodySensorLocationCharacteristicCBUUID = CBUUID(string: "2A38")

class MainViewController: UIViewController {

    @IBOutlet weak var BPMLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var stopButton: UIButton!
    
    var centralManager: CBCentralManager!
    var heartRatePeripheral: CBPeripheral!
    var category = Category()
    
    var heartRateList = [HeartRate]()
    var categoryList = [Category]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadItems()
        verifyCategory()
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        centralManager = CBCentralManager(delegate: self, queue: nil)

    }
    
    func verifyCategory() {
        
        category = Category(context: context)
        
        category.name = "Entry \(categoryList.count + 1)"
        
        categoryList.append(category)
        
        saveItems()
        
    }

    func onHeartRateReceived(_ heartRate: Int) {
        //UI
        BPMLabel.text = String(heartRate)
        print("BPM: \(heartRate)")
        
        //persisting data
        let newHeartRate = HeartRate(context: context)
        newHeartRate.heartRate = Int64(heartRate)
        newHeartRate.parentCategory = category
        
        heartRateList.append(newHeartRate)
        
        saveItems()
    }
    
    func saveItems(){
        do {
            try context.save()
        } catch  {
            print("Error: \(error)")
        }
    }

    func loadItems(){
        let request : NSFetchRequest<Category> = Category.fetchRequest()
        do {
            categoryList = try context.fetch(request)
        } catch  {
            print("Error fetching data: \(error)")
        }

    }
    
    @IBAction func stopButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension MainViewController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state{
        case .unknown:
            print("Central State is .unknown")
        case .resetting:
            print("Central State is .resetting")
        case .unsupported:
            print("Central State is.unsupported")
        case .unauthorized:
            print("Central State is .unauthorized")
        case .poweredOff:
            print("Central State is .poweredOff")
        case .poweredOn:
            print("Central State is .poweredOn")
            centralManager.scanForPeripherals(withServices: [heartRateServiceCBUUID])

        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        print(peripheral)
        heartRatePeripheral = peripheral
        heartRatePeripheral.delegate = self
        centralManager.stopScan()
        centralManager.connect(heartRatePeripheral)
        
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected!")
        heartRatePeripheral.discoverServices([heartRateServiceCBUUID])
    }
    
}

extension MainViewController: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        
        for service in services {
            print(service)
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService,
                    error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            print(characteristic)
            if characteristic.properties.contains(.read) {
                print("\(characteristic.uuid): properties contains .read")
                peripheral.readValue(for: characteristic)
            }
            if characteristic.properties.contains(.notify) {
                print("\(characteristic.uuid): properties contains .notify")
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {
        switch characteristic.uuid {
        case bodySensorLocationCharacteristicCBUUID:
            let bodySensorLocation = bodyLocation(from: characteristic)
            locationLabel.text = bodySensorLocation
        case heartRateMeasurementCharacteristicCBUUID:
            let bpm = heartRate(from: characteristic)
            onHeartRateReceived(bpm)
        default:
            print("Unhandled Characteristic UUID: \(characteristic.uuid)")
        }
    }
    
    private func bodyLocation(from characteristic: CBCharacteristic) -> String {
        guard let characteristicData = characteristic.value,
            let byte = characteristicData.first else { return "Error" }
        
        switch byte {
        case 0: return "Other"
        case 1: return "Chest"
        case 2: return "Wrist"
        case 3: return "Finger"
        case 4: return "Hand"
        case 5: return "Ear Lobe"
        case 6: return "Foot"
        default:
            return "Reserved for future use"
        }
    }
    
    private func heartRate(from characteristic: CBCharacteristic) -> Int {
        guard let characteristicData = characteristic.value else { return -1 }
        let byteArray = [UInt8](characteristicData)
        
        let firstBitValue = byteArray[0] & 0x01
        if firstBitValue == 0 {
            // Heart Rate Value Format is in the 2nd byte
            return Int(byteArray[1])
        } else {
            // Heart Rate Value Format is in the 2nd and 3rd bytes
            return (Int(byteArray[1]) << 8) + Int(byteArray[2])
        }
    }
}

