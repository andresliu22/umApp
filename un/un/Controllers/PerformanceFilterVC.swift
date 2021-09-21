//
//  PerformanceFilterVC.swift
//  un
//
//  Created by Andres Liu on 1/24/21.
//

import UIKit

class PerformanceFilterVC: UIViewController {

    @IBOutlet weak var buttonCampaign: UIButton!
    @IBOutlet weak var startDateTxt: UITextField!
    @IBOutlet weak var finishDateTxt: UITextField!
    
    var campaignList = [FilterBody]()
    var arrayCampaign = ["ICE CHILL"]
    var arrayBeforeFilter = [String]()
    
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
        
        PerformanceFilterManager.shared.performanceFiltersVC = self
        buttonCampaign.addCustomStyle(borderWidth: 1)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(FilterCell.self, forCellReuseIdentifier: "FilterCell")
        self.searchBar.delegate = self
        self.tableView.reloadData()
        
        startDateTxt.layer.borderWidth = 1
        startDateTxt.layer.borderColor = UIColor.black.cgColor
        startDateTxt.setLeftPaddingPoints(5.0)
        startDateTxt.datePicker(target: self,
                                          doneAction: #selector(startDoneAction),
                                          cancelAction: #selector(startCancelAction),
                                          datePickerMode: .date)
        finishDateTxt.layer.borderWidth = 1
        finishDateTxt.layer.borderColor = UIColor.black.cgColor
        finishDateTxt.setLeftPaddingPoints(5.0)
        finishDateTxt.datePicker(target: self,
                                          doneAction: #selector(finishDoneAction),
                                          cancelAction: #selector(finishCancelAction),
                                          datePickerMode: .date)
    }
    
    func changeButtonTitle(_ button: UIButton, _ arrayFilter: [Int], _ list: [FilterBody]) {
        if arrayFilter.count <= 1 {
            let filterList = list.filter(){$0.id == arrayFilter[0]}
            button.setTitle(filterList[0].name, for: .normal)
        } else if arrayFilter.count < list.count {
            button.setTitle("Varios", for: .normal)
        } else {
            button.setTitle("Todos", for: .normal)
        }
    }

    func addTransparentView(searchPlaceholder: String) {
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
            if arrayCampaign.isEmpty {
                arrayCampaign = arrayBeforeFilter
            }
            print("No hubo cambio en filtro")
        }
    }
    
    @objc func startCancelAction() {
        self.startDateTxt.resignFirstResponder()
    }

    @objc func startDoneAction() {
        if let datePickerView = self.startDateTxt.inputView as? UIDatePicker {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            let dateString = dateFormatter.string(from: datePickerView.date)
            self.startDateTxt.text = dateString
            
            print(datePickerView.date)
            print(dateString)
            
            self.startDateTxt.resignFirstResponder()
        }
    }
    
    @objc func finishCancelAction() {
        self.finishDateTxt.resignFirstResponder()
    }

    @objc func finishDoneAction() {
        if let datePickerView = self.finishDateTxt.inputView as? UIDatePicker {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            let dateString = dateFormatter.string(from: datePickerView.date)
            self.finishDateTxt.text = dateString
            
            print(datePickerView.date)
            print(dateString)
            
            self.finishDateTxt.resignFirstResponder()
        }
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
    
    @IBAction func goToMotiveList(_ sender: UIButton) {
        self.dismiss(animated: true) {
            PerformanceManager.shared.performanceVC.goToMotiveList()
        }
    }
    
    @IBAction func applyFilters(_ sender: UIButton) {
        self.dismiss(animated: true) {
            PerformanceManager.shared.performanceVC.arrayCampaign = self.arrayCampaign
            PerformanceManager.shared.performanceVC.startDate = self.startDateTxt.text!
            PerformanceManager.shared.performanceVC.finishDate = self.finishDateTxt.text!
            PerformanceManager.shared.performanceVC.getPerformance()
        }
    }
    @IBAction func closeFilter(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension PerformanceFilterVC: UITableViewDataSource {
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
        
        if tableView == self.tableView {
            var arrayValues = [String]()

            switch (selectedButton) {
                case buttonCampaign:
                    arrayValues = arrayCampaign
                default:
                    arrayValues = arrayCampaign
            }

            var value: String = ""

            if searching {
                value = dataSearch[indexPath.row].name
            } else {
                value = dataSource[indexPath.row].name
            }

            arrayValues.append(value)
            selectedButton.setTitle(value, for: .normal)

            switch (selectedButton) {
                case buttonCampaign:
                    arrayCampaign = arrayValues
                default:
                    arrayCampaign = arrayValues
            }
            didSelect = true
            print(arrayValues)
            removeTransparentView()
        }
    }
    
}

extension PerformanceFilterVC: UITableViewDelegate {
    
}

extension PerformanceFilterVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        dataSearch = dataSource.filter({$0.name.uppercased().contains(searchText.uppercased())})
        if searchText != "" {
            searching = true
        } else {
            searching = false
        }
        tableView.reloadData()
    }
}
