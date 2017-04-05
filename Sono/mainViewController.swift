//
//  mainViewController.swift
//  Sono
//
//  Created by Amr Guzlan on 2016-10-01.
//  Copyright © 2016 Amro Gazlan. All rights reserved.
//

import UIKit
import DeviceKit

class mainViewController :UIViewController, EmpaticaDelegate , EmpaticaDeviceDelegate{
    var settingsBarButton : UIBarButtonItem?
    var device : EmpaticaDeviceManager?
    var segueDestination : String?
    var timer = Timer()
    var buttonColour = UIColor.white.cgColor
    
    @IBOutlet weak var scanStatusLabel: UILabel!
    @IBOutlet weak var senderBtn: UIButton!
    
    @IBAction func scanDevices(_ sender: UIButton) {
        print("Started scanning for E4's...")
        scanStatusLabel.text = "Scanning..."
        scanStatusLabel.textColor = UIColor.black
        EmpaticaAPI.discoverDevices(with: self)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackgroundColor()
        let borderColor = UIColor(red: 0.41, green: 1.28, blue: 1.85, alpha: 0.0)
        senderBtn.layer.borderWidth = 4
        senderBtn.layer.borderColor = borderColor.cgColor
        scanStatusLabel.text = ""
        let iOSDevice = Device()
        switch iOSDevice{
        case .iPhone6sPlus:
            print("This is a 6s plus")
        case .iPhone6:
            print("This is a 6")
        case .iPhone5c:
            print("this is a 5c")
        case .iPhone4:
            print("This is a 4")
        default:
            print("Not really sure what iOS device this is")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(animateButton), userInfo: nil, repeats: true)
    }
    
    func animateButton (){
        self.senderBtn.layer.borderWidth = 3.0
        let color: CABasicAnimation = CABasicAnimation(keyPath: "borderColor")
        color.fromValue = UIColor.clear.cgColor
        color.toValue = buttonColour
        color.duration = 1.5
        color.autoreverses = true
        self.senderBtn.layer.borderColor = UIColor.clear.cgColor
        self.senderBtn.layer.add(color, forKey: "")
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func didDiscoverDevices(_ devices: [Any]!) {
        if device?.deviceStatus != nil {
            if device?.deviceStatus == kDeviceStatusConnected {
                performSegue(withIdentifier: "displayGraphsSegue", sender: nil)
            }
        }
        if devices.count > 0 {
            print("I was able to find \(devices.count)")
            scanStatusLabel.text = "Success detecting Device"
            scanStatusLabel.textColor = UIColor.green
            buttonColour = UIColor.green.cgColor
            if let foundDevice =  (devices[0] as? EmpaticaDeviceManager){
                device = foundDevice
                performSegue(withIdentifier: "displayGraphsSegue", sender: nil)
            }
        }
        else{
            print("I was not able to find devices")
            scanStatusLabel.text = "Failed To Detect Device"
            scanStatusLabel.textColor = UIColor.red
            buttonColour = UIColor.red.cgColor
        }
    }
    func didUpdate(_ status: BLEStatus) {
        switch status {
        case kBLEStatusNotAvailable:
            print("TURN ON YOUR BLUETOOTH!")
            scanStatusLabel.text = "Please turn on your Bluetooth"
            scanStatusLabel.textColor = UIColor.black
        case kBLEStatusReady:
            print("Finished scanning")
        case kBLEStatusScanning:
            print("Currently scanning")
        default:
            print ("No idea about the status")
        }
    }
    func setBackgroundColor(){
        let bc = CAGradientLayer()
        let topColor = UIColor(colorLiteralRed: 0.325, green: 0.824, blue: 0.675, alpha: 1.00).cgColor
        let bottomColor = UIColor(colorLiteralRed: 0.129, green: 0.412, blue: 0.647, alpha: 1.00).cgColor
        bc.colors = [topColor, bottomColor]
        bc.locations = [0.0, 1.0]
        bc.frame = self.view.bounds
        self.view.layer.insertSublayer(bc, at: 0)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "displayGraphsSegue"{
            let destinationVC = segue.destination as! UITabBarController
             let viewControllersManaged = destinationVC.viewControllers
             let navigationController = viewControllersManaged?[0] as! UINavigationController
             let mainDestinationVc = navigationController.topViewController as! GraphCollectionViewController
            mainDestinationVc.connectedE4 = device
        }
    }

}
