//
//  ViewController.swift
//  TchekSdkSample
//
//  Created by Silvio Pulitano on 16/09/2021.
//

import UIKit
import TchekSDK

class ViewController: UIViewController {
	
	private let TCHEK_ID_LIST: String = "TCHEK_ID_LIST"
	
	private var tchekIdList: [String]? {
		get {
			return UserDefaults.standard.object(forKey: TCHEK_ID_LIST) as? [String]
		}
		set {
			UserDefaults.standard.set(newValue, forKey: TCHEK_ID_LIST)
		}
	}
	
	@IBOutlet weak var tableView: UITableView!
	
	private var tchekIndexSelected: Int? = nil
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		darkNavBarWithLogo()
		
		print("\(self): viewDidLoad: tchekIdList: \(tchekIdList ?? [])")
		
		tableView.dataSource = self
		tableView.delegate = self
		
		let btnNavBar = UIBarButtonItem(title: "Custom UI: \(AppDelegate.CUSTOM_UI)", style: .plain, target: self, action: #selector(actionCustomUI))
		btnNavBar.tintColor = .white
		navigationItem.setRightBarButton(btnNavBar, animated: true)
	}
	
	@objc private func actionCustomUI() {
		AppDelegate.CUSTOM_UI = !AppDelegate.CUSTOM_UI
		let alertController = UIAlertController(title: "Change custom UI", message: "Please kill app and restart", preferredStyle: .alert)
		alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
		if let popoverController = alertController.popoverPresentationController { // iPad
			popoverController.sourceView = self.view //to set the source of your alert
			popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.maxY, width: 0, height: 0) // you can set this as per your requirement.
			popoverController.permittedArrowDirections = [] //to hide the arrow of any particular direction
		}
		present(alertController, animated: true, completion: nil)
	}
	
	private func darkNavBarWithLogo() {
		navigationController?.setNavigationBarHidden(false, animated: true)
		navigationController?.navigationBar.barTintColor = UIColor(named: "AccentColor") ?? .darkGray
		navigationController?.navigationBar.barStyle = .black
		navigationController?.navigationBar.isTranslucent = false
		if let img: UIImage = UIImage(named: "logo_light") {
			let imageView = UIImageView(image: img)
			imageView.contentMode = .scaleAspectFit
			navigationItem.titleView = imageView
		}
	}
	
	@IBAction func actionShootInspect(_ sender: Any) {
		let builder: TchekShootInspectBuilder
		if AppDelegate.CUSTOM_UI {
			builder = TchekShootInspectBuilder(delegate: self) { builder in
				builder.thumbBg = .brown
				builder.thumbBorder = .blue
				builder.thumbBorderBadImage = .orange
				builder.thumbBorderGoodImage = .green
				builder.thumbDot = .cyan
				builder.thumbBorderThickness = 0
				builder.thumbCorner = 0
				
				builder.btnTuto = .yellow
				builder.btnTutoText = .cyan
				
				builder.btnRetake = .yellow
				builder.btnRetakeText = .cyan
				
				builder.previewBg = .orange
				
				builder.btnEndNext = .yellow
				builder.btnEndNextText = .cyan
			}
		} else {
			builder = TchekShootInspectBuilder(delegate: self)
		}
		let viewController = TchekSdk.shootInspect(builder: builder)
		navigationController?.pushViewController(viewController, animated: true)
	}
	
	@IBAction func actionFastTrack(_ sender: Any) {
		if let tchekIndex = tchekIndexSelected,
		   let tchekId = tchekIdList?[tchekIndex] {
			
			let builder: TchekFastTrackBuilder
			if AppDelegate.CUSTOM_UI {
				builder = TchekFastTrackBuilder(tchekId: tchekId, delegate: self) { builder in
					builder.btnAddExtraDamage = .red
					builder.btnAddExtraDamageText = .orange
					builder.btnCreateReport = .yellow
					builder.btnCreateReportText = .cyan
				}
			} else {
				builder = TchekFastTrackBuilder(tchekId: tchekId, delegate: self)
			}
			
			let viewController = TchekSdk.fastTrack(builder: builder)
			self.present(viewController, animated: true, completion: nil)
		}
	}
	
	@IBAction func actionReport(_ sender: Any) {
		if let tchekIndex = tchekIndexSelected,
		   let tchekId = tchekIdList?[tchekIndex] {
			
			let builder: TchekReportBuilder
			if AppDelegate.CUSTOM_UI {
				builder = TchekReportBuilder(tchekId: tchekId, delegate: self) { builder in
					builder.btnReportPrevColor = .lightGray
					builder.btnReportPrevTextColor = .darkGray
					builder.btnReportNextColor = .black
					builder.btnReportNextTextColor = .white
					builder.reportPagingBg = .orange
					builder.reportPagingText = .lightText
					builder.reportPagingTextSelected = .white
					builder.reportPagingIndicator = .white
				}
			} else {
				builder = TchekReportBuilder(tchekId: tchekId, delegate: self)
			}
			
			let viewController = TchekSdk.report(builder: builder)
			navigationController?.pushViewController(viewController, animated: true)
		}
	}
}

// MARK: Delegate TchekShootInspectDelegate
extension ViewController: TchekShootInspectDelegate {
	func onDetectionEnd(tchekId: String) {
		var array: [String] = []
		if let tchekIdList = tchekIdList {
			array.append(contentsOf: tchekIdList)
		}
		array.append(tchekId)
		tchekIdList = array
		
		print("\(self): onDetectionEnd: tchekIdList: \(tchekIdList ?? [])")
	}
}

// MARK: Delegate TchekFastTrackBuilderDelegate
extension ViewController: TchekFastTrackBuilderDelegate {
	func onFastTrackEnd(tchek: Tchek) {
		print("\(self): onFastTrackEnd: tchek: \(tchek.id)")
	}
}

// MARK: Delegate TchekReportBuilderDelegate
extension ViewController: TchekReportBuilderDelegate {
	func onReportUpdate(tchek: Tchek) {
		print("\(self): onReportUpdate: tchek: \(tchek.id)")
	}
}

// MARK: Delegate UITableView
extension ViewController: UITableViewDataSource, UITableViewDelegate {
	// UITableViewDataSource
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCell.IDENTIFIER, for: indexPath) as? TableViewCell,
		   let tchekId = tchekIdList?[indexPath.row] {
			cell.data(tchekId: tchekId)
			return cell
		}
		return UITableViewCell()
	}
	
	// UITableViewDelegate
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tchekIdList?.count ?? 0
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tchekIndexSelected = indexPath.row
	}
}
