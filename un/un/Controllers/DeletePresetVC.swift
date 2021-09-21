//
//  DeletePresetVC.swift
//  un
//
//  Created by Andres Liu on 1/27/21.
//

import UIKit

class DeletePresetVC: UIViewController {

    @IBOutlet weak var presetNameLabel: UILabel!
    
    @IBOutlet weak var buttonDelete: UIButton!
    
    var presetName = UserDefaults.standard.array(forKey: "presetName") as? [String] ?? [String]()
    
    var presetArray = UserDefaults.standard.array(forKey: "presetArray") as? [[[Int]]] ?? [[[Int]]]()
    var presetSelected = 0
    override func viewDidLoad() {
        super.viewDidLoad()

        presetNameLabel.text = presetName[presetSelected]
    }
    
    @IBAction func deletePreset(_ sender: UIButton) {
        presetName.remove(at: presetSelected)
        UserDefaults.standard.set(presetName, forKey: "presetName")
        presetArray.remove(at: presetSelected)
        UserDefaults.standard.set(presetArray, forKey: "presetArray")
        
        PresetManager.shared.presetVC.presetName = presetName
        PresetManager.shared.presetVC.presetArray = presetArray
        PresetManager.shared.presetVC.presetTableView.reloadData()
        
        let alert = UIAlertController(title: "Éxito", message: "El preset ha sido eliminado", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true)
    }
    @IBAction func cancelDelete(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
