//
//  RegisterViewController.swift
//  GoogleMapsTracker
//
//  Created by Оксана Каменчук on 21.02.2023.
//

import UIKit

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var login: UITextField!
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextFields()
    }
    
    func setupTextFields() {
        
            password.isSecureTextEntry = true
    }
    
    @IBAction func register(_ sender: Any) {
        
        if let login = login.text,
            let password = password.text,
            login != "",
            password != "" {
            let user = User()
            user.login = login
            user.password = password
            let realmService = try! RealmService()
            let userBase = realmService.register(user: user)
            alertRegister(user: userBase)
        }
    }
    
    func alertRegister(user: User){
            
        let alertController = UIAlertController(title: "Регистрация", message: "Вы успешо зарегистрировались", preferredStyle: .actionSheet)
        let alertActionMap = UIAlertAction(title: "Войти?", style: .default) {_ in
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(alertActionMap)
        self.present(alertController, animated: true, completion: nil)
    }
}
