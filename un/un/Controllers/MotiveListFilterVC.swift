//
//  MotiveListFilterVC.swift
//  un
//
//  Created by Andres Liu on 1/24/21.
//

import UIKit

class MotiveListFilterVC: UIViewController {

    @IBOutlet weak var buttonOrder: UIButton!
    
    let transparentView = UIView()
    let tableView = UITableView()
    var selectedButton = UIButton()
    
    var dataSource = [String]()
    
    var didSelect = false
    
    var defaultOrder = "Inversion"
    var indexOrder = 0
    
    var motivoSeleccionado = ""
    var campaignName = ""
    var startDate = ""
    var endDate = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        MotiveFilterManager.shared.motiveListFiltersVC = self
        buttonOrder.addCustomStyle(borderWidth: 1)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.register(FilterCell.self, forCellReuseIdentifier: "FilterCell")
        
    }
    
    func addTransparentView(searchPlaceholder: String) {
        let frames = self.view.frame
        transparentView.frame = self.view.frame
        
        self.view.addSubview(transparentView)
        self.view.addSubview(tableView)
        
        self.tableView.frame = CGRect(x: frames.minX + 20, y: frames.maxY, width: frames.width - 40, height: 0)
        
        transparentView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        tableView.reloadData()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(removeTransparentView))
        
        transparentView.addGestureRecognizer(tapGesture)
        transparentView.alpha = 0
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .transitionCurlDown, animations: {
            self.transparentView.alpha = 0.5
            self.tableView.frame = CGRect(x: frames.minX + 20, y: frames.midY - 150, width: frames.width - 40, height: 300)
        }, completion: nil)
    }
    
    @objc func removeTransparentView() {
        let frames = self.view.frame
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .transitionCurlDown, animations: {
            self.transparentView.alpha = 0
            self.tableView.frame = CGRect(x: frames.minX + 20, y: frames.maxY, width: frames.width - 40, height: 0)
            self.tableView.reloadData()
        }, completion: nil)
        
        if didSelect {
            didSelect = false
        } else {
            print("No hubo cambio en filtro")
        }
    }

    @IBAction func onClickBtnOrder(_ sender: UIButton) {
        dataSource = ["Inversion", "Alcance", "Impresion", "Clicks", "CTR", "CPC", "Video views", "VTR", "Post reactions", "Post comments", "Post shares"]
        selectedButton = buttonOrder
        didSelect = false
        tableView.reloadData()
        addTransparentView(searchPlaceholder: "motivo...")
    }
    
    @IBAction func applyFilters(_ sender: Any) {
        self.dismiss(animated: true) {
            MotiveManager.shared.motiveListVC.defaultOrder = self.defaultOrder
            MotiveManager.shared.motiveListVC.indexOrder = self.indexOrder
            MotiveManager.shared.motiveListVC.getMotivos()
        }
    }
    
    @IBAction func closeFilter(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension MotiveListFilterVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell", for: indexPath)
        cell.textLabel?.font = UIFont(name: "Georgia",
                                      size: 15.0)

        cell.textLabel?.text = dataSource[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let value: String = dataSource[indexPath.row]
        selectedButton.setTitle(value, for: .normal)
        defaultOrder = value
        indexOrder = indexPath.row
        didSelect = true
        removeTransparentView()
        
    }
    
}

extension MotiveListFilterVC: UITableViewDelegate {
    
}
