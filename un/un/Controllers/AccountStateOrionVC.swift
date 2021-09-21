//
//  AccountStateOrionVC.swift
//  un
//
//  Created by Andres Liu on 1/21/21.
//

import UIKit
import Alamofire
import SwiftyJSON
import Charts
import SideMenu

class AccountStateOrionVC: UIViewController {
    
    
    @IBOutlet weak var consumoAnualOrion: UILabel!
    @IBOutlet weak var mediaCreditsAnualOrion: UILabel!
    @IBOutlet weak var consumoGaugeView: UIView!
    @IBOutlet weak var mediaGaugeView: UIView!
    @IBOutlet weak var graphView: UIView!
    @IBOutlet weak var legendCV: UICollectionView!
    
    var consumoGaugeGraph = GaugeView()
    var mediaGaugeGraph = GaugeView()
    
    var arrayYear = [Int]()
    var yearList = [FilterBody]()
    var barChart = BarChartView()
    var graphData = [EstadoCuentaOrionStruct]()
    
    var graphicColors: [UIColor] = [UIColor(rgb: 0x18AFD4), UIColor(rgb: 0x584EB7)]
    let months = ["Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"]
    
    let monthsInitials = ["Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Set", "Oct", "Nov", "Dic"]
    let legendValues = ["Consumo mensual orion", "Media credits orion"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        OrionManager.shared.orionVC = self
        self.legendCV.dataSource = self
        self.legendCV.delegate = self
        
        consumoGaugeGraph.frame = CGRect(x: 0, y: 0, width: consumoGaugeView.frame.width, height: consumoGaugeView.frame.height)
        consumoGaugeGraph.value = 0
        consumoGaugeGraph.setUp()
        consumoGaugeGraph.backgroundColor = .clear
        consumoGaugeView.addSubview(consumoGaugeGraph)
        
        mediaGaugeGraph.frame = CGRect(x: 0, y: 0, width: mediaGaugeView.frame.width, height: mediaGaugeView.frame.height)
        mediaGaugeGraph.value = 0
        mediaGaugeGraph.setUp()
        mediaGaugeGraph.backgroundColor = .clear
        mediaGaugeView.addSubview(mediaGaugeGraph)
        
        getFilters()
    }
    
    func getFilters() {
        yearList = NetworkManager.shared.getYears()
        arrayYear.append(yearList[yearList.count - 1].id)
        getBarChart()
    }
    
    func getBarChart() {
        self.graphData.removeAll()
        let serverManager = ServerManager()
        let parameters : Parameters  = ["year": arrayYear[0], "idCurrency": UserDefaults.standard.integer(forKey: "moneda"), "idBrand": "C1"]
        
        serverManager.serverCallWithHeaders(url: serverManager.estadoCuentaOrionURL, params: parameters, method: .post, callback: {  (intCheck : Int, jsonData : JSON) -> Void in
            if intCheck == 1 {
                guard !jsonData.isEmpty else {
                    self.showAlert(title: "Error", message: "No hay datos con determinado filtro")
                    return
                }
                let data = jsonData["orion"]
                for i in 0..<12 {
                    let element = EstadoCuentaOrionStruct(name: self.months[i], annualConsumption: 0.0, mediaCredits: 0.0)
                    self.graphData.append(element)
                }
                
                var annualConsumptionCurrent = ""
                if data["annualConsumptionCurrent"].float! < 1000 {
                    annualConsumptionCurrent = "$ \(String(format: "%.2f", data["annualConsumptionCurrent"].float!))"
                } else if data["annualConsumptionCurrent"].float! < 1000000 {
                    annualConsumptionCurrent = "$ \(String(format: "%.2f", data["annualConsumptionCurrent"].float!/1000))K"
                } else {
                    annualConsumptionCurrent = "$ \(String(format: "%.2f", data["annualConsumptionCurrent"].float!/1000000))MM"
                }
                
                self.consumoAnualOrion.text = annualConsumptionCurrent
                //anualConsumptionExpected
                
                var mediaCreditsCurrent = ""
                if data["mediaCreditsCurrent"].float! < 1000 {
                    mediaCreditsCurrent = "$ \(String(format: "%.2f", data["mediaCreditsCurrent"].float!))"
                } else if data["mediaCreditsCurrent"].float! < 1000000 {
                    mediaCreditsCurrent = "$ \(String(format: "%.2f", data["mediaCreditsCurrent"].float!/1000))K"
                } else {
                    mediaCreditsCurrent = "$ \(String(format: "%.2f", data["mediaCreditsCurrent"].float!/1000000))MM"
                }
                
                self.mediaCreditsAnualOrion.text = mediaCreditsCurrent
                //mediaCreditsExpected
                
                for mes in data["months"].arrayValue {
                    let index = self.graphData.firstIndex(where: { $0.name.caseInsensitiveCompare(mes["name"].string!) == .orderedSame })
                    self.graphData[Int(index!)].annualConsumption += mes["amountAnnualConsumption"].float!
                    self.graphData[Int(index!)].mediaCredits += mes["amountMediCredits"].float!

                }
                    
                //self.graphData = self.graphData.filter{ $0.annualConsumption > 0}
                print(self.graphData)
                print(self.graphData.count)
                
                self.consumoGaugeGraph.value = Int(data["annualConsumptionCurrent"].float! / data["annualConsumptionExpected"].float! * 100)
                self.mediaGaugeGraph.value = Int(data["mediaCreditsCurrent"].float! / data["mediaCreditsExpected"].float! * 100)
                
                if self.consumoGaugeGraph.value > 100 {
                    self.consumoGaugeGraph.value = 100
                }
                if self.mediaGaugeGraph.value > 100 {
                    self.mediaGaugeGraph.value = 100
                }
                self.consumoGaugeGraph.valueArea = self.consumoGaugeGraph.value
                self.mediaGaugeGraph.valueArea = self.mediaGaugeGraph.value

                self.consumoGaugeGraph.setNeedsDisplay()
                self.mediaGaugeGraph.setNeedsDisplay()
                
                self.showBarChart(dataPoints: self.monthsInitials)
            } else {
                self.showAlert(title: "Error", message: "Datos no fueron cargados correctamente")
            }
        })
    }
    
    func showBarChart(dataPoints: [String]) {
        if self.graphData.count > 0 {
            clearGraphView()

            self.barChart.frame = CGRect(x: 10, y: 10, width: self.graphView.frame.size.width, height: self.graphView.frame.height - 20)

            // Y - Axis Setup
            let yaxis = self.barChart.leftAxis
            yaxis.drawGridLinesEnabled = false
            yaxis.labelTextColor = UIColor.clear
            yaxis.axisLineColor = UIColor.clear
            yaxis.labelPosition = .insideChart
            yaxis.enabled = true
            yaxis.spaceTop = 0.35
            yaxis.axisMinimum = 0
            
            // X - Axis Setup
            let xaxis = self.barChart.xAxis
            xaxis.drawGridLinesEnabled = false
            xaxis.labelTextColor = UIColor.black
            xaxis.axisLineColor = UIColor.white
            xaxis.granularityEnabled = true
            xaxis.enabled = true
            xaxis.labelPosition = .bottom
            xaxis.labelFont = UIFont(name: "Gotham-Bold",
                                     size: 16.0)!
            //xaxis.valueFormatter = bottomLabelsAxis.valueFormatter
            xaxis.centerAxisLabelsEnabled = true
            xaxis.valueFormatter = IndexAxisValueFormatter(values: self.monthsInitials)
            xaxis.granularity = 1
            
            graphView.addSubview(barChart)

            var entries = [BarChartDataEntry]()
            var entries2 = [BarChartDataEntry]()
            
            for x in 0..<graphData.count {
                entries.append(BarChartDataEntry(x: Double(x), y: Double(graphData[x].annualConsumption / 1000).round(to: 2)))
                
                entries2.append(BarChartDataEntry(x: Double(x), y: Double(graphData[x].mediaCredits / 1000).round(to: 2)))
            }
            
            let set = BarChartDataSet(values: entries, label: "Consumed")
            let set2 = BarChartDataSet(values: entries2, label: "Media credits")
            
            set.drawValuesEnabled = false
            set.colors =  [UIColor(rgb: 0x18AFD4)]
            set.valueColors = [.black]
            set.valueLabelAngle = -90
            
            set2.drawValuesEnabled = false
            set2.colors =  [UIColor(rgb: 0x584EB7)]
            set2.valueColors = [.black]
            set2.valueLabelAngle = -90
            
            let barChartRenderer = BarChartEstadoDeCuentaContratosRenderer(dataProvider: barChart, animator: barChart.chartAnimator, viewPortHandler: barChart.viewPortHandler)
            barChart.renderer = barChartRenderer
            
            var datasets = [BarChartDataSet]()
            datasets.append(set)
            datasets.append(set2)
            
            let chartData = BarChartData(dataSets: datasets)
            
            let pFormatter = NumberFormatter()
            pFormatter.numberStyle = .currency
            pFormatter.maximumFractionDigits = 0
            pFormatter.multiplier = 1.0
            //pFormatter.zeroSymbol = ""
            pFormatter.currencySymbol = "$"
            pFormatter.positiveSuffix = "K"
            chartData.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
            chartData.setDrawValues(true)
            chartData.setValueTextColor(UIColor.black)
            
            let groupSpace = 0.3
            let barSpace = 0.05
            let barWidth = 0.3
            // (0.3 + 0.05) * 2 + 0.3 = 1.00 -> interval per "group"

            let groupCount = self.months.count
            let startYear = 0

            chartData.barWidth = barWidth
            barChart.xAxis.axisMinimum = Double(startYear)
            let gg = chartData.groupWidth(groupSpace: groupSpace, barSpace: barSpace)
            barChart.xAxis.axisMaximum = Double(startYear) + gg * Double(groupCount)
            chartData.groupBars(fromX: Double(startYear), groupSpace: groupSpace, barSpace: barSpace)
            barChart.notifyDataSetChanged()
            barChart.data = chartData
            barChart.data?.setValueFont(UIFont(name: "Georgia",
                                                    size: 12.0)!)
            
            barChart.chartDescription.enabled = false
            barChart.legend.enabled = false
            barChart.rightAxis.enabled = false
            barChart.drawValueAboveBarEnabled = true
            barChart.setVisibleXRangeMaximum(6)
            barChart.animate(yAxisDuration: 1.0, easingOption: .linear)
            barChart.doubleTapToZoomEnabled = false
            self.barChart.highlightPerTapEnabled = false
            
        } else {
            self.showAlert(title: "Error", message: "No hay datos con determinado filtro")
        }
    }
    
    func clearGraphView() {
        barChart.removeFromSuperview()
    }

    @IBAction func goToProjected(_ sender: UIButton) {
        self.navigationController?.popToViewController(ofClass: AccountStateProjectedVC.self, animated: false)
    }
    
    @IBAction func goToContract(_ sender: UIButton) {
        if let destinationViewController = navigationController?.viewControllers.filter({$0 is AccountStateContractVC}).first {
            navigationController?.popToViewController(destinationViewController, animated: false)
        } else {
            let contractVC = self.storyboard?.instantiateViewController(withIdentifier: "ContractVC") as! AccountStateContractVC
            self.navigationController?.pushViewController(contractVC, animated: false)
        }
    }
    
    @IBAction func goToOrion(_ sender: UIButton) {
    }
    @IBAction func showFIlters(_ sender: UIButton) {
        let orionFilter = storyboard?.instantiateViewController(withIdentifier: "OrionFilters") as! SideMenuNavigationController
        orionFilter.presentationStyle = .menuSlideIn
        orionFilter.presentationStyle.presentingEndAlpha = 0.5
        orionFilter.presentationStyle.onTopShadowOpacity = 1
        orionFilter.menuWidth = self.view.frame.width * 0.75
        
        present(orionFilter, animated: true) {
            OrionFilterManager.shared.orionFiltersVC.arrayYear = self.arrayYear
            OrionFilterManager.shared.orionFiltersVC.yearList = self.yearList
            OrionFilterManager.shared.orionFiltersVC.changeButtonTitle(OrionFilterManager.shared.orionFiltersVC.buttonYear, self.arrayYear, self.yearList)
        }
    }
    @IBAction func returnToReportList(_ sender: UIButton) {
        self.navigationController?.popToViewController(ofClass: ReportListVC.self, animated: true)
    }
}

extension AccountStateOrionVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SecondLegend", for: indexPath) as? SecondLegendCVCell {
            
            cell.listarEle(color: graphicColors[indexPath.row], nombre: legendValues[indexPath.row])

            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    

}

extension AccountStateOrionVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        let totalCellWidth = 120 * collectionView.numberOfItems(inSection: 0)
        let totalSpacingWidth = 10 * (collectionView.numberOfItems(inSection: 0) - 1)

        let leftInset = (collectionView.layer.frame.size.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
        let rightInset = leftInset

        return UIEdgeInsets(top: 10, left: leftInset, bottom: 0, right: rightInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let label = UILabel(frame: CGRect.zero)
        label.text = legendValues[indexPath.row]
        label.sizeToFit()
        return CGSize(width: label.frame.width + 20, height: 20)
    }
}
