//
//  mainViewController.swift
//  Sono
//
//  Created by Amr Guzlan on 2016-10-01.
//  Copyright © 2016 Amro Gazlan. All rights reserved.
//

import UIKit

class mainViewController :UIViewController, EmpaticaDelegate , EmpaticaDeviceDelegate{
    var settingsBarButton : UIBarButtonItem?
    var device : EmpaticaDeviceManager?
    
    @IBAction func scanDevices(_ sender: UIButton) {
        print("Started scanning for E4's...")
       
        EmpaticaAPI.discoverDevices(with: self)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func didDiscoverDevices(_ devices: [Any]!) {
        if devices.count > 0 {
            print("I was able to find \(devices.count)")
            if let foundDevice =  (devices[0] as? EmpaticaDeviceManager){
                device = foundDevice
                performSegue(withIdentifier: "displayGraphsSegue", sender: nil)
            }
        }
        else{
            print("I was not able to find devices")
        }
    }
    func didUpdate(_ status: BLEStatus) {
        switch status {
        case kBLEStatusNotAvailable:
            print("TURN ON YOUR BLUETOOTH YOU DICK!")
        case kBLEStatusReady:
            print("Finished scanning")
        case kBLEStatusScanning:
            print("Currently scanning")
        default:
            print ("No idea about the status")
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "displayGraphsSegue"{
            let destinationVC = segue.destination as! GraphCollectionViewController
               destinationVC.connectedE4 = device
            
        }
    }
//    func didReceiveAccelerationX(_ x: Int8, y: Int8, z: Int8, withTimestamp timestamp: Double, fromDevice device: EmpaticaDeviceManager!) {
//        print("(\(x),\(y),\(z))")
//    }
}
