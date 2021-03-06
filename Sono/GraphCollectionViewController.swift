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
    var skinTemperatureLabel : UILabel?
    var hrLabel : UILabel?
    
    var tempCounter = 0
    var gsrCounter = 0
    var hrCounter = 0
    var ibiCounter = 0
    var bvpCounter = 0
    
    
    var updatedSecond : Double = 0.0
    var lastBVPReading : Float = 0.0
    var lastGSRReading : Float = 0.0
    var lastBatteryReading : Float = 0.0
    var timeEpoch = Double(Date().timeIntervalSince1970)
    
    
    
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
    
    let biomusic = Biomusic()
    
    var playPauseButton : UIButton?
    var muteMusic : UIButton?
    
    //The following variables are for autoscaling
    var minGSRValue = 10.0
    var minGSRValueTimeout = 45
    var maxGSRValue = 0.0
    var maxGSRValueTimeout = 45
    
    var minBVPValue = -100.0
    var minBVPValueTimeout = 500
    var maxBVPValue = 100.0
    var maxBVPValueTimeout = 500
    
    
    var isGraphing = true
    var isMute = false
    
    override func viewDidAppear(_ animated: Bool) {
        startNewSession()
    }
    
    override func viewDidLoad() {
    
        super.viewDidLoad()
        self.collectionView?.backgroundColor = UIColor.white
        self.collectionView?.isScrollEnabled = false
        //setBackgroundColor()
        batteryReading = ""
        setupBatteryLabel()
        configureSkinTemperatureLabel()
        configureHRLabel()
        configurePlayPauseButton()
        configureMuteMusicButton()
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: grapCellIdentifier) // register the reusable cell we have
        self.collectionView!.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10 , left: 5, bottom: 0, right: 5)
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
        self.navigationItem.title = "Biomusic"
        self.navigationController?.tabBarItem.title = "Biomusic"
        self.navigationController?.tabBarItem.setFAIcon(icon: .FAMusic)
        //self.tabBarItem.setFAIcon(icon: .FAMusic)
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
            graphs[i].layer.borderColor = UIColor.orange.cgColor
            graphs[i].layer.borderWidth = 0
            graphs[i].clipsToBounds = true
            graphs[i].noDataText = self.noGraphDataMessages[i]
            graphs[i].translatesAutoresizingMaskIntoConstraints = false
            graphs[i].xAxis.labelPosition = .bottom
            graphs[i].animate(xAxisDuration: 2.0)
            graphs[i].animate(yAxisDuration: 2.0)
            graphs[i].zoom(scaleX: CGFloat(1.0), scaleY: CGFloat(1.0), xValue: 0, yValue: Double(0), axis: .left)
            graphs[i].chartDescription?.font = UIFont(name: "Helvetica", size: 22)!
            graphs[i].chartDescription?.textColor = UIColor.white
            graphs[i].legend.enabled = false
            graphs[i].leftAxis.labelTextColor = UIColor.white
            graphs[i].xAxis.labelTextColor = UIColor.white
            graphs[i].xAxis.axisMinimum = 0
            graphs[i].leftAxis.drawGridLinesEnabled = false
            //graphs[i].xAxis.drawGridLinesEnabled = false
            //graphs[i].rightAxis.drawGridLinesEnabled = false
            if i == 0 {
                graphs[i].leftAxis.axisMinimum = -100.00
                graphs[i].leftAxis.axisMaximum = 100.00
                graphs[i].chartDescription?.text = "BVP"
            }else{
                graphs[i].chartDescription?.text = "EDA "
                //graphs[1].leftAxis.axisMinimum = 0.15
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
            if indexPath.row == 0 {
                cell.addSubview(hrLabel!)
            }else if indexPath.row == 1{
                cell.addSubview(skinTemperatureLabel!)
            }
            return cell
        }
        else if indexPath.section == 1{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GraphCell", for: indexPath)
            cell.addSubview(graphs[indexPath.row])
            cell.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[v0]-0-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":graphs[indexPath.row]]))
            cell.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[v0]-0-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":graphs[indexPath.row]]))
            gradients[indexPath.row].frame = cell.layer.bounds //ORDER CHANGES HERE
            cell.layer.insertSublayer(gradients[indexPath.row], at: 0)
            return cell
        }
        else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: informationCellIdentifier, for: indexPath)
            if indexPath.row == 0 {
                cell.addSubview(battery!)
            }else if indexPath.row == 1{
                 cell.addSubview(playPauseButton!)
            }
            return cell
            
        }
        
    }
    
    
    func setChartData(forChart chart: LineChartView, withNumber num : Int){
        //        chart.xAxis.labelPosition = .bottom
        var entries = [ChartDataEntry]()
        entries.append(ChartDataEntry(x: 0, y: 0))
        
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
            return CGSize(width: self.view.frame.width-10, height: (self.collectionView?.window?.frame.height)!*0.3)
        }
        else if indexPath.section == 0{
            return CGSize(width: 0.45*(self.view.frame.width), height:   (self.view.frame.height)*0.05)
        }else{
            return CGSize(width: 0.45*(self.view.frame.width), height:   (self.view.frame.height)*0.1)
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
            self.bvpCounter += 1
            DispatchQueue.main.async(execute: {[unowned self] in
                if self.isGraphing{
                    self.updateEntry(forGraph: self.graphs[0], withTimestamp: timestamp-self.timeEpoch, andValue: bvp)
                }
            })
        }
        
        //Set new bounds for graphing
//        if (((Double(bvp) < minBVPValue)) || minBVPValueTimeout == 0){
//            minBVPValue = Double(bvp) - 50
//            minBVPValueTimeout = 500
//            self.graphs[0].leftAxis.axisMinimum = minBVPValue
//        }
//        else {
//            minBVPValueTimeout = minBVPValueTimeout - 1
//        }
//        
//        if (((Double(bvp) > maxBVPValue)) || maxBVPValueTimeout == 0){
//            maxBVPValue = Double(bvp) + 50
//            maxBVPValueTimeout = 500
//            self.graphs[0].leftAxis.axisMaximum = maxBVPValue
//        }
//        else {
//            maxBVPValueTimeout = maxBVPValueTimeout - 1
//        }
        
    }
    func didReceiveGSR(_ gsr: Float, withTimestamp timestamp: Double, fromDevice device: EmpaticaDeviceManager!) {
        gsrQueue.async {[unowned self] in
            self.biomusic.updateGSR(newGSR: Double(gsr))
            self.gsrCounter += 1
            DispatchQueue.main.async(execute: {[unowned self] in
                if self.isGraphing{
                    self.updateEntry(forGraph: self.graphs[1], withTimestamp: timestamp-self.timeEpoch, andValue: gsr)
                }
            })
        }
        
        //Set new bounds for graphing
        if (((Double(gsr) < minGSRValue) && (Double(gsr) != 0.0)) || minGSRValueTimeout == 0){
            minGSRValue = Double(gsr) - 0.015
            minGSRValueTimeout = 45
            self.graphs[1].leftAxis.axisMinimum = minGSRValue
        }
        else {
            minGSRValueTimeout = minGSRValueTimeout - 1
        }
        
        if (((Double(gsr) > maxGSRValue)) || maxGSRValueTimeout == 0){
            maxGSRValue = Double(gsr) + 0.015
            maxGSRValueTimeout = 45
            self.graphs[1].leftAxis.axisMaximum = maxGSRValue
        }
        else {
            maxGSRValueTimeout = maxGSRValueTimeout - 1
        }
    }
    func didReceiveIBI(_ ibi: Float, withTimestamp timestamp: Double, fromDevice device: EmpaticaDeviceManager!) {
        ibiQueue.async {[unowned self] in
            self.biomusic.updateIBI(newIBI: Double(ibi))
            DispatchQueue.main.async {
                let temp = (60/Double(ibi)).rounded()
                self.hrLabel!.text = "\(temp)bpm"
            }
            self.ibiCounter += 1
        }
        
        
    }
    func didReceiveHR(_ hr: Float, withTimestamp timestamp: Double, fromDevice device: EmpaticaDeviceManager!) {
        hrQueue.async {[unowned self] in
            self.hrCounter += 1
        }
        
    }
    func didReceiveBatteryLevel(_ level: Float, withTimestamp timestamp: Double, fromDevice device: EmpaticaDeviceManager!) {
        if level !=   lastBatteryReading {
            lastBatteryReading = level
            DispatchQueue.main.async {[unowned self] finished in
                if level > 0.9 {
                    self.battery?.setFAText(prefixText:"\(Int(level*100))%", icon: .FABatteryFull, postfixText: "", size: 25)
                }else if level < 0.9 && level > 0.75 {
                    self.battery?.setFAText(prefixText:"\(Int(level*100))%", icon: .FABatteryThreeQuarters, postfixText: "", size: 25)
                }else if level > 0.4 && level < 0.75 {
                    self.battery?.setFAText(prefixText:"\(Int(level*100))%", icon: .FABatteryHalf, postfixText: "", size: 25)
                }else if level > 0.1 && level < 0.25 {
                    self.battery?.setFAText(prefixText:"\(Int(level*100))%", icon: .FABatteryQuarter, postfixText: "", size: 25)
                }else if level < 0.1 {
                    self.battery?.setFAText(prefixText:"\(Int(level*100))%", icon: .FABatteryEmpty, postfixText: "", size: 25)
                }
            }
        }
    }
    func didReceiveTemperature(_ temp: Float, withTimestamp timestamp: Double, fromDevice device: EmpaticaDeviceManager!) {
        tempQueue.async {[unowned self] in
            self.biomusic.updateTemperature(newTemperature: Double(temp))
            DispatchQueue.main.async {
                let temp = Double(temp*100).rounded()/100
                self.skinTemperatureLabel!.text = "\(temp)C°"
            }
            
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
        let graphData = graph.lineData
        let graphDataSet = graph.lineData?.dataSets[0] as! LineChartDataSet
        if graphDataSet.entryCount  > 2000 {
            graphDataSet.removeFirst()
        }
        graphDataSet.addEntry(ChartDataEntry(x: timestamp, y: Double(value)))
        graphData?.notifyDataChanged()
        graphDataSet.notifyDataSetChanged()
        graph.notifyDataSetChanged()
        graph.setVisibleXRangeMaximum(10)
        graph.moveViewToX(timestamp)
    }
    
    func configureSkinTemperatureLabel(){
        skinTemperatureLabel = UILabel(frame: CGRect(x: 0, y: 0,
                                                     width: CGFloat(0.45*(self.view.frame.width)),
                                                     height: CGFloat((self.view.frame.height)*0.05)))
        skinTemperatureLabel?.lineBreakMode = .byWordWrapping
        skinTemperatureLabel?.text = "--C°"
        skinTemperatureLabel?.font = UIFont(name: "Helvetica", size: 20)
        skinTemperatureLabel?.textAlignment = .center
        skinTemperatureLabel?.textColor = UIColor.white
        skinTemperatureLabel?.backgroundColor = UIColor(colorLiteralRed: 0.035 , green: 0.420, blue: 0.573, alpha: 1.00)
        skinTemperatureLabel?.layer.cornerRadius = 5
        skinTemperatureLabel?.clipsToBounds  = true
        
    }
    
    func configureHRLabel(){
        hrLabel = UILabel(frame: CGRect(x: 0, y: 0,
                                                     width: CGFloat(0.45*(self.view.frame.width)),
                                                     height: CGFloat((self.view.frame.height)*0.05)))
        hrLabel?.lineBreakMode = .byWordWrapping
        hrLabel?.text = "--bpm"
        hrLabel?.font = UIFont(name: "Helvetica", size: 20)
        hrLabel?.textAlignment = .center
        hrLabel?.textColor = UIColor.white
        hrLabel?.backgroundColor = UIColor(colorLiteralRed: 0.035 , green: 0.420, blue: 0.573, alpha: 1.00)
        hrLabel?.layer.cornerRadius = 5
        hrLabel?.clipsToBounds  = true
    }
    
    func configurePlayPauseButton(){
        
        
        playPauseButton = UIButton(frame: CGRect(x: 0, y: 0,
                                                 width: CGFloat(0.45*(self.view.frame.width)),
                                                 height: CGFloat((self.view.frame.height)*0.1)))
        playPauseButton?.setFAIcon(icon: .FAPause, iconSize:40, forState: .normal)
        playPauseButton?.contentVerticalAlignment = .center
        playPauseButton?.setFATitleColor(color: UIColor.white)
        playPauseButton?.backgroundColor = UIColor(colorLiteralRed: 0.909 , green: 0.255, blue: 0.231, alpha: 1.00)
        playPauseButton?.layer.cornerRadius = 10
        playPauseButton?.addTarget(self, action: #selector(playPause), for: .touchUpInside)
        
    }
    func configureMuteMusicButton(){
        muteMusic = UIButton(frame: CGRect(x: 0, y: 0,
                                           width: CGFloat(0.45*(self.view.frame.width)),
                                           height: CGFloat((self.view.frame.height)*0.1)))
        muteMusic?.setFAIcon(icon: .FAVolumeUp, iconSize:40, forState: .normal)
        muteMusic?.contentVerticalAlignment = .center
        muteMusic?.setFATitleColor(color: UIColor.white)
        muteMusic?.backgroundColor = UIColor(colorLiteralRed: 0.957, green: 0.698, blue: 0.203, alpha: 1.00)
        muteMusic?.layer.cornerRadius = 10
        muteMusic?.addTarget(self, action: #selector(muteSound), for: .touchUpInside)
    }
    func muteSound(){
        if isMute{
            muteMusic?.setFAIcon(icon: .FAVolumeUp, iconSize:40, forState: .normal)
            isMute = false
        }else{
            muteMusic?.setFAIcon(icon: .FAVolumeOff, iconSize:40, forState: .normal)
            isMute = true
        }
    }
    func playPause(){
        if isGraphing {
            playPauseButton?.setFAIcon(icon: .FAPlay, iconSize:40, forState: .normal)
            isGraphing = false
            biomusic.isPlaying = false
        }else{
            playPauseButton?.setFAIcon(icon: .FAPause, iconSize:40, forState: .normal)
            isGraphing = true
            biomusic.isPlaying = true
        }
        
    }
    func setupBatteryLabel(){
        self.battery = UILabel(frame: CGRect(x: 0, y: 0, width: 0.45*(self.view.frame.width-5), height: (self.view.frame.height)*0.1))
        self.battery?.font = UIFont(name: "Helvetica", size: 26)
        battery?.backgroundColor =  UIColor(colorLiteralRed: 0.909 , green: 0.255, blue: 0.231, alpha: 1.00)
        battery?.layer.cornerRadius = 10
        battery?.clipsToBounds  = true
        self.battery?.textAlignment = .center
        self.battery?.textColor = UIColor.white
    }
    override func viewWillDisappear(_ animated: Bool) {
        
    }
}
