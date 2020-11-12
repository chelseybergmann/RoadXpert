//
//  AppDelegate.swift
//  RoadXpert
//
//  Created by Chelsey Bergmann on 10/12/20.
//
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate { 

    var window: UIWindow?
    
    var navigationController: UINavigationController?
    
    // Set Start.swift as root view controller when app launches.
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        if #available(iOS 13.0, *) {@available(iOS 13.0, *)  // Scenes available is iOS 13.
            class SceneDelegate: UIResponder, UIWindowSceneDelegate {
            var window: UIWindow?
                   
            func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
                guard let _ = (scene as? UIWindowScene) else { return }
                        if let windowScene = scene as? UIWindowScene {
                            self.window = UIWindow(windowScene: windowScene)
                            let mainNavigationController = UINavigationController(rootViewController: Start())
                            self.window!.rootViewController = mainNavigationController
                            self.window!.makeKeyAndVisible()
                        }
                }
            }
                // < iOS 13.0
                }  else {
                    self.window = UIWindow(frame: UIScreen.main.bounds)
                    let mainViewController = Start()
                    let mainNavigationController = UINavigationController(rootViewController: mainViewController)
                    self.window!.rootViewController = mainNavigationController
                    self.window!.makeKeyAndVisible()
                
        }
                return true
    }
}


