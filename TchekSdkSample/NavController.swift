//
//  NavController.swift
//  TchekSDKSample
//
//  Created by Silvio Pulitano on 19/11/2021.
//

import UIKit

class NavController: UINavigationController {
	override func viewDidLoad() {
		super.viewDidLoad()
		setNeedsStatusBarAppearanceUpdate()
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		.lightContent
	}
}
