//
//  AppDelegate.swift
//  TchekSDKSample
//
//  Created by Silvio Pulitano on 22/09/2021.
//

import UIKit
import TchekSDK

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

	public static var CUSTOM_UI: Bool {
		get {
			return UserDefaults.standard.object(forKey: "CUSTOM_UI") as? Bool ?? false
		}
		set {
			UserDefaults.standard.set(newValue, forKey: "CUSTOM_UI")
		}
	}

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		
		let builder = TchekBuilder(userId: "your_user_id", ui: { builder in
			if AppDelegate.CUSTOM_UI {
				builder.alertButtonText = .orange
				builder.accentColor = .orange
			}
		})
		TchekSdk.configure(key: "6d52f1de4ffda05cb91c7468e5d99714f5bf3b267b2ae9cca8101d7897d2", builder: builder)
		
		return true
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

