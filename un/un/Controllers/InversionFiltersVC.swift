//
//  InversionFiltersVC.swift
//  un
//
//  Created by Andres Liu on 1/18/21.
//

import UIKit
import Alamofire
import SwiftyJSON

class InversionFiltersVC: UIViewController {

    @IBOutlet weak var buttonYear: UIButton!
    @IBOutlet weak var buttonMonth: UIButton!
    @IBOutlet weak var buttonMedia: UIButton!
    @IBOutlet weak var buttonProvider: UIButton!
    @IBOutlet weak var buttonCampaign: UIButton!
    @IBOutlet weak var buttonBrand: UIButton!
    
    let transparentView = UIView()
    let searchBar = UISearchBar()
    let tableView = UITableView()
    let tableViewB = UITableView()
    var selectedButton = UIButton()
    
    var dataSource = [FilterBody]()
    var dataSearch = [FilterBody]()
    
    var dataSourceB = [Brand]()
    
    var searching = false
    var didSelect = false
    
    var arrayYear = [Int]()
    var arrayMonth = [Int]()
    var arrayMedia = [Int]()
    var arrayProvider = [Int]()
    var arrayCampaign = [Int]()
    var arrayBrand = [String]()
    
    var arrayBeforeFilter = [Int]()
    var arrayBeforeFilterB = [String]()
    
    var yearList = [FilterBody]()
    var monthList = [FilterBody]()
    var providerList = [FilterBody]()
    var mediaList = [FilterBody]()
    var campaignList = [FilterBody]()
    var brandList = [Brand]()
    
    var allYears = [String]()
    var arrayVacio = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        InversionFilterManager.shared.inversionFiltersVC = self
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(FilterCell.self, forCellReuseIdentifier: "InversionCell")
        self.tableView.allowsMultipleSelection = true
        self.tableView.allowsMultipleSelectionDuringEditing = true
        
        self.tableViewB.delegate = self
        self.tableViewB.dataSource = self
        self.tableViewB.register(FilterCell.self, forCellReuseIdentifier: "InversionCell")
        self.tableViewB.allowsMultipleSelection = false
        self.tableViewB.allowsMultipleSelectionDuringEditing = false
        
        self.searchBar.delegate = self
        
        buttonYear.addCustomStyle(borderWidth: 1)
        buttonMonth.addCustomStyle(borderWidth: 1)
        buttonMedia.addCustomStyle(borderWidth: 1)
        buttonProvider.addCustomStyle(borderWidth: 1)
        buttonCampaign.addCustomStyle(borderWidth: 1)
        buttonBrand.addCustomStyle(borderWidth: 1)
        
    }
    
    func changeButtonTitle(_ button: UIButton, _ arrayFilter: [Int], _ list: [FilterBody]) {
        if arrayFilter.count <= 1 {
            if arrayFilter == arrayYear {
                button.setTitle("\(arrayFilter[0])", for: .normal)
            } else if arrayFilter == arrayMonth {
                button.setTitle(list[arrayFilter[0] - 1].name, for: .normal)
            } else if arrayFilter == arrayMedia {
                button.setTitle(list[arrayFilter[0] - 1].name, for: .normal)
            } else {
                let filterList = list.filter(){$0.id == arrayFilter[0]}
                if filterList.count < 1 {
                    button.setTitle("", for: .normal)
                } else {
                    button.setTitle(filterList[0].name, for: .normal)
                }
            }
            
        } else if arrayFilter.count < list.count {
            button.setTitle("Varios", for: .normal)
        } else {
            button.setTitle("Todos", for: .normal)
        }
    }
    
    func addTransparentView(searchPlaceholder: String) {
        //let screen = CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        let frames = self.view.frame
        transparentView.frame = self.view.frame
        
        self.view.addSubview(transparentView)
        self.view.addSubview(searchBar)
        self.view.addSubview(tableView)
        
        self.searchBar.frame = CGRect(x: frames.minX + 20, y: frames.maxY, width: frames.width - 40, height: 0)
        self.tableView.frame = CGRect(x: frames.minX + 20, y: frames.maxY, width: frames.width - 40, height: 0)
        
        let searchTextField: UITextField? = searchBar.value(forKey: "searchField") as? UITextField
            if searchTextField!.responds(to: #selector(getter: UITextField.attributedPlaceholder)) {
                let attributeDict = [NSAttributedString.Key.foregroundColor: UIColor.black]
                searchTextField!.attributedPlaceholder = NSAttributedString(string: "Buscar \(searchPlaceholder)", attributes: attributeDict)
            }
        
        searchBar.layer.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        transparentView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        tableView.reloadData()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(removeTransparentView))
        
        transparentView.addGestureRecognizer(tapGesture)
        transparentView.alpha = 0
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .transitionCurlDown, animations: {
            self.transparentView.alpha = 0.5
            self.searchBar.frame = CGRect(x: frames.minX + 20, y: frames.midY - 200, width: frames.width - 40, height: 50)
            self.tableView.frame = CGRect(x: frames.minX + 20, y: frames.midY - 150, width: frames.width - 40, height: 300)
        }, completion: nil)
    }
    
    @objc func removeTransparentView() {
        let frames = self.view.frame
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .transitionCurlDown, animations: {
            self.transparentView.alpha = 0
            self.searchBar.frame = CGRect(x: frames.minX + 20, y: frames.maxY, width: frames.width - 40, height: 0)
            self.tableView.frame = CGRect(x: frames.minX + 20, y: frames.maxY, width: frames.width - 40, height: 0)
            self.searchBar.text = ""
            self.searching = false
            self.tableView.reloadData()
            self.searchBar.resignFirstResponder()
        }, completion: nil)
        
        if didSelect {
            didSelect = false
        } else {
            if arrayYear.isEmpty {
                arrayYear = arrayBeforeFilter
            }
            if arrayMonth.isEmpty {
                arrayMonth = arrayBeforeFilter
            }
            if arrayMedia.isEmpty {
                arrayMedia = arrayBeforeFilter
            }
            if arrayProvider.isEmpty {
                arrayProvider = arrayBeforeFilter
            }
            if arrayCampaign.isEmpty {
                arrayCampaign = arrayBeforeFilter
            }
            print("No hubo cambio en filtro")
        }
    }
    
    func addTransparentViewB(searchPlaceholder: String) {
        //let screen = CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        let frames = self.view.frame
        transparentView.frame = self.view.frame
        
        self.view.addSubview(transparentView)
        //self.view.addSubview(searchBar)
        self.view.addSubview(tableViewB)
        
        //self.searchBar.frame = CGRect(x: frames.minX + 20, y: frames.maxY, width: frames.width - 40, height: 0)
        self.tableViewB.frame = CGRect(x: frames.minX + 20, y: frames.maxY, width: frames.width - 40, height: 0)
        
//        let searchTextField: UITextField? = searchBar.value(forKey: "searchField") as? UITextField
//            if searchTextField!.responds(to: #selector(getter: UITextField.attributedPlaceholder)) {
//                let attributeDict = [NSAttributedString.Key.foregroundColor: UIColor.black]
//                searchTextField!.attributedPlaceholder = NSAttributedString(string: "Buscar \(searchPlaceholder)", attributes: attributeDict)
//            }
    
        //searchBar.layer.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        transparentView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        tableViewB.reloadData()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(removeTransparentViewB))
        
        transparentView.addGestureRecognizer(tapGesture)
        transparentView.alpha = 0
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .transitionCurlDown, animations: {
            self.transparentView.alpha = 0.5
            //self.searchBar.frame = CGRect(x: frames.minX + 20, y: frames.midY - 200, width: frames.width - 40, height: 50)
            self.tableViewB.frame = CGRect(x: frames.minX + 20, y: frames.midY - 150, width: frames.width - 40, height: 300)
        }, completion: nil)
    }
    
    @objc func removeTransparentViewB() {
        let frames = self.view.frame
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .transitionCurlDown, animations: {
            self.transparentView.alpha = 0
            //self.searchBar.frame = CGRect(x: frames.minX + 20, y: frames.maxY, width: frames.width - 40, height: 0)
            self.tableViewB.frame = CGRect(x: frames.minX + 20, y: frames.maxY, width: frames.width - 40, height: 0)
            //self.searchBar.text = ""
            //self.searching = false
            self.tableViewB.reloadData()
            //self.searchBar.resignFirstResponder()
        }, completion: nil)
        
        if didSelect {
            didSelect = false
        } else {
            if arrayBrand.isEmpty {
                arrayBrand = arrayBeforeFilterB
            }

            print("No hubo cambio en filtro")
        }
    }
    @IBAction func onClickBtnYear(_ sender: UIButton) {
        dataSource = yearList
        selectedButton = buttonYear
        arrayBeforeFilter = arrayYear
        arrayYear.removeAll()
        didSelect = false
        tableView.reloadData()
        addTransparentView(searchPlaceholder: "año...")
    }
    @IBAction func onClickBtnMonth(_ sender: UIButton) {
        dataSource = monthList
        selectedButton = buttonMonth
        arrayBeforeFilter = arrayMonth
        arrayMonth.removeAll()
        didSelect = false
        tableView.reloadData()
        addTransparentView(searchPlaceholder: "mes...")
    }
    @IBAction func onClickBtnMedia(_ sender: UIButton) {
        dataSource = mediaList
        selectedButton = buttonMedia
        arrayBeforeFilter = arrayMedia
        arrayMedia.removeAll()
        didSelect = false
        tableView.reloadData()
        addTransparentView(searchPlaceholder: "medio...")
    }
    @IBAction func onClickBtnProvider(_ sender: UIButton) {
        dataSource = providerList
        selectedButton = buttonProvider
        arrayBeforeFilter = arrayProvider
        arrayProvider.removeAll()
        didSelect = false
        tableView.reloadData()
        addTransparentView(searchPlaceholder: "proveedor...")
    }
    @IBAction func onClickBtnCampaign(_ sender: UIButton) {
        dataSource = campaignList
        selectedButton = buttonCampaign
        arrayBeforeFilter = arrayCampaign
        arrayCampaign.removeAll()
        didSelect = false
        tableView.reloadData()
        addTransparentView(searchPlaceholder: "campaña...")
    }
    
    @IBAction func onClickBtnBrand(_ sender: UIButton) {
        dataSourceB = brandList
        selectedButton = buttonBrand
        arrayBeforeFilterB = arrayBrand
        arrayBrand.removeAll()
        didSelect = false
        tableViewB.reloadData()
        addTransparentViewB(searchPlaceholder: "marca...")
    }
    @IBAction func applyFilters(_ sender: UIButton) {
        self.dismiss(animated: true) {
            InversionManager.shared.inversionVC.arrayYear = self.arrayYear
            InversionManager.shared.inversionVC.arrayMonth = self.arrayMonth
            InversionManager.shared.inversionVC.arrayMedia = self.arrayMedia
            InversionManager.shared.inversionVC.arrayProvider = self.arrayProvider
            InversionManager.shared.inversionVC.arrayCampaign = self.arrayCampaign
            InversionManager.shared.inversionVC.arrayBrand = self.arrayBrand
            
            let filterList = self.brandList.filter(){$0.id == self.arrayBrand[0]}
            InversionManager.shared.inversionVC.tabAdMarca.setTitle(filterList[0].name, for: .normal)
            InversionManager.shared.inversionVC.showChart()
        }
    }
    @IBAction func closeInversionFilter(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}


extension InversionFiltersVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
            if searching {
                return dataSearch.count + 1
            } else {
                return dataSource.count + 1
            }
        } else {
            return dataSourceB.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == self.tableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "InversionCell", for: indexPath)
            
            cell.textLabel?.font = UIFont(name: "Georgia",
                                          size: 15.0)
            
            if indexPath.row == 0 {
                cell.textLabel?.text = "Todos"
            } else {
                if searching {
                    cell.textLabel?.text = dataSearch[indexPath.row - 1].name
                } else {
                    cell.textLabel?.text = dataSource[indexPath.row - 1].name
                }
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "InversionCell", for: indexPath)
            
            cell.textLabel?.font = UIFont(name: "Georgia",
                                          size: 15.0)
            
            cell.textLabel?.text = dataSourceB[indexPath.row].name
            
            return cell
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == self.tableView {
            var arrayValues = [Int]()
            
            switch (selectedButton) {
                case buttonYear:
                    arrayValues = arrayYear
                case buttonMonth:
                    arrayValues = arrayMonth
                case buttonMedia:
                    arrayValues = arrayMedia
                case buttonProvider:
                    arrayValues = arrayProvider
                case buttonCampaign:
                    arrayValues = arrayCampaign
                default:
                    arrayValues = arrayYear
            }
            
            var valueSelected: FilterBody
            if indexPath.row == 0 {
                valueSelected = FilterBody(id: -1, name: "Todos")
            } else {
                if searching {
                    valueSelected = FilterBody(id: dataSearch[indexPath.row - 1].id, name: dataSearch[indexPath.row - 1].name)
                } else {
                    valueSelected = FilterBody(id: dataSource[indexPath.row - 1].id, name: dataSource[indexPath.row - 1].name)
                }
            }
            
            if valueSelected.id == -1 {
                for section in 0..<tableView.numberOfSections {
                    for row in 0..<tableView.numberOfRows(inSection: section) {
                        let indexPath = IndexPath(row: row, section: section)
                        tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                    }
                }
                arrayValues.removeAll()
                for i in 0..<dataSource.count {
                    arrayValues.append(dataSource[i].id)
                }
            } else {
                arrayValues.append(valueSelected.id)
            }
            
            if arrayValues.count == 1 {
                selectedButton.setTitle(valueSelected.name, for: .normal)
            } else if arrayValues.count > 1 && arrayValues.count < dataSource.count {
                selectedButton.setTitle("Varios", for: .normal)
            } else if arrayValues.count >= dataSource.count {
                let indexPath = IndexPath(row: 0, section: 0)
                tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                selectedButton.setTitle("Todos", for: .normal)
            }
            
            switch (selectedButton) {
                case buttonYear:
                    arrayYear = arrayValues
                case buttonMonth:
                    arrayMonth = arrayValues
                case buttonMedia:
                    arrayMedia = arrayValues
                case buttonProvider:
                    arrayProvider = arrayValues
                case buttonCampaign:
                    arrayCampaign = arrayValues
                default:
                    arrayYear = arrayValues
            }
            
            didSelect = true
        } else {
            var arrayValues = [String]()
            
            switch (selectedButton) {
                case buttonBrand:
                    arrayValues = arrayBrand
                default:
                    arrayValues = arrayBrand
            }
            
            let valueSelected = Brand(id: dataSourceB[indexPath.row].id, name: dataSourceB[indexPath.row].name)
            
            arrayValues.append(valueSelected.id)
            
            selectedButton.setTitle(valueSelected.name, for: .normal)
            
            switch (selectedButton) {
                case buttonBrand:
                    arrayBrand = arrayValues
                default:
                    arrayBrand = arrayValues
            }
            
            didSelect = true
            removeTransparentViewB()
        }
        
        
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        if tableView == self.tableView {
            var arrayValues = [Int]()
            switch (selectedButton) {
                case buttonYear:
                    arrayValues = arrayYear
                case buttonMonth:
                    arrayValues = arrayMonth
                case buttonMedia:
                    arrayValues = arrayMedia
                case buttonProvider:
                    arrayValues = arrayProvider
                case buttonCampaign:
                    arrayValues = arrayCampaign
                default:
                    arrayValues = arrayYear
            }
            var valueSelected: FilterBody
            if indexPath.row == 0 {
                valueSelected = FilterBody(id: -1, name: "Todos")
            } else {
                if searching {
                    valueSelected = FilterBody(id: dataSearch[indexPath.row - 1].id, name: dataSearch[indexPath.row - 1].name)
                } else {
                    valueSelected = FilterBody(id: dataSource[indexPath.row - 1].id, name: dataSource[indexPath.row - 1].name)
                }
            }
            
            if valueSelected.id == -1 {
                for section in 0..<tableView.numberOfSections {
                    for row in 0..<tableView.numberOfRows(inSection: section) {
                        let indexPath = IndexPath(row: row, section: section)
                        tableView.deselectRow(at: indexPath, animated: false)
                    }
                }
                arrayValues.removeAll()
            } else {
                arrayValues = arrayValues.filter(){$0 != valueSelected.id}
            }
            
            
            if arrayValues.count == 1 {
                let nameLeft: [FilterBody] = dataSource.filter(){$0.id == arrayValues[0]}
                selectedButton.setTitle(nameLeft[0].name, for: .normal)
            } else if arrayValues.count > 1 && arrayValues.count < dataSource.count {
                let indexPath = IndexPath(row: 0, section: 0)
                tableView.deselectRow(at: indexPath, animated: false)
                selectedButton.setTitle("Varios", for: .normal)
            } else if arrayValues.count >= dataSource.count {
                selectedButton.setTitle("Todos", for: .normal)
            } else if arrayValues.count == 0 {
                didSelect = false
            }
            
            switch (selectedButton) {
                case buttonYear:
                    arrayYear = arrayValues
                case buttonMonth:
                    arrayMonth = arrayValues
                case buttonMedia:
                    arrayMedia = arrayValues
                case buttonProvider:
                    arrayProvider = arrayValues
                case buttonCampaign:
                    arrayCampaign = arrayValues
                default:
                    arrayYear = arrayValues
            }
        }
        
    }
}

extension InversionFiltersVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        dataSearch = dataSource.filter({$0.name.uppercased().contains(searchText.uppercased())})
        if searchText != "" {
            searching = true
        } else {
            searching = false
        }
        tableView.reloadData()
        var arrayValues = [Int]()
        
        switch (selectedButton) {
            case buttonYear:
                arrayValues = arrayYear
            case buttonMonth:
                arrayValues = arrayMonth
            case buttonMedia:
                arrayValues = arrayMedia
            case buttonProvider:
                arrayValues = arrayProvider
            case buttonCampaign:
                arrayValues = arrayCampaign
            default:
                arrayValues = arrayYear
        }
        
        var arrayNames = [String]()
        for i in 0..<arrayValues.count {
            let index = dataSource.firstIndex(where: { $0.id == arrayValues[i]})
            arrayNames.append(dataSource[Int(index!)].name)
        }
        
        for section in 0..<tableView.numberOfSections {
            for row in 0..<tableView.numberOfRows(inSection: section) {
                let indexPath = IndexPath(row: row, section: section)
                if arrayNames.contains(tableView.cellForRow(at: indexPath)?.textLabel?.text ?? "-999" ) {
                    tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                }
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        switch (selectedButton) {
            case buttonYear:
                arrayYear.removeAll()
            case buttonMonth:
                arrayMonth.removeAll()
            case buttonMedia:
                arrayMedia.removeAll()
            case buttonProvider:
                arrayProvider.removeAll()
            case buttonCampaign:
                arrayCampaign.removeAll()
            default:
                arrayYear.removeAll()
        }
    }
}
