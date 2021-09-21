//
//  SavePresetVC.swift
//  un
//
//  Created by Andres Liu on 1/27/21.
//

import UIKit

class SavePresetVC: UIViewController {

    
    @IBOutlet weak var presetNameTxt: UITextField!
    
    @IBOutlet weak var buttonSave: UIButton!
    
    var preset = [[Int]]()
    override func viewDidLoad() {
        super.viewDidLoad()

        presetNameTxt.layer.borderColor = #colorLiteral(red: 0.2392156863, green: 0.2352941176, blue: 0.2392156863, alpha: 1)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
         guard let text = textField.text else { return true }
         let newLength = text.count + string.count - range.length
         return newLength <= 20
    }
    
    @IBAction func cancelSave(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func savePreset(_ sender: UIButton) {
        
        guard presetNameTxt.text != "" else {
            showAlert(title: "Error", message: "Escribe un nombre")
            return
        }
        
        var presetName = UserDefaults.standard.array(forKey: "presetName") as? [String] ?? [String]()
        presetName.append(presetNameTxt.text!)
        UserDefaults.standard.set(presetName, forKey: "presetName")
        
        var presetArray = UserDefaults.standard.array(forKey: "presetArray") as? [[[Int]]] ?? [[[Int]]]()
        presetArray.append(preset)
        UserDefaults.standard.set(presetArray, forKey: "presetArray")
        
        let alert = UIAlertController(title: "Éxito", message: "El preset ha sido creado", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true)
    }
    
}
