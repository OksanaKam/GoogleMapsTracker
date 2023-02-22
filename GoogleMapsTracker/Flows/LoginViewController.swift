//
//  LoginViewController.swift
//  GoogleMapsTracker
//
//  Created by Оксана Каменчук on 21.02.2023.
//

import UIKit
import RxSwift
import RxCocoa

class LoginViewController: UIViewController {
    
    enum Constants {
        static let login = "admin"
        static let password = "123456"
    }
    
    @IBOutlet weak var login: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet var loginButton: UIButton!
    
    @IBOutlet weak var router: LoginRouter!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextFields()
        setupObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func setupObserver(){
        Observable.combineLatest(login.rx.text.asObservable().unwrap(),
                                 password.rx.text.asObservable().unwrap())
            .map { (userName, password) in
                userName.count >= AuthConstatns.minLoginLenght && password.count >= AuthConstatns.minPasswordLength
            }
            .subscribe(onNext: { [weak self] isValid in
                self?.activeLoginButton(isValid: isValid)
            })
            .disposed(by:disposeBag)
    }
        
    func activeLoginButton(isValid: Bool){
        loginButton.isEnabled = isValid
        loginButton.backgroundColor = isValid ? UIColor.systemBlue : UIColor.systemGray
    }
    
    func setupTextFields() {
        login.autocorrectionType = .no
        password.isSecureTextEntry = true
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
