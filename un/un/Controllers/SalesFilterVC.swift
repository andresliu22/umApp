//
//  SalesFilterVC.swift
//  un
//
//  Created by Andres Liu on 1/24/21.
//

import UIKit

class SalesFilterVC: UIViewController {

    @IBOutlet weak var buttonCampaign: UIButton!
    
    var arrayCampaign = ["ICE CHILL"]
    var campaignList = [FilterBody]()
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

        SalesFilterManager.shared.salesFilterVC = self
        self.searchBar.delegate = self
        buttonCampaign.addCustomStyle(borderWidth: 1)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(FilterCell.self, forCellReuseIdentifier: "FilterCell")
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
    
    @IBAction func onClickBtnCampaign(_ sender: UIButton) {
        dataSource = campaignList
        selectedButton = buttonCampaign
        arrayBeforeFilter = arrayCampaign
        arrayCampaign.removeAll()
        didSelect = false
        tableView.reloadData()
        addTransparentView(searchPlaceholder: "campaña...")
    }
    
    @IBAction func applyFilters(_ sender: UIButton) {
        self.dismiss(animated: true) {
            SalesManager.shared.salesVC.arrayCampaign = self.arrayCampaign
            SalesManager.shared.salesVC.getVentas()
        }
    }
    @IBAction func closeFilter(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension SalesFilterVC: UITableViewDataSource {
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

extension SalesFilterVC: UITableViewDelegate {
}

extension SalesFilterVC: UISearchBarDelegate {
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
