//
//  ChangePassVC.swift
//  un
//
//  Created by Andres Liu on 1/14/21.
//

import UIKit
import Alamofire
import SwiftyJSON

class ChangePassVC: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var oldPassTxt: UITextField!
    @IBOutlet weak var newPassTxt: UITextField!
    @IBOutlet weak var confirmPassTxt: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        oldPassTxt.delegate = self
        newPassTxt.delegate = self
        confirmPassTxt.delegate = self
        
        self.hideKeyboardWhenTappedAround()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switchBasedNextTextField(textField)
        return true
    }
    
    func switchBasedNextTextField(_ textField: UITextField) {
        switch textField {
            case oldPassTxt:
                newPassTxt.becomeFirstResponder()
            case newPassTxt:
                confirmPassTxt.becomeFirstResponder()
            case confirmPassTxt:
                confirmPassTxt.resignFirstResponder()
            default:
                confirmPassTxt.resignFirstResponder()
            }
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
         guard let text = textField.text else { return true }
         let newLength = text.count + string.count - range.length
         return newLength <= 20
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }

    @IBAction func returnToMenu(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func returnToReporte(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func savePass(_ sender: UIButton) {
        guard oldPassTxt.text != "" else {
            showAlert(title: "Error", message: "Ingresar contraseña actual")
            return
        }
        guard newPassTxt.text != "" || confirmPassTxt.text != "" else {
            showAlert(title: "Error", message: "Ingresar nueva contraseña")
            return
        }
        guard newPassTxt.text!.count >= 8 && confirmPassTxt.text!.count >= 8 else {
            showAlert(title: "Error", message: "Nueva contraseña debe tener minimo 8 caracteres")
            return
        }
        guard newPassTxt.text == confirmPassTxt.text else {
            showAlert(title: "Error", message: "Contraseñas no coinciden")
            return
        }
        guard oldPassTxt.text == UserDefaults.standard.string(forKey: "userPass") else {
            showAlert(title: "Error", message: "Contraseña incorrecta")
            return
        }
        guard oldPassTxt.text != newPassTxt.text else {
            showAlert(title: "Error", message: "Elegir una nueva contraseña")
            return
        }
        changePassword()
    }
    
    func changePassword() {
        let serverManager = ServerManager()
        let parameters : Parameters  = ["oldPass": oldPassTxt.text!, "newPassword": newPassTxt.text!]
        
        let processing = UIAlertController(title: nil, message: "Procesando...", preferredStyle: .alert)

        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating();
        processing.view.addSubview(loadingIndicator)
        present(processing, animated: true, completion: nil)
        
        serverManager.serverCallWithHeaders(url: serverManager.changePassURL, params: parameters, method: .put, callback: {  (intCheck : Int, jsonData : JSON) -> Void in
            if intCheck == 1 {
                self.dismiss(animated: false, completion: {
                    print("Success")
                    UserDefaults.standard.setValue(self.newPassTxt.text!, forKey: "userPass")
                    self.showAlert(title: "Éxito!", message: "Su contraseña ha sido cambiada satisfactoriamente")
                    self.oldPassTxt.text = ""
                    self.newPassTxt.text = ""
                    self.confirmPassTxt.text = ""
                })
            } else {
                self.dismiss(animated: false, completion: {
                    print("Failure")
                    self.showAlert(title: "Error", message: "Contraseña incorrecta")
                })
            }
        })
    }
}
