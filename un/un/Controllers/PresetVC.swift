//
//  PresetVC.swift
//  un
//
//  Created by Andres Liu on 1/27/21.
//

import UIKit

class PresetVC: UIViewController {

    @IBOutlet weak var presetTableView: UITableView!
    
    var presetName = UserDefaults.standard.array(forKey: "presetName") as? [String] ?? [String]()
    
    var presetArray = UserDefaults.standard.array(forKey: "presetArray") as? [[[Int]]] ?? [[[Int]]]()
    
    var presetSelected = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        PresetManager.shared.presetVC = self
        presetTableView.dataSource = self
        presetTableView.delegate = self
    }
    
    @objc func accessoryButtonTapped(sender: UIButton){
        presetSelected = sender.tag
        let deletePresetVC = storyboard?.instantiateViewController(identifier: "DeletePresetVC") as! DeletePresetVC
        deletePresetVC.modalPresentationStyle = .overCurrentContext
        deletePresetVC.presetSelected = self.presetSelected
//        deletePresetVC.presetNameLabel.text = self.presetName[self.presetSelected]
        self.present(deletePresetVC, animated: true, completion: nil)
    }

    @IBAction func closeMenu(_ sender: UIButton) {
//        self.navigationController?.popToViewController(ofClass: ReportListVC.self, animated: true)
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func returnToMenu(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension PresetVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presetName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
//        let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuCell", for: indexPath)
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "SideMenuCell")
        
        cell.textLabel?.font = UIFont(name: "Georgia",
                                      size: 15.0)
        cell.textLabel?.text = presetName[indexPath.row]
        
        let xButton = UIButton(type: .custom)
        xButton.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        xButton.addTarget(self, action: #selector(accessoryButtonTapped(sender:)), for: .touchUpInside)
        xButton.setImage(UIImage(systemName: "xmark")!.withTintColor(.darkGray, renderingMode: .alwaysOriginal), for: .normal)
        xButton.contentMode = .scaleAspectFit
        xButton.tag = indexPath.row
        cell.accessoryView = xButton as UIView
        
        //cell.accessoryView = UIImageView(image: UIImage(systemName: "xmark")!.withTintColor(.darkGray, renderingMode: .alwaysOriginal))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let inversion = storyboard!.instantiateViewController(withIdentifier: "InversionVC") as! InversionVC
        inversion.arrayVacio = false
        inversion.arrayYear = self.presetArray[indexPath.row][0]
        inversion.arrayMonth = self.presetArray[indexPath.row][1]
        inversion.arrayMedia = self.presetArray[indexPath.row][2]
        inversion.arrayProvider = self.presetArray[indexPath.row][3]
        inversion.arrayCampaign = self.presetArray[indexPath.row][4]
        self.navigationController?.pushViewController(inversion, animated: true)
    }
    
}

extension PresetVC: UITableViewDelegate {
    
}
