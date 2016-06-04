//
//  ChartViewController.swift
//  MarksheetReader
//
//  Created by Nakayama on 2016/06/04.
//  Copyright © 2016年 Nakayama. All rights reserved.
//

import UIKit
import Charts

class ChartViewController: UIViewController {

    @IBOutlet weak var radarChartView: RadarChartView!
    
    @IBOutlet weak var listeningScoreLabel: UILabel!
    @IBOutlet weak var readingScoreLabel: UILabel!
    @IBOutlet weak var totalScoreLabel: UILabel!
    @IBOutlet weak var listeningRangeLabel: UILabel!
    @IBOutlet weak var readingRangeLabel: UILabel!
    @IBOutlet weak var totalRangeLabel: UILabel!
    
    var launchScreenLabel: UILabel!
    
    
    private var parts: [String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLaunchScreen()
        
        parts = ["Part1", "Part2", "Part3", "Part4", "Part5", "Part6", "Part7"]
        let scores = [0.8, 0.22, 0.5, 0.9, 1, 0.19, 0.78]
        
        radarChartView.animate(yAxisDuration: 2.0)
        radarChartView.drawWeb = true
        radarChartView.descriptionText = "April 2016"
        radarChartView.webAlpha = CGFloat(1.0)
        radarChartView.yAxis.drawLabelsEnabled = false
        radarChartView.yAxis.axisMaxValue = 1
        radarChartView.yAxis.axisMinValue = 0
        radarChartView.layer.borderColor = UIColor.grayColor().CGColor
        
        setChart(parts, values: scores)
        
        setScores()
        
    }
    
    func setLaunchScreen(){
        let screenWidth = UIScreen.mainScreen().nativeBounds.width
        let screenHeight = UIScreen.mainScreen().nativeBounds.height
        
        self.launchScreenLabel = UILabel(frame: CGRectMake(0,0,screenWidth,screenHeight))
        self.launchScreenLabel.backgroundColor = UIColor(red: 0, green: CGFloat(80)/255.0, blue: CGFloat(127)/255.0, alpha: 1.0)
        self.launchScreenLabel.text = "R"
        self.launchScreenLabel.textColor = UIColor.whiteColor()
        self.launchScreenLabel.font = UIFont(name: "Avenir-Black",size: 200)
        self.launchScreenLabel.center = self.view.center
        self.launchScreenLabel.textAlignment = NSTextAlignment.Center
        self.view.addSubview(self.launchScreenLabel)
        
    }
 
    override func viewDidAppear(animated: Bool) {
        UIView.animateWithDuration(
            0.3,
            delay: 1.0,
            options: UIViewAnimationOptions.CurveEaseOut,
            animations: { () in
                self.launchScreenLabel.transform = CGAffineTransformMakeScale(0.9, 0.9)
            },
            completion: { (Bool) in }
        )
        
        UIView.animateWithDuration(
            0.2,
            delay: 1.3,
            options: UIViewAnimationOptions.CurveEaseInOut,
            animations: { () in
                self.launchScreenLabel.transform = CGAffineTransformMakeScale(1.2, 1.2)
                self.launchScreenLabel.alpha = 0
            },
            completion: { (Bool) in }
        )
        
    }
    
    func setChart(dataPoints: [String], values: [Double]) {
        self.radarChartView.noDataText = "No Data"
        
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = RadarChartDataSet(yVals: dataEntries, label: "Score")
        chartDataSet.colors = [NSUIColor.orangeColor()]
        chartDataSet.drawFilledEnabled = true
        chartDataSet.fillColor = NSUIColor.orangeColor()
        //chartDataSet.drawValuesEnabled = false
        let formatter = NSNumberFormatter()
        formatter.numberStyle = NSNumberFormatterStyle.PercentStyle
        formatter.formatWidth = 3
        chartDataSet.valueFormatter = formatter
        let chartData = RadarChartData(xVals: dataPoints)
        chartData.addDataSet(chartDataSet)
        
        radarChartView.data = chartData
    }
    
    func setScores(){
        
        self.listeningScoreLabel.text = "80 / 100"
        self.listeningRangeLabel.text = "330 - 420"
        self.readingScoreLabel.text = "85 / 100"
        self.readingRangeLabel.text = "350 - 430"
        self.totalScoreLabel.text = "165 / 200"
        self.totalRangeLabel.text = "680 - 850"
        
    }
    
    
}
