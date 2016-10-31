//
//  mainViewController.swift
//  Sono
//
//  Created by Amr Guzlan on 2016-10-01.
//  Copyright © 2016 Amro Gazlan. All rights reserved.
//

import UIKit

class mainViewController :UIViewController, EmpaticaDelegate , EmpaticaDeviceDelegate{
  
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
            (devices[0] as! EmpaticaDeviceManager).connect(with: self)
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
}
