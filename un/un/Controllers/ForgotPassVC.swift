//
//  ForgotPassVC.swift
//  un
//
//  Created by Andres Liu on 1/14/21.
//

import UIKit
import Alamofire
import SwiftyJSON

class ForgotPassVC: UIViewController {

    
    @IBOutlet weak var radioButtonEmail: UIImageView!
    
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var buttonNext: UIButton!
    
    var userEmail = ""
    
    var selectedOption = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        emailLabel.text = userEmail
        buttonNext.isEnabled = false
    }

        
    @IBAction func returnToLogin(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func markEmail(_ sender: UIButton) {
        guard selectedOption == 0 else {
            selectedOption = 0
            radioButtonEmail.image = UIImage(named: "unmark_circle")
            buttonNext.isEnabled = false
            buttonNext.layer.backgroundColor = #colorLiteral(red: 0.6117647059, green: 0.6117647059, blue: 0.6117647059, alpha: 1)
            return
        }
        selectedOption = 1
        radioButtonEmail.image = UIImage(named: "mark_circle")
        buttonNext.isEnabled = true
        buttonNext.layer.backgroundColor = #colorLiteral(red: 0.8528811336, green: 0, blue: 0.05069902539, alpha: 1)
        
    }
    @IBAction func goToForgotPass2(_ sender: UIButton) {
        let forgotPassVC2 = self.storyboard?.instantiateViewController(identifier: "ForgotPassVC2") as! ForgotPassVC2
        forgotPassVC2.email = userEmail
        forgotPassVC2.modeRecup = "M"
        self.navigationController?.pushViewController(forgotPassVC2, animated: true)
    }
}

class ForgotPassVC2: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var helloUserLabel: UILabel!
    @IBOutlet weak var txt1: UITextField!
    @IBOutlet weak var txt2: UITextField!
    @IBOutlet weak var txt3: UITextField!
    @IBOutlet weak var txt4: UITextField!
    @IBOutlet weak var buttonSendCode: UIButton! {
        didSet {
            let attrs = [
                NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
            ]
            let attrString = NSMutableAttributedString.init(string: "Enviar código", attributes: attrs)
            buttonSendCode.setAttributedTitle(attrString, for: .normal)
        }
    }
    @IBOutlet weak var buttonNext: UIButton!
    
    var email = ""
    var modeRecup = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonNext.isEnabled = false
        
        txt1.layer.borderColor = #colorLiteral(red: 0.6117647059, green: 0.6117647059, blue: 0.6117647059, alpha: 1)
        txt2.layer.borderColor = #colorLiteral(red: 0.6117647059, green: 0.6117647059, blue: 0.6117647059, alpha: 1)
        txt3.layer.borderColor = #colorLiteral(red: 0.6117647059, green: 0.6117647059, blue: 0.6117647059, alpha: 1)
        txt4.layer.borderColor = #colorLiteral(red: 0.6117647059, green: 0.6117647059, blue: 0.6117647059, alpha: 1)
        
        txt1.delegate = self
        txt2.delegate = self
        txt3.delegate = self
        txt4.delegate = self
        
        txt1.becomeFirstResponder()
        
        self.hideKeyboardWhenTappedAround()
        
        sendCode()
        
    }
    
    func sendCode() {
        let serverManager = ServerManager()
        let parameters : Parameters  = ["correo": email, "modoRecup": modeRecup]
        serverManager.serverCallWithHeadersRecoveryPass(url: serverManager.recoveryPassAppURL, params: parameters, method: .post, callback: {  (intCheck : Int, jsonData : JSON) -> Void in
            if intCheck == 1 {
                print("Success")
            } else {
                print("Failure")
            }
        })
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if ((textField.text?.count)! < 1) && (string.count > 0) {
            if textField == txt1 {
                txt2.becomeFirstResponder()
            }
            if textField == txt2 {
                txt3.becomeFirstResponder()
            }
            if textField == txt3 {
                txt4.becomeFirstResponder()
            }
            if textField == txt4 {
                buttonNext.isEnabled = true
                buttonNext.layer.backgroundColor = #colorLiteral(red: 0.8528811336, green: 0, blue: 0.05069902539, alpha: 1)
                txt4.resignFirstResponder()
            }
            textField.text = string
            return false
        } else if ((textField.text?.count)! >= 1) && (string.count == 0) {
            if textField == txt2 {
                txt1.becomeFirstResponder()
            }
            if textField == txt3 {
                txt2.becomeFirstResponder()
            }
            if textField == txt4 {
                txt3.becomeFirstResponder()
            }
            if textField == txt1 {
                txt1.resignFirstResponder()
            }
            textField.text = ""
            return false
        } else if ((textField.text?.count)! >= 1) {
            textField.text = string
            return false
        }
        
        return true
    }
    
    @IBAction func returnToForgotPass(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func resendCode(_ sender: UIButton) {
        let serverManager = ServerManager()
        let parameters : Parameters  = ["correo": email, "modoRecup": modeRecup]
        
        let processing = UIAlertController(title: nil, message: "Enviando SMS...", preferredStyle: .alert)

        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating();
        processing.view.addSubview(loadingIndicator)
        present(processing, animated: true, completion: nil)
        
        serverManager.serverCallWithHeadersRecoveryPass(url: serverManager.recoveryPassAppURL, params: parameters, method: .post, callback: {  (intCheck : Int, jsonData : JSON) -> Void in
            if intCheck == 1 {
                self.dismiss(animated: false, completion: {
                    print("Success")
                    self.showAlert(title: "Éxito!", message: "El código ha sido enviado correctamente")
                })
            } else {
                self.dismiss(animated: false, completion: {
                    print("Failure")
                    self.showAlert(title: "Error", message: "Ha ocurrido un error en el envio, intentar nuevamente")
                })
            }
        })
    }
    
    
    @IBAction func goToForgotPass3(_ sender: UIButton) {
        let codigoIngresado = "\(txt1.text!)\(txt2.text!)\(txt3.text!)\(txt4.text!)"
        
        let serverManager = ServerManager()
        let parameters : Parameters  = ["correo": email, "key": codigoIngresado]
        
        let processing = UIAlertController(title: nil, message: "Verificando...", preferredStyle: .alert)

        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating();
        processing.view.addSubview(loadingIndicator)
        present(processing, animated: true, completion: nil)
        
        serverManager.serverCallWithHeadersRecoveryPass(url: serverManager.recoveryKeyAppURL, params: parameters, method: .post, callback: {  (intCheck : Int, jsonData : JSON) -> Void in
            if intCheck == 1 {
                self.dismiss(animated: false, completion: {
                    print("Success")
                    UserDefaults.standard.setValue("Basic \(jsonData["token"].string ?? "")", forKey: "recoveryToken")
                    let forgotPassVC3 = self.storyboard?.instantiateViewController(identifier: "ForgotPassVC3") as! ForgotPassVC3
                    self.navigationController?.pushViewController(forgotPassVC3, animated: true)
                })
            } else {
                self.dismiss(animated: false, completion: {
                    print("Failure")
                    self.showAlert(title: "Error", message: "Código incorrecto")
                })
            }
        })
    }
}

class ForgotPassVC3: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var passTxt: UITextField!
    @IBOutlet weak var confirmPassTxt: UITextField!
    @IBOutlet weak var buttonSave: UIButton!
    
    var passCheck = false
    var confirmPassCheck = false
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonSave.isEnabled = false
        passTxt.delegate = self
        confirmPassTxt.delegate = self
        
        self.hideKeyboardWhenTappedAround()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switchBasedNextTextField(textField)
        return true
    }
    
    func switchBasedNextTextField(_ textField: UITextField) {
        switch textField {
            case passTxt:
                confirmPassTxt.becomeFirstResponder()
            case confirmPassTxt:
                confirmPassTxt.resignFirstResponder()
            default:
                confirmPassTxt.resignFirstResponder()
            }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
         guard let text = textField.text else { return true }
        if textField == passTxt {
            let oldText = text as NSString
            let newString = oldText.replacingCharacters(in: range, with: string) as NSString
            if newString.length > 0 {
                passCheck = true
            } else {
                passCheck = false
            }
        }
        
        if textField == confirmPassTxt {
            let oldText = text as NSString
            let newString = oldText.replacingCharacters(in: range, with: string) as NSString
            if newString.length > 0 {
                confirmPassCheck = true
            } else {
                confirmPassCheck = false
            }
        }
        
        if passCheck && confirmPassCheck {
            buttonSave.isEnabled = true
            buttonSave.layer.backgroundColor = #colorLiteral(red: 0.8528811336, green: 0, blue: 0.05069902539, alpha: 1)
        } else {
            buttonSave.isEnabled = false
            buttonSave.layer.backgroundColor = #colorLiteral(red: 0.6117647059, green: 0.6117647059, blue: 0.6117647059, alpha: 1)
        }
         let newLength = text.count + string.count - range.length
         return newLength <= 20
    }
    
    @IBAction func returnToForgotPass2(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func savePass(_ sender: UIButton) {
        guard passTxt.text != "" || confirmPassTxt.text != "" else {
            showAlert(title: "Error", message: "Llenar campos vacios")
            return
        }
        guard passTxt.text!.count >= 8 && confirmPassTxt.text!.count >= 8 else {
            showAlert(title: "Error", message: "Contraseña debe tener minimo 8 caracteres")
            return
        }
        guard passTxt.text == confirmPassTxt.text else {
            showAlert(title: "Error", message: "Contraseñas no coinciden")
            return
        }
        
        let serverManager = ServerManager()
        let parameters : Parameters  = ["newPassword": confirmPassTxt.text!]
        
        let processing = UIAlertController(title: nil, message: "Procesando...", preferredStyle: .alert)

        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating();
        processing.view.addSubview(loadingIndicator)
        present(processing, animated: true, completion: nil)
        
        serverManager.serverCallWithHeadersRecovery(url: serverManager.changeExternalPassURL, params: parameters, method: .put, callback: {  (intCheck : Int, jsonData : JSON) -> Void in
            if intCheck == 1 {
                self.dismiss(animated: false, completion: {
                    print("Success")
                    let alert = UIAlertController(title: "Éxito!", message: "Su contraseña ha sido cambiada satisfactoriamente", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (_) in
                        self.navigationController?.popToRootViewController(animated: true)
                    }))
                    self.present(alert, animated: true)
                })
            } else {
                self.dismiss(animated: false, completion: {
                    print("Failure")
                    self.showAlert(title: "Error", message: "Ha habido un error, por favor inténtelo denuevo")
                })
            }
        })
    }
}
