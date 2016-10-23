//
//  BarViewController.swift
//  Sono
//
//  Created by Amr Guzlan on 2016-10-22.
//  Copyright © 2016 Amro Gazlan. All rights reserved.
//

import UIKit
import Charts

class BarViewController: UIViewController {

    @IBOutlet weak var barChartView: BarChartView!
    // will create some mock data
    var months: [String]?
    override func viewDidLoad() {
        super.viewDidLoad()
        months =  ["Amro", "Paul", "Mahmoud", "Zeyad"]
        let unitsSold = [20.0, 30.8, 23.5, 40.6]
        setChart(dataPoints: months!, values: unitsSold)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setChart(dataPoints: [String], values: [Double]){
//        var dataEntries : [BarChartDataEntry]
//        for i in 0..<dataPoints.count{
//            let dataEntry = BarChartDataEntry(x: Double(i), y: values[i])
//            dataEntries.append(dataEntry)
//        }
//        let chartDataSet = BarChartDataSet(values: dataEntries, label: "The ninja turtles")
//        let chartData = BarChartData()
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
