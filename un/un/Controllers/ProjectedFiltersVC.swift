//
//  ProjectedFiltersVC.swift
//  un
//
//  Created by Andres Liu on 1/20/21.
//

import UIKit

class ProjectedFiltersVC: UIViewController {

    @IBOutlet weak var buttonMedia: UIButton!
    @IBOutlet weak var buttonProvider: UIButton!
    @IBOutlet weak var buttonVehicle: UIButton!
    
    let transparentView = UIView()
    let searchBar = UISearchBar()
    let tableView = UITableView()
    var selectedButton = UIButton()
    
    var dataSource = [FilterBody]()
    var dataSearch = [FilterBody]()
    
    var searching = false
    var didSelect = false
    
    var arrayMedia = [Int]()
    var arrayProvider = [Int]()
    var arrayVehicle = [Int]()
    
    var arrayBeforeFilter = [Int]()
    
    var mediaList = [FilterBody]()
    var providerList = [FilterBody]()
    var vehicleList = [FilterBody]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(FilterCell.self, forCellReuseIdentifier: "FilterCell")
        tableView.allowsMultipleSelection = true
        tableView.allowsMultipleSelectionDuringEditing = true
        searchBar.delegate = self
        ProjectedFilterManager.shared.projectedFiltersVC = self
        
        buttonMedia.addCustomStyle(borderWidth: 1)
        buttonProvider.addCustomStyle(borderWidth: 1)
        buttonVehicle.addCustomStyle(borderWidth: 1)
        
    }
    
    func changeButtonTitle(_ button: UIButton, _ arrayFilter: [Int], _ list: [FilterBody]) {
        if arrayFilter.count <= 1 {
            if arrayFilter == arrayMedia {
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
            if arrayMedia.isEmpty {
                arrayMedia = arrayBeforeFilter
            }
            if arrayProvider.isEmpty {
                arrayProvider = arrayBeforeFilter
            }
            if arrayVehicle.isEmpty {
                arrayVehicle = arrayBeforeFilter
            }
            print("No hubo cambio en filtro")
        }
    }
    
    @IBAction func onCLickBtnMedia(_ sender: UIButton) {
        dataSource = mediaList
        selectedButton = buttonMedia
        arrayBeforeFilter = arrayMedia
        arrayMedia.removeAll()
        didSelect = false
        tableView.reloadData()
        addTransparentView(searchPlaceholder: "medio...")
    }
    @IBAction func onCLickBtnProvider(_ sender: UIButton) {
        dataSource = providerList
        selectedButton = buttonProvider
        arrayBeforeFilter = arrayProvider
        arrayProvider.removeAll()
        didSelect = false
        tableView.reloadData()
        addTransparentView(searchPlaceholder: "proveedor...")
    }
    @IBAction func onCLickBtnVehicle(_ sender: UIButton) {
        dataSource = vehicleList
        selectedButton = buttonVehicle
        arrayBeforeFilter = arrayVehicle
        arrayVehicle.removeAll()
        didSelect = false
        tableView.reloadData()
        addTransparentView(searchPlaceholder: "vehículo...")
    }
    @IBAction func applyFilters(_ sender: UIButton) {
        self.dismiss(animated: true) {
            
            ProjectedManager.shared.projectedVC.arrayMedia = self.arrayMedia
            ProjectedManager.shared.projectedVC.arrayProvider = self.arrayProvider
            ProjectedManager.shared.projectedVC.arrayVehicle = self.arrayVehicle

            ProjectedManager.shared.projectedVC.getBarChart()
        }
    }
    @IBAction func returnToReport(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension ProjectedFiltersVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            return dataSearch.count + 1
        } else {
            return dataSource.count + 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell", for: indexPath)
        
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
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var arrayValues = [Int]()
        
        switch (selectedButton) {
            case buttonMedia:
                arrayValues = arrayMedia
            case buttonProvider:
                arrayValues = arrayProvider
            case buttonVehicle:
                arrayValues = arrayVehicle
            default:
                arrayValues = arrayMedia
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
            case buttonMedia:
                arrayMedia = arrayValues
            case buttonProvider:
                arrayProvider = arrayValues
            case buttonVehicle:
                arrayVehicle = arrayValues
            default:
                arrayMedia = arrayValues
        }
        
        didSelect = true
    
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        var arrayValues = [Int]()
        switch (selectedButton) {
            case buttonMedia:
                arrayValues = arrayMedia
            case buttonProvider:
                arrayValues = arrayProvider
            case buttonVehicle:
                arrayValues = arrayVehicle
            default:
                arrayValues = arrayMedia
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
            case buttonMedia:
                arrayMedia = arrayValues
            case buttonProvider:
                arrayProvider = arrayValues
            case buttonVehicle:
                arrayVehicle = arrayValues
            default:
                arrayMedia = arrayValues
        }
    }
}

extension ProjectedFiltersVC: UITableViewDelegate {
    
}

extension ProjectedFiltersVC: UISearchBarDelegate {
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
            case buttonMedia:
                arrayValues = arrayMedia
            case buttonProvider:
                arrayValues = arrayProvider
            case buttonVehicle:
                arrayValues = arrayVehicle
            default:
                arrayValues = arrayMedia
        }
        
        var arrayNames = [String]()
        for i in 0..<arrayValues.count {
            let index = dataSource.firstIndex(where: { $0.id == arrayValues[i]})
            arrayNames.append(dataSource[Int(index!)].name)
        }
        
        for section in 0..<tableView.numberOfSections {
            for row in 0..<tableView.numberOfRows(inSection: section) {
                let indexPath = IndexPath(row: row, section: section)
                if arrayNames.contains(tableView.cellForRow(at: indexPath)?.textLabel?.text ?? "-999") {
                    tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                }
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        switch (selectedButton) {
            case buttonMedia:
                arrayMedia.removeAll()
            case buttonProvider:
                arrayProvider.removeAll()
            case buttonVehicle:
                arrayVehicle.removeAll()
            default:
                arrayMedia.removeAll()
        }
    }
}
