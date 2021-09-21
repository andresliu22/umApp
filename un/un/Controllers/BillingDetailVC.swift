//
//  BillingDetailVC.swift
//  un
//
//  Created by Andres Liu on 1/24/21.
//

import UIKit
import Alamofire
import SwiftyJSON
import Charts
import SideMenu

class BillingDetailVC: UIViewController {

    @IBOutlet weak var legendCV: UICollectionView!
    @IBOutlet weak var graphView: UIView! {
        didSet {
            let bottomBorder = CALayer()
            bottomBorder.frame = CGRect(x: 0.0, y: 0, width: graphView.frame.width, height: 1.0)
            bottomBorder.backgroundColor = #colorLiteral(red: 0.6117647059, green: 0.6117647059, blue: 0.6117647059, alpha: 1)
            graphView.layer.addSublayer(bottomBorder)
        }
    }
    @IBOutlet weak var detailContentView: UIView! {
        didSet {
            let bottomBorder = CALayer()
            bottomBorder.frame = CGRect(x: 0.0, y: detailContentView.frame.size.height, width: detailContentView.frame.width, height: 1.0)
            bottomBorder.backgroundColor = #colorLiteral(red: 0.6117647059, green: 0.6117647059, blue: 0.6117647059, alpha: 1)
            detailContentView.layer.addSublayer(bottomBorder)
        }
    }
    @IBOutlet weak var categoryView: UIView!
    @IBOutlet weak var detailCV: UICollectionView!
    
    var lineChart = LineChartView()
    
    var arrayYear = [Int]()
    var yearList = [FilterBody]()
    
    var graphData = [FacturacionDetalleStruct]()
    var detailData = [FacturacionDetalleTabla]()
    var graphicColors: [UIColor] = [UIColor(rgb: 0xF34627), UIColor(rgb: 0x5FF281)]
    let months = ["Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"]
    let monthsInitials = ["Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Set", "Oct", "Nov", "Dic"]
    let legendValues = ["Consumido", "Pagado"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let rightBorder = CALayer()
        rightBorder.frame = CGRect(x: self.view.frame.width * 0.25, y: 0, width: 1, height: categoryView.frame.height)
        rightBorder.backgroundColor = #colorLiteral(red: 0.6117647059, green: 0.6117647059, blue: 0.6117647059, alpha: 1)
        categoryView.layer.addSublayer(rightBorder)
        
        DetailManager.shared.detailVC = self
        self.legendCV.dataSource = self
        self.legendCV.delegate = self
        
        self.detailCV.dataSource = self
        self.detailCV.delegate = self
        
        getFilters()
    }
    
    func getFilters() {
        yearList = NetworkManager.shared.getYears()
        
        arrayYear.append(yearList[yearList.count - 1].id)
        getLineChart()
    }
    
    func getLineChart() {
        self.graphData.removeAll()
        self.detailData.removeAll()
        let serverManager = ServerManager()
        let parameters : Parameters  = ["year": arrayYear[0], "idCurrency": UserDefaults.standard.integer(forKey: "moneda"), "idBrand": UserDefaults.standard.string(forKey: "idBrand")!]
        
        serverManager.serverCallWithHeaders(url: serverManager.facturacionURL, params: parameters, method: .post, callback: {  (intCheck : Int, jsonData : JSON) -> Void in
            if intCheck == 1 {
                guard !jsonData.isEmpty else {
                    self.showAlert(title: "Error", message: "No hay datos con determinado filtro")
                    return
                }
                
                for i in 0..<12 {
                    let element = FacturacionDetalleStruct(name: self.months[i], consumido: 0.0, pagado: 0.0)
                    self.graphData.append(element)
                    let newDetail = FacturacionDetalleTabla(mes: self.months[i], consumido: 0.0, facturado: 0.0, porFacturar: 0.0, pagado: 0.0, porPagar: 0.0, vencido: 0.0)
                    self.detailData.append(newDetail)
                }
                
                for month in jsonData["billings"].arrayValue {
            
                    let index = self.graphData.firstIndex(where: { $0.name.caseInsensitiveCompare(month["month"].string!) == .orderedSame })
                    self.graphData[Int(index!)].consumido += month["amountConsumed"].float!
                    self.graphData[Int(index!)].pagado += month["amountPaid"].float!
                    
                    let detailIndex = self.detailData.firstIndex(where: { $0.mes.caseInsensitiveCompare(month["month"].string!) == .orderedSame })
                    
                    self.detailData[Int(detailIndex!)].consumido += month["amountConsumed"].float ?? 0
                    self.detailData[Int(detailIndex!)].facturado += month["amountInvoice"].float ?? 0
                    self.detailData[Int(detailIndex!)].porFacturar += month["amountToBilled"].float ?? 0
                    self.detailData[Int(detailIndex!)].pagado += month["amountPaid"].float ?? 0
                    self.detailData[Int(detailIndex!)].porPagar += month["amountToPayToBeat"].float ?? 0
                    self.detailData[Int(detailIndex!)].vencido += month["amountToPayDefeated"].float ?? 0

                }
                
                //self.graphData = self.graphData.filter{ $0.consumido > 0}
                print(self.graphData)
                print(self.graphData.count)
                self.showLineChart(dataPoints: self.monthsInitials)
                self.detailCV.reloadData()
            } else {
                self.showAlert(title: "Error", message: "Datos no fueron cargados correctamente")
            }
        })
    }
    
    func showLineChart(dataPoints: [String]) {
        if self.graphData.count > 0 {
            clearGraphView()

            self.lineChart.frame = CGRect(x: 20, y: 0, width: self.graphView.frame.size.width - 30, height: self.graphView.frame.height - 10)

            // Y - Axis Setup
            let yaxis = self.lineChart.leftAxis
            yaxis.drawGridLinesEnabled = false
            yaxis.labelTextColor = #colorLiteral(red: 0.2392156863, green: 0.2352941176, blue: 0.2392156863, alpha: 1)
            yaxis.axisLineColor = #colorLiteral(red: 0.2392156863, green: 0.2352941176, blue: 0.2392156863, alpha: 1)
            yaxis.enabled = true
            yaxis.labelAlignment = .justified
            yaxis.labelCount = 5
            yaxis.axisLineWidth = 0.0
            yaxis.labelAlignment = .left
            yaxis.labelFont = UIFont(name: "Gotham-Medium",
                                    size: 12.0)!
            yaxis.valueFormatter = YAxisLineChartFormatter()
            self.lineChart.rightAxis.enabled = false
            
            let rightBorder = CALayer()
            rightBorder.frame = CGRect(x: self.view.frame.width * 0.25, y: 0, width: 1, height: graphView.frame.height)
            rightBorder.backgroundColor = #colorLiteral(red: 0.6117647059, green: 0.6117647059, blue: 0.6117647059, alpha: 1)
            graphView.layer.addSublayer(rightBorder)
            
            // X - Axis Setup
            let xaxis = self.lineChart.xAxis
            xaxis.drawGridLinesEnabled = false
            xaxis.labelTextColor = #colorLiteral(red: 0.2392156863, green: 0.2352941176, blue: 0.2392156863, alpha: 1)
            xaxis.axisLineColor = UIColor.white
            xaxis.granularityEnabled = true
            xaxis.enabled = true
            xaxis.labelPosition = .bottom
            xaxis.labelFont = UIFont(name: "Georgia",
                                     size: 12.0)!
            xaxis.drawGridLinesEnabled = false
            xaxis.valueFormatter = IndexAxisValueFormatter(values: self.monthsInitials)
            
            self.graphView.addSubview(self.lineChart)

            var entries = [ChartDataEntry]()
            var entries2 = [ChartDataEntry]()
            
            for x in 0..<graphData.count {
                entries.append(ChartDataEntry(x: Double(x), y: Double(graphData[x].consumido / 1000000).round(to: 2)))
                entries2.append(ChartDataEntry(x: Double(x), y: Double(graphData[x].pagado / 1000000).round(to: 2)))
            }
            
            let set = LineChartDataSet(values: entries, label: "Consumido")
            let set2 = LineChartDataSet(values: entries2, label: "Pagado")
            
            set.mode = .linear
            set.setCircleColor(UIColor(rgb: 0xF34627))
            set.circleHoleColor = UIColor(rgb: 0xF34627)
            set.setColor(UIColor(rgb: 0xF34627))
            set.circleRadius = 4
            set.lineWidth = 2
            set.drawValuesEnabled = false
            
            set2.mode = .linear
            set2.setCircleColor(UIColor(rgb: 0x5FF281))
            set2.circleHoleColor = UIColor(rgb: 0x5FF281)
            set2.setColor(UIColor(rgb: 0x5FF281))
            set2.circleRadius = 4
            set2.lineWidth = 2
            set2.drawValuesEnabled = false
            
            var datasets = [LineChartDataSet]()
            datasets.append(set)
            datasets.append(set2)
            
            let chartData = LineChartData(dataSets: datasets)
            
            let pFormatter = NumberFormatter()
            pFormatter.numberStyle = .currency
            pFormatter.maximumFractionDigits = 2
            pFormatter.multiplier = 1.0
            //pFormatter.zeroSymbol = ""
            pFormatter.currencySymbol = "$"
            pFormatter.positiveSuffix = "MM"
            chartData.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
            chartData.setDrawValues(true)
            chartData.setValueTextColor(#colorLiteral(red: 0.2392156863, green: 0.2352941176, blue: 0.2392156863, alpha: 1))
            
            lineChart.data = chartData
            
            lineChart.chartDescription.enabled = false
            lineChart.legend.enabled = false
            lineChart.rightAxis.enabled = false
            lineChart.notifyDataSetChanged()
            lineChart.setVisibleXRangeMaximum(3)
            lineChart.animate(yAxisDuration: 1.0, easingOption: .linear)
            lineChart.doubleTapToZoomEnabled = false

        } else {
            self.showAlert(title: "Error", message: "No hay datos con determinado filtro")
        }
    }
    
    func clearGraphView() {
        self.lineChart.removeFromSuperview()
    }
    
    @IBAction func goToBillingBalance(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: false)
    }
    @IBAction func showFilters(_ sender: UIButton) {
        let detailFilter = storyboard?.instantiateViewController(withIdentifier: "DetailFilter") as! SideMenuNavigationController
        detailFilter.presentationStyle = .menuSlideIn
        detailFilter.presentationStyle.presentingEndAlpha = 0.5
        detailFilter.presentationStyle.onTopShadowOpacity = 1
        detailFilter.menuWidth = self.view.frame.width * 0.75
        
        present(detailFilter, animated: true) {
            DetailFilterManager.shared.detailFiltersVC.arrayYear = self.arrayYear
            DetailFilterManager.shared.detailFiltersVC.yearList = self.yearList
            DetailFilterManager.shared.detailFiltersVC.changeButtonTitle(DetailFilterManager.shared.detailFiltersVC.buttonYear, self.arrayYear, self.yearList)
        }
    }
    @IBAction func returnToReport(_ sender: UIButton) {
        self.navigationController?.popToViewController(ofClass: ReportListVC.self, animated: true)
    }
    
}

extension BillingDetailVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == legendCV {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SecondLegend", for: indexPath) as? SecondLegendCVCell {
                
                cell.listarEle(color: graphicColors[indexPath.row], nombre: legendValues[indexPath.row])

                return cell
            } else {
                return UICollectionViewCell()
            }
        } else {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "detailCell", for: indexPath) as? DetailCVC {
                
                cell.listarDetalle(mesNombre: String(detailData[indexPath.row].mes.prefix(3)), consumido: detailData[indexPath.row].consumido, facturado: detailData[indexPath.row].facturado, porFacturar: detailData[indexPath.row].porFacturar, pagado: detailData[indexPath.row].pagado, porPagar: detailData[indexPath.row].porPagar, vencido: detailData[indexPath.row].vencido)

                return cell
            } else {
                return UICollectionViewCell()
            }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == legendCV {
            return 2
        } else {
            return detailData.count
        }
        
    }
    

}

extension BillingDetailVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        if collectionView == legendCV {
            let totalCellWidth = 120 * collectionView.numberOfItems(inSection: 0)
            let totalSpacingWidth = 10 * (collectionView.numberOfItems(inSection: 0) - 1)

            let leftInset = (collectionView.layer.frame.size.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
            let rightInset = leftInset

            return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
        } else {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == legendCV {
            let label = UILabel(frame: CGRect.zero)
            label.text = legendValues[indexPath.row]
            label.sizeToFit()
            return CGSize(width: label.frame.width + 40, height: 30)
        } else {
            return CGSize(width: 80, height: 210)
        }
    }
}
