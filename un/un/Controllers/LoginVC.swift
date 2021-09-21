//
//  LoginVC.swift
//  un
//
//  Created by Andres Liu on 1/11/21.
//

import UIKit
import SwiftyJSON
import Alamofire
import SwiftJWT

class LoginVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var passTxt: UITextField!
    @IBOutlet weak var forgetPassButton: UIButton! {
        didSet {
            let attrs = [
                NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
            ]
            let attrString = NSMutableAttributedString.init(string: "¿Olvidaste tu contraseña?", attributes: attrs)
            forgetPassButton.setAttributedTitle(attrString, for: .normal)
        }
    }
    @IBOutlet weak var loginButton: UIButton!
    
    var userToken: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emailTxt.delegate = self
        passTxt.delegate = self
        
        hideKeyboardWhenTappedAround()
        
        if UserDefaults.standard.bool(forKey: "isUserLoggedIn") == true {
            getInfoUsuario()
        }
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
            case emailTxt:
                passTxt.becomeFirstResponder()
            case passTxt:
                passTxt.resignFirstResponder()
                loginUser(loginButton)
            default:
                passTxt.resignFirstResponder()
            }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
         guard let text = textField.text else { return true }
         let newLength = text.count + string.count - range.length
         return newLength <= 30
    }
    
    @IBAction func goToForgetPass(_ sender: UIButton) {
        
        guard emailTxt.text != "" else {
            showAlert(title: "Error", message: "Ingresar correo")
            return
        }
        let validEmail = isValidEmail(emailTxt.text!)
        guard validEmail else {
            showAlert(title: "Error", message: "Ingresar correo válido")
            return
        }
        
        let forgotPassVC = storyboard?.instantiateViewController(identifier: "ForgotPassVC") as! ForgotPassVC
        forgotPassVC.userEmail = emailTxt.text!
        self.navigationController?.pushViewController(forgotPassVC, animated: true)
        
    }
    
    @IBAction func loginUser(_ sender: UIButton) {
        guard emailTxt.text != "" else {
            showAlert(title: "Error", message: "Ingresar correo")
            return
        }
        
        let validEmail = isValidEmail(emailTxt.text!)
        guard validEmail else {
            showAlert(title: "Error", message: "Ingresar correo válido")
            return
        }
        
        guard passTxt.text != "" else {
            showAlert(title: "Error", message: "Ingresar contraseña")
            return
        }
        
        var jwtToken: String = ""
        let myHeader = Header()
    
        struct MyUser: Claims {
            let user: String
            let password: String
        }
        let myUser = MyUser(user: emailTxt.text!, password: passTxt.text!)
        var myJWT = JWT(header: myHeader, claims: myUser)
        let urlPath = Bundle.main.url(forResource: "privateKey", withExtension: "key")!

        do {
            let privateKey: Data = try Data(contentsOf: urlPath)
            let jwtSigner = JWTSigner.hs256(key: privateKey)
            let signedJWT = try myJWT.sign(using: jwtSigner)
            jwtToken = signedJWT
        } catch {
            print("Error")
        }
        
        let serverManager = ServerManager()
        let parameters : Parameters  = ["id_token": jwtToken]
        let loggingIn = UIAlertController(title: nil, message: "Iniciando sesión...", preferredStyle: .alert)

        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating();

        loggingIn.view.addSubview(loadingIndicator)
        present(loggingIn, animated: true, completion: nil)
        
        UserDefaults.standard.setValue(2, forKey: "moneda")
        UserDefaults.standard.setValue("123", forKey: "userToken")
        
        serverManager.serverCallWithHeaders(url: serverManager.loginURL, params: parameters, method: .post, callback: {  (intCheck : Int, jsonData : JSON) -> Void in
            
            if intCheck == 1 {
                self.dismiss(animated: false, completion: {
                    print("Success")
                    self.userToken = jwtToken
                    print(jwtToken)
                    UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
                    UserDefaults.standard.setValue("Basic \(jsonData["jwt"])", forKey: "userToken")
                    UserDefaults.standard.setValue(self.passTxt.text!, forKey: "userPass")
                    
                    self.getInfoUsuario()

                })
                
            } else {
                self.dismiss(animated: false, completion: {
                    print("Failure")
                    let alert = UIAlertController(title: "Error", message: "Usuario y/o contraseña incorrecta", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true)
                })
            }
        })
    }
    
    func getInfoUsuario() {
        let serverManager = ServerManager()
        let parameters : Parameters  = ["userToken": UserDefaults.standard.string(forKey: "userToken")!]
        serverManager.serverCallWithHeaders(url: serverManager.myProfileURL, params: parameters, method: .post, callback: {  (intCheck : Int, jsonData : JSON) -> Void in
            if intCheck == 1 {
                print("Success")
                
                UserDefaults.standard.setValue("\(jsonData["firstName"].string ?? "")", forKey: "userFirstName")
                UserDefaults.standard.setValue(jsonData["userType"].string!.uppercased(), forKey: "userType")
                
//                if jsonData["userType"].string!.uppercased() == "HOLDING" || jsonData["userType"].string!.uppercased() == "ADMINISTRADOR" {
//                    //self.performSegue(withIdentifier: "goToBrandList", sender: self)
//                    let brandListVC = self.storyboard?.instantiateViewController(withIdentifier: "brandListVC") as! BrandListVC
//                    self.navigationController?.pushViewController(brandListVC, animated: true)
//                } else {
//                    self.getMarca()
//                }
                let brandListVC = self.storyboard?.instantiateViewController(withIdentifier: "brandListVC") as! BrandListVC
                self.navigationController?.pushViewController(brandListVC, animated: true)
            } else {
                print("Failure")
            }
        })
    }
    
    func getMarca() {
        let serverManager = ServerManager()
        let parameters : Parameters  = [:]
        serverManager.serverCallWithHeadersGET(url: serverManager.marcaURL, params: parameters, method: .get, callback: {  (intCheck : Int, jsonData : JSON) -> Void in
            if intCheck == 1 {
                for marca in jsonData.arrayValue {
                    UserDefaults.standard.setValue(marca["externalcode"].string!, forKey: "idBrand")
                    UserDefaults.standard.setValue(marca["name"].string!, forKey: "brandName")
                    let menu = self.storyboard?.instantiateViewController(withIdentifier: "LeftMenu") as! SideMenuVC
                    let reportListVC = self.storyboard?.instantiateViewController(withIdentifier: "ReportListVC") as! ReportListVC
                    self.navigationController?.pushViewController(menu, animated: false, completion: {
                        self.navigationController?.pushViewController(reportListVC, animated: false)
                    })
                    //self.performSegue(withIdentifier: "fromLoginToListado", sender: self)
                }
            } else {
                print("Failure")
                let alert = UIAlertController(title: "Error", message: "Time Limit Exceeded", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Reload", style: .default, handler: { _ in self.getMarca()
                }))
                alert.addAction(UIAlertAction(title: "Return", style: .default, handler: { _ in self.dismiss(animated: true, completion: nil)
                }))
                self.present(alert, animated: true)
            }
        })
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToBrandList" {
            let presentingVC = segue.source as! LoginVC
            presentingVC.passTxt.text = ""
        }
    }

}
