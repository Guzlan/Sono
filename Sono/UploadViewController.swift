//
//  UploadViewController.swift
//  Sono
//
//  Created by Amr Guzlan on 2016-11-30.
//  Copyright © 2016 Amro Gazlan. All rights reserved.
//

import UIKit
import SwiftyDropbox

enum ReadingType : String {
    case temperature  = "temperature.csv"
    case ibi = "ibi.csv"
    case bvp = "bvp.csv"
    case hr = "hr.csv"
    case gsr = "gsr.csv"
}
class UploadViewController: UIViewController {
    var client : DropboxClient?
    var tempReading : Data?
    var ibiReading: Data?
    var bvpReading : Data?
    var hrReading : Data?
    var gsrReading : Data?
    @IBAction func closeViewController(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DropboxClientsManager.authorizeFromController(UIApplication.shared,
                                                      controller: self,
                                                      openURL: { (url: URL) -> Void in
                                                        UIApplication.shared.openURL(url)
        })
        //Reference after programmatic auth flow
        client = DropboxClientsManager.authorizedClient
        uploadToDropBox(readings: bvpReading!, ofReadingType: .bvp)
        uploadToDropBox(readings: tempReading!, ofReadingType: .temperature)
        uploadToDropBox(readings: ibiReading!, ofReadingType: .ibi)
        uploadToDropBox(readings: hrReading!, ofReadingType: .hr)
        uploadToDropBox(readings: gsrReading!, ofReadingType: .gsr)
        //
        
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    override func viewDidAppear(_ animated: Bool) {
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func uploadToDropBox(readings: Data, ofReadingType : ReadingType){
        let date = NSDate()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        let day = formatter.string(from: date as Date)
        let calendar = NSCalendar.current
        let hour = calendar.component(.hour, from: date as Date)
        let minutes = calendar.component(.minute, from: date as Date)
        let csvName = "\(hour):\(minutes)-\(day)-\(ofReadingType.rawValue)"
        let request = client?.files.upload(path: "/\(csvName)", input: readings)
            .response{ response, error in
                if let response = response{
                    print (response)
                }else if let error = error {
                    print (error)
                }
            }
            .progress{ progressData in
                print ("The progress data is \(progressData)")
        }
        
        
        
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
