//
//  LoginViewController.swift
//  GoogleMapsTracker
//
//  Created by Оксана Каменчук on 21.02.2023.
//

import UIKit

class LoginViewController: UIViewController {
    
    enum Constants {
        static let login = "admin"
        static let password = "123456"
    }
    
    @IBOutlet weak var login: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var router: LoginRouter!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
            
        self.navigationController?.isNavigationBarHidden = true
    }
    
    @IBAction func enter(_ sender: Any) {
        if let login = login.text,
            let password = password.text {
            let user = User()
            user.login = login
            user.password = password
            let realmService = try! RealmService()
            if realmService.login(user: user){
                router.showMaps()
            } else {
                alertAuth()
            }
        }
    }
    
    
    @IBAction func register(_ sender: Any) {
        
        router.showRegister()
    }
    
    func alertAuth () {
            
        let alertController = UIAlertController(title: "Ошибка входа", message: "Не верный логин или пароль!", preferredStyle: .actionSheet)
        let alertAction = UIAlertAction(title: "Попробовать снова", style: .cancel, handler: nil)
        alertController.addAction(alertAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

final class LoginRouter: BaseRouter {
    
    func showRegister(){
        
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(RegisterViewController.self)
        show(controller, style: .modal(animated: true))
        
    }
    
    func showMaps(){
        
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(MapViewController.self)
        show(controller, style: .push(animated: true))
        
    }
}
