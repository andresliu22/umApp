//
//  ImplementationFiltersVC.swift
//  un
//
//  Created by Andres Liu on 1/18/21.
//

import UIKit

class ImplementationFiltersVC: UIViewController {

    @IBOutlet weak var buttonCampaign: UIButton!
    @IBOutlet weak var buttonMedia: UIButton!
    
    let transparentView = UIView()
    let searchBar = UISearchBar()
    let tableView = UITableView()
    var selectedButton = UIButton()
    
    var dataSource = [FilterBody]()
    var dataSearch = [FilterBody]()
    
    var searching = false
    var didSelect = false
    
    var arrayCampaign = [Int]()
    var arrayMedia = [Int]()
    
    var mediaList = [FilterBody]()
    var campaignList = [FilterBody]()
    
    var arrayBeforeFilter = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ImplementationFilterManager.shared.implementationFiltersVC = self
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(FilterCell.self, forCellReuseIdentifier: "ImplementationCell")
        self.tableView.allowsMultipleSelection = false
        self.tableView.allowsMultipleSelectionDuringEditing = false
        self.searchBar.delegate = self
        
        buttonMedia.addBorders(width: 1)
        buttonCampaign.addBorders(width: 1)
        buttonMedia.titleEdgeInsets.left = 10
        buttonCampaign.titleEdgeInsets.left = 10
        buttonMedia.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        buttonCampaign.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        
    }
    
    func changeButtonTitle(_ button: UIButton, _ arrayFilter: [Int], _ list: [FilterBody]) {
        guard arrayFilter.count > 0 else {
            button.setTitle("", for: .normal)
            return
        }
        let filterList = list.filter(){$0.id == arrayFilter[0]}
        if filterList.count < 1 {
            button.setTitle("", for: .normal)
        } else {
            button.setTitle(filterList[0].name, for: .normal)
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
    
    @IBAction func onClickBtnMedia(_ sender: UIButton) {
        dataSource = mediaList
        selectedButton = buttonMedia
        arrayBeforeFilter = arrayMedia
        arrayMedia.removeAll()
        didSelect = false
        tableView.reloadData()
        addTransparentView(searchPlaceholder: "medio...")
    }
    
    @IBAction func applyFilters(_ sender: UIButton) {
        self.dismiss(animated: true) {
            print(self.arrayMedia)
            print(self.arrayCampaign)
            ImplementationManager.shared.implementationVC.arrayCampaign = self.arrayCampaign
            ImplementationManager.shared.implementationVC.arrayMedia = self.arrayMedia
            ImplementationManager.shared.implementationVC.getCampaigns()
        }
    }
    @IBAction func returnToImplementation(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension ImplementationFiltersVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            return dataSearch.count
        } else {
            return dataSource.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ImplementationCell", for: indexPath)
        
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
            case buttonMedia:
                arrayValues = arrayMedia
            case buttonCampaign:
                arrayValues = arrayCampaign
            default:
                arrayValues = arrayMedia
        }
        
        var valueSelected: FilterBody
        
        if searching {
            valueSelected = FilterBody(id: dataSearch[indexPath.row].id, name: dataSearch[indexPath.row].name)
        } else {
            valueSelected = FilterBody(id: dataSource[indexPath.row].id, name: dataSource[indexPath.row].name)
        }
        
        arrayValues.append(valueSelected.id)
        selectedButton.setTitle(valueSelected.name, for: .normal)
        
        switch (selectedButton) {
            case buttonMedia:
                arrayMedia = arrayValues
            case buttonCampaign:
                arrayCampaign = arrayValues
            default:
                arrayMedia = arrayValues
        }
        didSelect = true
        removeTransparentView()
    }
}

extension ImplementationFiltersVC: UISearchBarDelegate {
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
            case buttonMedia:
                arrayMedia.removeAll()
            case buttonCampaign:
                arrayCampaign.removeAll()
            default:
                arrayMedia.removeAll()
        }
    }
}
