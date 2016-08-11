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
    
    @IBOutlet weak var bgImage: UIImageView!
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
        
        parts = ["Part1", "Part2", "Part3", "Part4", "Part5", "Part6", "Part7"]
        let scores = [0.82, 0.86, 0.7, 0.9, 1, 0.8, 0.78]
        
        radarChartView.animate(yAxisDuration: 2.0)
        radarChartView.drawWeb = true
        radarChartView.descriptionText = ""
        radarChartView.webAlpha = CGFloat(1.0)
        radarChartView.yAxis.drawLabelsEnabled = false
        radarChartView.yAxis.axisMaxValue = 1
        radarChartView.yAxis.axisMinValue = 0
        radarChartView.layer.borderColor = UIColor.whiteColor().CGColor
        radarChartView.backgroundColor = UIColor.clearColor()
        radarChartView.webColor = NSUIColor.whiteColor()
        radarChartView.innerWebColor = NSUIColor.whiteColor()
        radarChartView.yAxis.labelTextColor = NSUIColor.whiteColor()
        radarChartView.xAxis.labelTextColor = NSUIColor.whiteColor()
        
        setChart(parts, values: scores)
        
        setScores()
        
        setBackgroundImage()
        
    }
    
    func setBackgroundImage() {
        self.bgImage.image = UIImage(named: "business")
        self.bgImage.contentMode = UIViewContentMode.ScaleAspectFill
        
        let imageView = UIImageView()
        imageView.frame = self.bgImage.bounds
        imageView.backgroundColor = ColorManager().clearGrayColor()
        self.bgImage.addSubview(imageView)
        
        let blurEffect = UIBlurEffect(style: .Light)
        let visualEffectView = UIVisualEffectView(effect: blurEffect)
        visualEffectView.frame = self.bgImage.bounds
        self.bgImage.addSubview(visualEffectView)
    }
    
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        //self.navigationItem.title = "Score"
    }
    
    func setChart(dataPoints: [String], values: [Double]) {
        self.radarChartView.noDataText = "No Data"
        
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = RadarChartDataSet(yVals: dataEntries, label: "April 2016")
        chartDataSet.colors = [NSUIColor.orangeColor()]
        chartDataSet.drawFilledEnabled = true
        chartDataSet.fillColor = NSUIColor.orangeColor()
        chartDataSet.fillAlpha = 0.8
        chartDataSet.valueColors = [NSUIColor.greenColor()]
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
