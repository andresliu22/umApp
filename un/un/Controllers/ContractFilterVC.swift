//
//  ContractFilterVC.swift
//  un
//
//  Created by Andres Liu on 1/20/21.
//

import UIKit

class ContractFilterVC: UIViewController {

    
    @IBOutlet weak var buttonProvider: UIButton!
    @IBOutlet weak var buttonYear: UIButton!
    
    var arrayProvider = [Int]()
    var arrayYear = [Int]()
    
    var providerList = [FilterBody]()
    var yearList = [FilterBody]()
    
    var arrayBeforeFilter = [Int]()
    
    let transparentView = UIView()
    let searchBar = UISearchBar()
    let tableView = UITableView()
    var selectedButton = UIButton()
    
    var dataSource = [FilterBody]()
    var dataSearch = [FilterBody]()
    
    var searching = false
    var didSelect = false
    override func viewDidLoad() {
        super.viewDidLoad()

        buttonProvider.addCustomStyle(borderWidth: 1)
        buttonYear.addCustomStyle(borderWidth: 1)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(FilterCell.self, forCellReuseIdentifier: "FilterCell")

        self.searchBar.delegate = self
        
        ContractFilterManager.shared.contractFiltersVC = self
    }
    
    func changeButtonTitle(_ button: UIButton, _ arrayFilter: [Int], _ list: [FilterBody]) {
        if arrayFilter.count <= 1 {
            let filterList = list.filter(){$0.id == arrayFilter[0]}
            if filterList.count < 1 {
                button.setTitle("", for: .normal)
            } else {
                button.setTitle(filterList[0].name, for: .normal)
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
            if arrayProvider.isEmpty {
                arrayProvider = arrayBeforeFilter
            }
            if arrayYear.isEmpty {
                arrayYear = arrayBeforeFilter
            }
            print("No hubo cambio en filtro")
        }
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
    
    @IBAction func onClickBtnYear(_ sender: UIButton) {
        dataSource = yearList
        selectedButton = buttonYear
        arrayBeforeFilter = arrayYear
        arrayYear.removeAll()
        didSelect = false
        tableView.reloadData()
        addTransparentView(searchPlaceholder: "año...")
    }
    @IBAction func applyFilters(_ sender: UIButton) {
        self.dismiss(animated: true) {
            ContractManager.shared.contractVC.arrayYear = self.arrayYear
            ContractManager.shared.contractVC.arrayProvider = self.arrayProvider
            ContractManager.shared.contractVC.getBarChart()
        }
    }
    @IBAction func closeFilter(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension ContractFilterVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searching {
            return dataSearch.count
        } else {
            return dataSource.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell", for: indexPath)
        cell.textLabel?.font = UIFont(name: "Georgia",
                                      size: 15.0)
        if searching {
            cell.textLabel?.text = dataSearch[indexPath.row].name
        } else {
            cell.textLabel?.text = dataSource[indexPath.row].name
        }
        
        return cell
            
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var arrayValues = [Int]()
        
        switch (selectedButton) {
            case buttonProvider:
                arrayValues = arrayProvider
            case buttonYear:
                arrayValues = arrayYear
            default:
                arrayValues = arrayProvider
        }
        
        
        var valueSelected: FilterBody
        if searching {
            valueSelected = FilterBody(id: dataSearch[indexPath.row].id, name: dataSearch[indexPath.row].name)
        } else {
            valueSelected = FilterBody(id: dataSource[indexPath.row].id, name: dataSource[indexPath.row].name)
        }
        
        arrayValues.append(valueSelected.id)
        
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
            case buttonProvider:
                arrayProvider = arrayValues
            case buttonYear:
                arrayYear = arrayValues
            default:
                arrayProvider = arrayValues
        }
        
        didSelect = true
        print(arrayValues)
        removeTransparentView()
        
    }
    
}

extension ContractFilterVC: UITableViewDelegate {
    
}

extension ContractFilterVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        dataSearch = dataSource.filter({$0.name.uppercased().contains(searchText.uppercased())})
        if searchText != "" {
            searching = true
        } else {
            searching = false
        }
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        switch (selectedButton) {
            case buttonProvider:
                arrayProvider.removeAll()
            case buttonYear:
                arrayYear.removeAll()
            default:
                arrayProvider.removeAll()
        }
    }
}
