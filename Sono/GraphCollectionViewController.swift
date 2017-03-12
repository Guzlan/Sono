//
//  GraphCollectionViewController.swift
//  Sono
//
//  Created by Amr Guzlan on 2016-10-26.
//  Copyright © 2016 Amro Gazlan. All rights reserved.
//

import UIKit
import Charts
import Font_Awesome_Swift

private let grapCellIdentifier = "GraphCell"
private let informationCellIdentifier = "InformationCell"

class GraphCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, EmpaticaDeviceDelegate{
    
    var timer : Timer?
    

    
    var tempReading : String?
    var gsrReading : String?
    var hrReading: String?
    var ibiReading: String?
    var bvpReading: String?
    var batteryReading : String?
    
    var battery : UILabel?
    
    var tempCounter = 0
    var gsrCounter = 0
    var hrCounter = 0
    var ibiCounter = 0
    var bvpCounter = 0
    
    
    var updatedSecond : Double = 0.0
    var lastBVPReading : Float = 0.0
    var lastGSRReading : Float = 0.0
    
    
    var connectedE4  : EmpaticaDeviceManager?
    var graphs = [LineChartView]() // an array to store our graphs
    let noGraphDataMessages = ["No EA data", "No blood volume data", "No heart rate data", "No temperature data","No inter beat interval data"] //ORDER CHANGES HERE
    let volumeGraph = LineChartView() //our volume graph
    let eaGraph = LineChartView() //our volume graph
    var gradients = [CAGradientLayer]()
    
    let bvpQueue  = DispatchQueue(label: "bvp", qos: .userInitiated)
    let tempQueue  = DispatchQueue(label: "temp", qos: .userInitiated)
    let ibiQueue  = DispatchQueue(label: "ibi", qos: .userInitiated)
    let hrQueue  = DispatchQueue(label: "hr", qos: .userInitiated)
    let gsrQueue  = DispatchQueue(label: "gsr", qos: .userInitiated)
    
    var slider : UISlider?
    
    override func viewDidAppear(_ animated: Bool) {
        startNewSession()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackgroundColor()
        batteryReading = ""
        setupBatteryLabel()
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: grapCellIdentifier) // register the reusable cell we have
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 5, bottom: 0, right: 5)
        layout.minimumInteritemSpacing = 20
        layout.minimumLineSpacing = 20
        self.collectionView!.collectionViewLayout = layout
        tempReading = ("Time Stamp,Temperature\n")
        gsrReading = ("Time Stamp,Response\n")
        hrReading = ("Time Stamp, Heart Rate\n")
        ibiReading = ("Time Stamp,IBI\n")
        bvpReading = ("Time Stamp,BVP\n")
        graphs.append(volumeGraph)// add volume graph to our graphs list
        graphs.append(eaGraph) // add the electrodermal activity graph
        setUp(graphs: graphs)
        setUpGradientBackground()
        connectedE4?.connect(with: self)
        self.tabBarItem.title = "Biomusic"
    }
    
    
    func startNewSession() {
        self.tempReading = ""
        self.gsrReading = ""
        self.hrReading = ""
        self.ibiReading = ""
        self.bvpReading = ""
        tempCounter = 0
        gsrCounter = 0
        hrCounter = 0
        ibiCounter = 0
        bvpCounter = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        connectedE4?.connect(with: self)
    }
    //
    //
    //    // MARK: UICollectionViewDataSource
    //
    
    func setUp(graphs: [LineChartView]){
        for i in 0..<graphs.count{
            graphs[i].layer.cornerRadius = 10
            graphs[i].layer.borderColor = UIColor.black.cgColor
            graphs[i].layer.borderWidth = 0.5
            graphs[i].clipsToBounds = true
            graphs[i].noDataText = self.noGraphDataMessages[i]
            graphs[i].translatesAutoresizingMaskIntoConstraints = false
            graphs[i].xAxis.labelPosition = .bottom
            graphs[i].animate(xAxisDuration: 2.0)
            graphs[i].animate(yAxisDuration: 2.0)
            graphs[i].zoom(scaleX: CGFloat(1.0), scaleY: CGFloat(1.0), xValue: 0, yValue: Double(0), axis: .left)
            if i == 0 {
                graphs[i].leftAxis.axisMinimum = -100.00
                graphs[i].leftAxis.axisMaximum = 100.00
            }else{
                graphs[i].leftAxis.axisMinimum = 0.00
                graphs[i].leftAxis.axisMaximum = 0.50
            }
            setChartData(forChart: graphs[i], withNumber: i)
        }
        
    }
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0{
            return 2
        }else if section == 1{
            return 2
        }
        else {
            return 3
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: informationCellIdentifier, for: indexPath)
            cell.layer.cornerRadius = 10
            cell.layer.borderColor = UIColor.black.cgColor
            cell.layer.borderWidth = 0.5
            cell.backgroundColor = UIColor.red
            if indexPath.row == 1{
                cell.layer.borderColor = UIColor.clear.cgColor
                cell.layer.borderWidth = 0
                cell.backgroundColor = UIColor.clear
                cell.addSubview(battery!)
            }
            return cell
        }
        else if indexPath.section == 1{
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GraphCell", for: indexPath)
                
                cell.addSubview(graphs[indexPath.row]) //ORDER CHANGES HERE
                // add constraints on the graph view inside it's cell. 0 padding from all sides
                cell.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[v0]-0-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":graphs[indexPath.row]]))
                cell.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[v0]-0-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":graphs[indexPath.row]]))
                gradients[indexPath.row].frame = cell.layer.bounds //ORDER CHANGES HERE
                cell.layer.insertSublayer(gradients[indexPath.row], at: 0)
                return cell
        }
        else{
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: informationCellIdentifier, for: indexPath)
                cell.layer.cornerRadius = 10
                cell.layer.borderColor = UIColor.black.cgColor
                cell.layer.borderWidth = 0.5
                cell.backgroundColor = UIColor.red
                return cell
        }
        
    }
    
    
    func setChartData(forChart chart: LineChartView, withNumber num : Int){
        //        chart.xAxis.labelPosition = .bottom
        var entries = [ChartDataEntry]()
        entries.append(ChartDataEntry(x: -1, y: 0))
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
        set.mode  = .cubicBezier
        if num == 1 {
            set.drawFilledEnabled = true
        }
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
        if indexPath.section == 1{
            return CGSize(width: self.view.frame.width-5, height: (self.collectionView?.window?.frame.height)!*0.3)
        }
        else if indexPath.section == 2 {
              return CGSize(width: 0.30*(self.view.frame.width)-5, height:  (self.collectionView?.window?.frame.height)!*0.1)
        }
        else{
            if indexPath.row == 0 {
                return CGSize(width: 0.60*(self.view.frame.width-5), height:  (self.collectionView?.window?.frame.height)!*0.1)
            }
            else {
                return CGSize(width: 0.30*(self.view.frame.width-5), height:  (self.collectionView?.window?.frame.height)!*0.1)
            }
    
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
    func didReceiveBVP(_ bvp: Float, withTimestamp timestamp: Double, fromDevice device: EmpaticaDeviceManager!) {
        bvpQueue.async { [unowned self] in
            self.bvpReading?.append("\(self.bvpCounter),\(bvp) \n")
            self.bvpCounter += 1
            self.updateEntry(forGraph: self.graphs[0], withTimestamp: timestamp, andValue: bvp)
        }
        
        
    }
    func didReceiveGSR(_ gsr: Float, withTimestamp timestamp: Double, fromDevice device: EmpaticaDeviceManager!) {
        gsrQueue.async {[unowned self] in
            self.gsrReading?.append("\(self.gsrCounter),\(gsr)\n")
            self.gsrCounter += 1
            self.updateEntry(forGraph: self.graphs[1], withTimestamp: timestamp, andValue: gsr)
        }
        
    }
    func didReceiveIBI(_ ibi: Float, withTimestamp timestamp: Double, fromDevice device: EmpaticaDeviceManager!) {
        ibiQueue.async {[unowned self] in
            self.ibiReading?.append("\(self.ibiCounter),\(ibi)\n")
            self.ibiCounter += 1
            print("\"Time is \(timestamp)\",",terminator:"")
            
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
    func setBackgroundColor(){
        let bc = CAGradientLayer()
        let topColor = UIColor(colorLiteralRed: 0.325, green: 0.824, blue: 0.675, alpha: 1.00).cgColor
        let bottomColor = UIColor(colorLiteralRed: 0.129, green: 0.412, blue: 0.647, alpha: 1.00).cgColor
        bc.colors = [topColor, bottomColor]
        bc.locations = [0.0, 1.0]
        bc.frame = self.view.bounds
        bc.zPosition = -1
        self.collectionView?.layer.insertSublayer(bc, at: 0)
    }
    func updateEntry (forGraph graph: LineChartView, withTimestamp timestamp : Double, andValue value : Float){
        DispatchQueue.main.async(execute:{
            let graphData = graph.lineData
            let graphDataSet = graph.lineData?.dataSets[0] as! LineChartDataSet
            graphDataSet.addEntry(ChartDataEntry(x: timestamp, y: Double(value)))
            graphData?.notifyDataChanged()
            graphDataSet.notifyDataSetChanged()
            graph.notifyDataSetChanged()
            graph.setVisibleXRangeMaximum(10)
            graph.moveViewToX(timestamp)
            
            
        })
    }
    func setupBatteryLabel(){
        self.battery = UILabel(frame: CGRect(x: 0, y: 0, width: 0.30*(self.view.frame.width-5), height: 0.15*(self.view.frame.width-5)))
        self.battery?.font = UIFont(name: "Helvetica", size: 26)
        self.battery?.textAlignment = .right
        self.battery?.setFAText(prefixText:"100%", icon: .FABatteryFull, postfixText: "", size: 25)
        self.battery?.setFAColor(color: UIColor.green)
        self.battery?.textColor = UIColor.black
    }
    override func viewWillDisappear(_ animated: Bool) {
        
    }
}
