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
    @IBOutlet weak var uploadStatusLog: UITextView!
    @IBAction func reuploadBtn(_ sender: AnyObject) {
        reupload()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("View Did appear")
//        DropboxClientsManager.authorizeFromController(UIApplication.shared,
//                                                      controller: self,
//                                                      openURL: { (url: URL) -> Void in
//                                                        UIApplication.shared.openURL(url)
//        })
        //Reference after programmatic auth flow
//        client = DropboxClientsManager.authorizedClient
        //
        
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("View Did appear")
        uploadStatusLog.text = ""
        //self.uploadStatusLabel.text = ""
        if let client = DropboxClientsManager.authorizedClient{
            //Perform some stuff
            print("Opening a new file")
            //self.fileToUploadPath = writeToFile(stringToWrite: "")
        }
        else{
            authenticate()
            print("Authenticating")
        }
        
        //uploadTest()
        
        uploadToDropBox(readings: bvpReading!, ofReadingType: .bvp)
        uploadToDropBox(readings: tempReading!, ofReadingType: .temperature)
        uploadToDropBox(readings: ibiReading!, ofReadingType: .ibi)
        uploadToDropBox(readings: hrReading!, ofReadingType: .hr)
        uploadToDropBox(readings: gsrReading!, ofReadingType: .gsr)
        //self.uploadStatusLog.text.append("DONE!\n")
    }

    func authenticate() {
        DropboxClientsManager.authorizeFromController(UIApplication.shared,
                                                      controller: self,
                                                      openURL: { (url: URL) -> Void in UIApplication.shared.openURL(url)},
                                                      browserAuth : false)
    }
    
    func reupload(){
        uploadStatusLog.text = ""
        uploadToDropBox(readings: bvpReading!, ofReadingType: .bvp)
        uploadToDropBox(readings: tempReading!, ofReadingType: .temperature)
        uploadToDropBox(readings: ibiReading!, ofReadingType: .ibi)
        uploadToDropBox(readings: hrReading!, ofReadingType: .hr)
        uploadToDropBox(readings: gsrReading!, ofReadingType: .gsr)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func uploadTest(){
        print("Upload test")
        let fileData = "testing data example".data(using: String.Encoding.utf8, allowLossyConversion: false)!
        
        if let client = DropboxClientsManager.authorizedClient {
            let request = client.files.upload(path: "/hello/test.txt", input: fileData)
                .response { response, error in
                    if let response = response {
                        print(response)
                    } else if let error = error {
                        print(error)
                    }
                }
                .progress { progressData in
                    print(progressData)
            }
        }
        
        // in case you want to cancel the request
//        if someConditionIsSatisfied {
//            request.cancel()
//        }
    }
    
    
    func uploadToDropBox(readings: Data, ofReadingType : ReadingType){
        print("In upload prompt")
        let date = NSDate()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        let day = formatter.string(from: date as Date)
        let calendar = NSCalendar.current
        let hour = calendar.component(.hour, from: date as Date)
        let minutes = calendar.component(.minute, from: date as Date)
        let year = calendar.component(.year, from: date as Date)
        let month = calendar.component(.month, from: date as Date)
        let csvName = "\(year)- \(month)-\(day) \(hour)h\(minutes)\(ofReadingType.rawValue)"
        let folderName = "\(day) \(hour)h\(minutes)"
        
        //uploadStatusLabel.text = "uploading \(ofReadingType.rawValue)"
        
        if let client = DropboxClientsManager.authorizedClient {
            let request = client.files.upload(path: "/\(folderName)/\(csvName)", input: readings)
                .response{ response, error in
                    if let response = response{
                        print (response)
                        self.uploadStatusLog.text.append("Successfully uploaded \(ofReadingType.rawValue) \n")
                        //self.uploadStatusLabel.textColor = UIColor.green
                    }else if let error = error {
                        print (error)
                        self.uploadStatusLog.text.append("Failed to upload \(ofReadingType.rawValue) \n")
                    }
                }
                .progress{ progressData in
                    print ("The progress data is \(progressData)")
            }
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
