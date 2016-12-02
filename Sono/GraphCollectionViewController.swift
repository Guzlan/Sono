//
//  GraphCollectionViewController.swift
//  Sono
//
//  Created by Amr Guzlan on 2016-10-26.
//  Copyright © 2016 Amro Gazlan. All rights reserved.
//

import UIKit
import Charts

private let grapCellIdentifier = "GraphCell"
private let informationCellIdentifier = "InformationCell"

class GraphCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, EmpaticaDeviceDelegate{
    

    @IBAction func uploadButton(_ sender: Any) {
            performSegue(withIdentifier: "UploadSegue", sender: sender)
    }
    var tempReading : String?
    var gsrReading : String?
    var hrReading: String?
    var ibiReading: String?
    var bvpReading: String?
    
    var tempCounter = 0
    var gsrCounter = 0
    var hrCounter = 0
    var ibiCounter = 0
    var bvpCounter = 0
    
    var connectedE4  : EmpaticaDeviceManager?
    var graphs = [LineChartView]() // an array to store our graphs
    let noGraphDataMessages = ["No EA data", "No blood volume data", "No heart rate data", "No temperature data","No inter beat interval data"] //ORDER CHANGES HERE
    let tempGraph  = LineChartView() //our temperature graph
    let volumeGraph = LineChartView() //our volume graph
    let eaGraph = LineChartView() //our volume graph
    let heartRateGraph = LineChartView() //our volume graph
    let ibiGraph = LineChartView() //our volume graph
    var gradients = [CAGradientLayer]()
    
    let bvpQueue  = DispatchQueue(label: "bvp", qos: .userInitiated)
    let tempQueue  = DispatchQueue(label: "temp", qos: .userInitiated)
    let ibiQueue  = DispatchQueue(label: "ibi", qos: .userInitiated)
    let hrQueue  = DispatchQueue(label: "hr", qos: .userInitiated)
    let gsrQueue  = DispatchQueue(label: "gsr", qos: .userInitiated)
    
    
    
    //The following are dummy variables....MAHMOUD remove them and put your logic variables instead
//    let y =
//    let dollars1 =
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Graphs" // title of the navigation controller page
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: grapCellIdentifier) // register the reusable cell we have
        self.collectionView!.backgroundColor = UIColor(colorLiteralRed: 0.251, green: 0.251, blue: 0.251, alpha: 1.00)
        self.collectionView!.contentInset = UIEdgeInsetsMake(10, 0, 0, 0)
        tempReading = ("Time Stamp,Temperature\n")
        gsrReading = ("Time Stamp,Response\n")
        hrReading = ("Time Stamp, Heart Rate\n")
        ibiReading = ("Time Stamp,IBI\n")
        bvpReading = ("Time Stamp,BVP\n")
        
        //ORDER CHANGES HERE
        graphs.append(tempGraph) // add temperature graph to our graphs list
        graphs.append(volumeGraph)// add volume graph to our graphs list
        graphs.append(eaGraph) // add the electrodermal activity graph
        graphs.append(heartRateGraph) // add the heart rate graph
        graphs.append(ibiGraph) // add the inter beat interval graph
        setUp(graphs: graphs)
        setUpGradientBackground()
        connectedE4?.connect(with: self)
    }
    override func viewWillAppear(_ animated: Bool) {
             self.navigationController?.isToolbarHidden = false
             connectedE4?.connect(with: self)
    }
    //
    //
    //    // MARK: UICollectionViewDataSource
    //
    
    func setUp(graphs: [LineChartView]){
        
        for i in 0..<graphs.count{
//            graphs[i].layer.borderWidth = 1
//            graphs[i].layer.borderColor = UIColor.white.cgColor
            graphs[i].layer.cornerRadius = 10
            graphs[i].clipsToBounds = true
            graphs[i].noDataText = self.noGraphDataMessages[i]
            graphs[i].translatesAutoresizingMaskIntoConstraints = false
            graphs[i].xAxis.labelPosition = .bottom
            graphs[i].animate(xAxisDuration: 2.0)
            graphs[i].animate(yAxisDuration: 2.0)
            setChartData(forChart: graphs[i], withNumber: 0)
        }
        
    }
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row < 2{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GraphCell", for: indexPath)
            
            cell.addSubview(graphs[indexPath.row]) //ORDER CHANGES HERE
            // add constraints on the graph view inside it's cell. 0 padding from all sides
            cell.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[v0]-0-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":graphs[indexPath.row]]))
            cell.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[v0]-0-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":graphs[indexPath.row]]))
            gradients[indexPath.row].frame = cell.layer.bounds //ORDER CHANGES HERE
            cell.layer.insertSublayer(gradients[indexPath.row], at: 0)
            return cell
        }else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: informationCellIdentifier, for: indexPath)
            return cell
        }
    }
    
    
    func setChartData(forChart chart: LineChartView, withNumber num : Int){
//        chart.xAxis.labelPosition = .bottom
        var entries = [ChartDataEntry]()
        entries.append(ChartDataEntry(x:0, y:0))
//        for i in 0..<months.count{
//            entries.append(ChartDataEntry(x: Double(i), y: dollars1[i]))
//        }
//        
        let set = LineChartDataSet()
        set.values = entries
        
        
        // removing the right axis, we're only interested in the left axis
        let rightAxis = chart.getAxis(.right)
        rightAxis.drawAxisLineEnabled = false
        rightAxis.drawLabelsEnabled = false
        rightAxis.drawTopYLabelEntryEnabled = false
        rightAxis.drawLimitLinesBehindDataEnabled = false
        
        // customizing our data set, I think this is constant for all graphs .. we'll see
        set.setColor(UIColor.white) // line color
        //set.setCircleColor(UIColor.darkGray) // our circle will be dark red
        set.lineWidth = 1.5
        set.drawCirclesEnabled = false
        set.drawValuesEnabled = false
        //set.circleRadius = 4.0 // the radius of the node circle
        //set.fillAlpha = 65 / 255.0
        //set.fillColor = UIColor.orange
        //set.highlightColor = UIColor.white
        //set.drawCircleHoleEnabled = true
        var dataSets  = [LineChartDataSet]()
        dataSets.append(set)
        let data = LineChartData(dataSets: dataSets)
        data.setValueTextColor(UIColor.white)
        chart.data = data
        
    }
    
    func setUpGradientBackground(){
        
        //ORDER CHANGES HERE BIG TIME !!!
        let tempGradient = CAGradientLayer()
        tempGradient.cornerRadius = 10
        tempGradient.colors = [ UIColor(colorLiteralRed: 0.988 , green: 0.569, blue: 0.341, alpha: 1.00).cgColor, UIColor(colorLiteralRed: 0.984, green: 0.267, blue: 0.231, alpha: 1.00).cgColor]
        let eAGradient = CAGradientLayer()
        eAGradient.cornerRadius = 10
        eAGradient.colors = [ UIColor(colorLiteralRed: 0.278 , green: 0.576, blue: 0.961, alpha: 1.00).cgColor, UIColor(colorLiteralRed: 0.043, green: 0.259, blue: 0.600, alpha: 1.00).cgColor]
        let heartRateGradient  = CAGradientLayer()
        heartRateGradient.cornerRadius = 10
        heartRateGradient.colors = [ UIColor(colorLiteralRed: 0.333 , green: 0.906, blue: 0.800, alpha: 1.00).cgColor, UIColor(colorLiteralRed: 0.235, green: 0.675, blue: 0.851, alpha: 1.00).cgColor]
        let ibiGradient = CAGradientLayer()
        ibiGradient.cornerRadius = 10
    
        ibiGradient.colors = [ UIColor(colorLiteralRed: 0.992, green: 0.773, blue: 0.184, alpha: 1.00).cgColor, UIColor(colorLiteralRed: 0.992, green: 0.635, blue: 0.157, alpha: 1.00).cgColor]
        let volume = CAGradientLayer()
        volume.cornerRadius = 10
        volume.colors = [ UIColor(colorLiteralRed: 0.302 , green: 0.933, blue: 0.365, alpha: 1.00).cgColor, UIColor(colorLiteralRed: 0.110, green: 0.710, blue: 0.122, alpha: 1.00).cgColor]
        gradients.append(tempGradient)
        gradients.append(eAGradient)
        gradients.append(heartRateGradient)
        gradients.append(ibiGradient)
        gradients.append(volume)
        
    }
    
    //MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.row < 2{
            return CGSize(width: self.view.frame.width-5, height: (self.collectionView?.window?.frame.height)!*0.3)
        }else {
            return CGSize(width: self.view.frame.width, height: 100)
        }
    }

    func didUpdate(_ status: DeviceStatus, forDevice device: EmpaticaDeviceManager!) {
        switch status{
        case kDeviceStatusDisconnected:
            print ("Disconnected from device")
        case kDeviceStatusConnecting:
            print ("Connecting to device")
        case kDeviceStatusConnected:
            print ("Connected to device")
        case kDeviceStatusFailedToConnect:
            print ("Failed to connect to device")
        case kDeviceStatusDisconnecting:
            print ("Diconnecting from device")
        default:
            print ("no idea what is going on")
            
        }
    }
//    func didReceiveTemperature(_ temp: Float, withTimestamp timestamp: Double, fromDevice device: EmpaticaDeviceManager!) {
//        updateEntry(forGraph: graphs[0], withTimestamp: timestamp, andValue: temp)
//        //print("time stamp \(timestamp) temp \(temp)")
//    }
    func didReceiveBVP(_ bvp: Float, withTimestamp timestamp: Double, fromDevice device: EmpaticaDeviceManager!) {
        bvpQueue.async { [unowned self] in
            self.bvpReading?.append("\(self.bvpCounter),\(bvp) \n")
            self.bvpCounter += 1
        }
       
    }
    func didReceiveGSR(_ gsr: Float, withTimestamp timestamp: Double, fromDevice device: EmpaticaDeviceManager!) {
        gsrQueue.async {[unowned self] in
            self.gsrReading?.append("\(self.gsrCounter),\(gsr)\n")
            self.gsrCounter += 1
        }
       
    }
    func didReceiveIBI(_ ibi: Float, withTimestamp timestamp: Double, fromDevice device: EmpaticaDeviceManager!) {
        ibiQueue.async {[unowned self] in
            self.ibiReading?.append("\(self.ibiCounter),\(ibi)\n")
            self.ibiCounter += 1
        }
       
        
    }
    func didReceiveHR(_ hr: Float, withTimestamp timestamp: Double, fromDevice device: EmpaticaDeviceManager!) {
        hrQueue.async {[unowned self] in
            self.hrReading?.append("\(self.hrCounter),\(hr)\n")
            self.hrCounter += 1
        }
        
    }
    func didReceiveTemperature(_ temp: Float, withTimestamp timestamp: Double, fromDevice device: EmpaticaDeviceManager!) {
        tempQueue.async {[unowned self] in
           self.tempReading?.append("\(self.tempCounter),\(temp)\n")
            self.tempCounter += 1
        }
        
    }
    func updateEntry (forGraph graph: LineChartView, withTimestamp timestamp : Double, andValue value : Float){
            DispatchQueue.main.async(execute:{
                
//                let graphData = graph.lineData
//                let graphDataSet = graph.lineData?.dataSets[0] as! LineChartDataSet
//                graphDataSet.addEntry(ChartDataEntry(x: timestamp, y: Double(value)))
//                graphData?.notifyDataChanged()
//                graphDataSet.notifyDataSetChanged()
//                graph.notifyDataSetChanged()
//                graph.setVisibleXRangeMaximum(10)
////                //            graph.setNeedsLayout()
////                //            graph.setNeedsDisplay()
//                graph.moveViewToX(timestamp)
            })
        //graph.zoom(scaleX: CGFloat(1.0), scaleY: CGFloat(1.0), xValue: timestamp, yValue: Double(value), axis: graphDataSet.axisDependency)
        //        graph.setVisibleYRangeMaximum(Double(value), axis: .left)
        //        graph.setVisibleYRangeMinimum(-1*Double(value), axis: .left)
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isToolbarHidden = true 
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "UploadSegue"{
            let destinationVC = segue.destination as! UploadViewController
            connectedE4?.disconnect()
            destinationVC.bvpReading = bvpReading?.data(using: String.Encoding.utf8, allowLossyConversion: false)
            destinationVC.tempReading = tempReading?.data(using: String.Encoding.utf8, allowLossyConversion: false)
            destinationVC.ibiReading = ibiReading?.data(using: String.Encoding.utf8, allowLossyConversion: false)
            destinationVC.gsrReading = gsrReading?.data(using: String.Encoding.utf8, allowLossyConversion: false)
            destinationVC.hrReading = hrReading?.data(using: String.Encoding.utf8, allowLossyConversion: false)
            
        }
    }
}
