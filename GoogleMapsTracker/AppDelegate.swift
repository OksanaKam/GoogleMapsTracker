//
//  AppDelegate.swift
//  GoogleMapsTracker
//
//  Created by Оксана Каменчук on 14.02.2023.
//

import UIKit
import GoogleMaps
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        GMSServices.provideAPIKey("key")
        
        let controller: UIViewController
        if UserDefaults.standard.bool(forKey: "isLogin") {
        controller = UIStoryboard(name: "Main", bundle: nil) .instantiateViewController(MapViewController.self)
        } else {
        controller = UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(LoginViewController.self)
        }
        window = UIWindow()
        window?.rootViewController = UINavigationController(rootViewController: controller)
        window?.makeKeyAndVisible()
        
        let center = UNUserNotificationCenter.current()
        registerPermission(center: center)
        
        return true
    }
    
    private func registerPermission(center: UNUserNotificationCenter) {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
            guard let self = self else { return }
            guard granted else {
                print("Разрешение не получено")
                return
                
            }
            let content = self.makeNotificationContent()
            let trigger = self.makeIntervalNotificatioTrigger()
            
            self.sendNotificatioRequest(content: content, trigger: trigger)
        }
    }
    
    private func makeNotificationContent() -> UNNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "Пора вставать"
        content.subtitle = "7 утра"
        content.body = "Пора вершить великие дела"
        content.badge = 4
        return content
        
    }
    
    func makeIntervalNotificatioTrigger() -> UNNotificationTrigger {
        return UNTimeIntervalNotificationTrigger(
            timeInterval: 30,
            repeats: false
        )
    }
    
    private func sendNotificatioRequest( content: UNNotificationContent, trigger: UNNotificationTrigger) {
        
        let request = UNNotificationRequest( identifier: "alaram",
                                             content: content,
                                             trigger: trigger
        )
        let center = UNUserNotificationCenter.current()
        center.add(request) { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

