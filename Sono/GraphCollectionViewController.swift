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
    var graphs = [LineChartView]() // an array to store our graphs
    let noGraphDataMessages = ["No EA data", "No blood volume data", "No heart rate data", "No temperature data","No inter beat interval data"] //ORDER CHANGES HERE
    let tempGraph  = LineChartView() //our temperature graph
    let volumeGraph = LineChartView() //our volume graph
    let eaGraph = LineChartView() //our volume graph
    let heartRateGraph = LineChartView() //our volume graph
    let ibiGraph = LineChartView() //our volume graph
    var gradients = [CAGradientLayer]()
    //The following are dummy variables....MAHMOUD remove them and put your logic variables instead
    let months = ["Jan" , "Feb", "Mar", "Apr", "May", "June", "July", "August", "Sept", "Oct", "Nov", "Dec"]
    let dollars1 = [1453.0,2352,5431,1442,5451,6486,1173,5678,9234,1345,9411,2212]
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Graphs" // title of the navigation controller page
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: grapCellIdentifier) // register the reusable cell we have
        //ORDER CHANGES HERE
        graphs.append(tempGraph) // add temperature graph to our graphs list
        graphs.append(volumeGraph)// add volume graph to our graphs list
        graphs.append(eaGraph) // add the electrodermal activity graph
        graphs.append(heartRateGraph) // add the heart rate graph
        graphs.append(ibiGraph) // add the inter beat interval graph
        setUp(graphs: graphs)
        setUpGradientBackground()
    }
//
//
//    // MARK: UICollectionViewDataSource
//
    
    func setUp(graphs: [LineChartView]){
        for i in 0..<graphs.count{
            graphs[i].layer.borderWidth = 1
            graphs[i].layer.borderColor = UIColor.white.cgColor
            graphs[i].layer.cornerRadius = 10
            graphs[i].clipsToBounds = true
            graphs[i].noDataText = self.noGraphDataMessages[i]
            graphs[i].translatesAutoresizingMaskIntoConstraints = false
            graphs[i].xAxis.labelPosition = .bottom
            setChartData(forChart: graphs[i], withNumber: 0)
        }
    }
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 5
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row < 5{
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
        chart.xAxis.labelPosition = .bottom
        var y = [ChartDataEntry]()
        for i in 0..<months.count{
            y.append(ChartDataEntry(x: Double(i), y: dollars1[i]))
        }
        
        let set = LineChartDataSet()
        set.values = y
        
        
        // removing the right axis, we're only interested in the left axis
        let rightAxis = chart.getAxis(.right)
        rightAxis.drawAxisLineEnabled = false
        rightAxis.drawLabelsEnabled = false
        rightAxis.drawTopYLabelEntryEnabled = false
        rightAxis.drawLimitLinesBehindDataEnabled = false
    
        // customizing our data set, I think this is constant for all graphs .. we'll see
        set.setColor(UIColor.white) // line color
        set.setCircleColor(UIColor.darkGray) // our circle will be dark red
        set.lineWidth = 1.5
        set.circleRadius = 4.0 // the radius of the node circle
        set.fillAlpha = 65 / 255.0
        set.fillColor = UIColor.orange
        set.highlightColor = UIColor.white
        set.drawCircleHoleEnabled = true
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
        heartRateGradient.colors = [ UIColor(colorLiteralRed: 0.871 , green: 0.871, blue: 0.871, alpha: 1.00).cgColor, UIColor(colorLiteralRed: 0.627, green: 0.627, blue: 0.627, alpha: 1.00).cgColor]
        let ibiGradient = CAGradientLayer()
        ibiGradient.cornerRadius = 10
        ibiGradient.colors = [ UIColor(colorLiteralRed: 0.133 , green: 0.827, blue: 0.533, alpha: 1.00).cgColor, UIColor(colorLiteralRed: 0.063, green: 0.498, blue: 0.396, alpha: 1.00).cgColor]
        let volume = CAGradientLayer()
        volume.cornerRadius = 10
        volume.colors = [ UIColor(colorLiteralRed: 0.988 , green: 0.941, blue: 0.506, alpha: 1.00).cgColor, UIColor(colorLiteralRed: 0.996, green: 0.914, blue: 0.337, alpha: 1.00).cgColor]
        gradients.append(tempGradient)
        gradients.append(eAGradient)
        gradients.append(heartRateGradient)
        gradients.append(ibiGradient)
        gradients.append(volume)
   
    }
    
    //MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.row < 5{
            return CGSize(width: self.view.frame.width-5, height: 250)
        }else {
            return CGSize(width: self.view.frame.width, height: 100)
        }
    }
    
//    func didReceiveAccelerationX(_ x: Int8, y: Int8, z: Int8, withTimestamp timestamp: Double, fromDevice device: EmpaticaDeviceManager!) {
//        print("(\(x),\(y),\(z))")
//    }

}
