//
//  SceneDelegate.swift
//  RoadXpert
//  Purpose: Creates scenes to navigate screens for iOS13+.
//  Created by Chelsey Bergmann on 10/12/20.
//

import UIKit

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

var window: UIWindow?
    
    // Set Start.swift as the root controller.
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

