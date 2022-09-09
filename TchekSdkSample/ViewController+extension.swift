//
//  ViewController+extension.swift
//  TchekSDKSample
//
//  Created by Silvio Pulitano on 09/03/2022.
//

import UIKit

extension UIViewController {
	func showAlert(title: String?,
				   msg: String,
				   style: UIAlertController.Style,
				   btnCancel: String?,
				   btnOk: String?, btnOkStyle: UIAlertAction.Style,
				   onBtnOk: (() -> Void)?) {
		let alertController = UIAlertController(title: title, message: msg, preferredStyle: style)
		if let btnCancel = btnCancel {
			alertController.addAction(UIAlertAction(title: btnCancel, style: .cancel, handler: nil))
		}
		if let btnOk = btnOk {
			alertController.addAction(UIAlertAction(title: btnOk, style: btnOkStyle) { action in
				onBtnOk?()
			})
		}
		if let popoverController = alertController.popoverPresentationController { // iPad
			popoverController.sourceView = self.view //to set the source of your alert
			popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.maxY, width: 0, height: 0) // you can set this as per your requirement.
			popoverController.permittedArrowDirections = [] //to hide the arrow of any particular direction
		}
		present(alertController, animated: true, completion: nil)
	}
}
