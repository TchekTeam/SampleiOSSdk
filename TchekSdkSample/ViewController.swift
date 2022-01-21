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
		
		print("\(self): viewDidLoad: tchekIdList: \(tchekIdList ?? [])")
		
		tableView.dataSource = self
		tableView.delegate = self
		
		let btnNavBar = UIBarButtonItem(title: "Custom UI: \(AppDelegate.CUSTOM_UI)", style: .plain, target: self, action: #selector(actionCustomUI))
		btnNavBar.tintColor = .white
		navigationItem.setRightBarButton(btnNavBar, animated: true)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		darkNavBarWithLogo()
	}
	
	@objc private func actionCustomUI() {
		AppDelegate.CUSTOM_UI = !AppDelegate.CUSTOM_UI
		showAlert(title: "Change custom UI",
				  msg: "Please kill app and restart",
				  style: .alert,
				  btnCancel: nil,
				  btnOk: "OK",
				  btnOkStyle: .default,
				  onBtnOk: nil)
	}
	
	private func darkNavBarWithLogo() {
		if #available(iOS 15.0, *) {
			let navBarAppearance = UINavigationBarAppearance()
			navBarAppearance.backgroundColor = UIColor(named: "AccentColor") ?? .darkGray
			navBarAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
			navigationController?.navigationBar.tintColor = .white // back button color
			// removeShadow
			navBarAppearance.shadowImage = UIImage()
			navBarAppearance.shadowColor = .clear
			// apply Appearance
			navigationController?.navigationBar.standardAppearance = navBarAppearance
			navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
		} else {
			navigationController?.setNavigationBarHidden(false, animated: true)
			navigationController?.navigationBar.barTintColor = UIColor(named: "AccentColor") ?? .darkGray
			navigationController?.navigationBar.barStyle = .black
			navigationController?.navigationBar.tintColor = .white
			navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
			navigationController?.navigationBar.isTranslucent = false
			// removeShadow
			navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
			navigationController?.navigationBar.shadowImage = UIImage()
		}
		if let img: UIImage = UIImage(named: "logo_light") {
			let imageView = UIImageView(image: img)
			imageView.contentMode = .scaleAspectFit
			navigationItem.titleView = imageView
		}
	}
	
	private func showAlert(title: String?, msg: String, style: UIAlertController.Style,
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
	
	@IBAction func actionShootInspect(_ sender: Any) {
		let builder: TchekShootInspectBuilder
		if AppDelegate.CUSTOM_UI {
			builder = TchekShootInspectBuilder(retryCount: 3, delegate: self) { builder in
				builder.thumbBg = .brown
				builder.thumbBorder = .blue
				builder.thumbBorderBadImage = .orange
				builder.thumbBorderGoodImage = .green
				builder.thumbDot = .cyan
				builder.thumbBorderThickness = 0
				builder.thumbCorner = 0
				
				builder.btnTuto = .yellow
				builder.btnTutoText = .cyan
				builder.tutoPageIndicatorDot = .darkGray
				builder.tutoPageIndicatorDotSelected = .blue
				
				builder.carOverlayGuide = .orange
				
				builder.btnRetake = .yellow
				builder.btnRetakeText = .cyan
				
				builder.previewBg = .orange
				
				builder.btnEndNext = .yellow
				builder.btnEndNextText = .cyan
			}
		} else {
			builder = TchekShootInspectBuilder(retryCount: 3, delegate: self)
		}
		let viewController: UIViewController
		if let tchekIndex = tchekIndexSelected,
		   let tchekId = tchekIdList?[tchekIndex] {
			builder.endBg = .black
			builder.endNavBarBg = .purple
			builder.endNavBarText = .red
			viewController = TchekSdk.shootInspectEnd(tchekId: tchekId, builder: builder)
		} else {
			viewController = TchekSdk.shootInspect(builder: builder)
		}
		navigationController?.pushViewController(viewController, animated: true)
	}
	
	@IBAction func actionFastTrack(_ sender: Any) {
		if let tchekIndex = tchekIndexSelected,
		   let tchekId = tchekIdList?[tchekIndex] {
			
			let builder: TchekFastTrackBuilder
			if AppDelegate.CUSTOM_UI {
				builder = TchekFastTrackBuilder(tchekId: tchekId, delegate: self) { builder in
					builder.navBarBg = .purple
					builder.navBarText = .red
					builder.fastTrackBg = .lightGray
					builder.fastTrackText = .purple
					builder.fastTrackPhotoAngle = .red
					builder.fastTrackPhotoAngleText = .orange
					builder.cardBg = .purple
					
					builder.damagesListBg = .purple
					builder.damagesListText = .red
					builder.damageCellText = .white
					builder.damageCellBorder = .red
					
					builder.vehiclePatternStroke = .white
					builder.vehiclePatternDamageFill = .orange
					builder.vehiclePatternDamageStoke = .red
					
					builder.btnAddExtraDamage = .red
					builder.btnAddExtraDamageText = .orange
					builder.btnCreateReport = .yellow
					builder.btnCreateReportText = .cyan
					
					builder.btnValidateExtraDamage = .yellow
					builder.btnValidateExtraDamageText = .cyan
					builder.btnDeleteExtraDamage = .red
					builder.btnDeleteExtraDamageText = .white
					builder.btnEditDamage = .purple
					builder.btnEditDamageText = .white
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
					builder.bg = .purple
					builder.navBarBg = .purple
					builder.navBarText = .white
					builder.reportText = .lightGray
					
					builder.btnPrev = .lightGray
					builder.btnPrevText = .darkGray
					builder.btnNext = .black
					builder.btnNextText = .white
					
					builder.pagingBg = .purple
					builder.pagingText = .lightText
					builder.pagingTextSelected = .white
					builder.pagingIndicator = .white
					
					builder.textFieldPlaceholderText = .black
					builder.textFieldUnderline = .lightGray
					builder.textFieldUnderlineSelected = .black
					builder.textFieldPlaceholderText = .lightGray
					builder.textFieldPlaceholderTextSelected = .black
					builder.textFieldText = .black
					
					builder.btnValidateSignature = .yellow
					builder.btnValidateSignatureText = .cyan
					
					builder.damageCellText = .white
					builder.damageCellBorder = .red
					builder.vehiclePatternStroke = .white
					builder.vehiclePatternDamageFill = .orange
					
					builder.repairCostCellCostBg = .yellow
					builder.repairCostCellCostText = .cyan
					builder.repairCostCellText = .red
					builder.repairCostCellCircleDamageCountBg = .cyan
					builder.repairCostCellCircleDamageCountText = .white
					builder.repairCostBtnCostSettingsText = .white
					builder.repairCostBtnCostSettings = .red
					builder.repairCostSettingsText = . red
					builder.btnValidateRepairCostEdit = .blue
					builder.btnValidateRepairCostEditText = .orange
					
					builder.vehiclePatternStroke = .blue
					builder.vehiclePatternDamageFill = .orange
					builder.vehiclePatternDamageStoke = .red
					
					builder.extraDamageBg = .purple
					builder.btnValidateExtraDamage = .yellow
					builder.btnValidateExtraDamageText = .cyan
					builder.btnDeleteExtraDamage = .red
					builder.btnDeleteExtraDamageText = .white
					builder.btnEditDamage = .purple
					builder.btnEditDamageText = .white
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
	func onDetectionEnd(tchekScan: TchekScan) {
		var array: [String] = []
		if let tchekIdList = tchekIdList {
			array.append(contentsOf: tchekIdList)
		}
		array.append(tchekScan.id)
		tchekIdList = array
		tableView.reloadData()
		print("\(self): onDetectionEnd: tchekIdList: \(tchekIdList ?? [])")
	}
}

// MARK: Delegate TchekFastTrackDelegate
extension ViewController: TchekFastTrackDelegate {
	func onFastTrackEnd(tchekScan: TchekScan) {
		print("\(self): onFastTrackEnd: tchekScan: \(tchekScan.id)")
	}
}

// MARK: Delegate TchekReportDelegate
extension ViewController: TchekReportDelegate {
	func onReportUpdate(tchekScan: TchekScan) {
		print("\(self): onReportUpdate: tchekScan: \(tchekScan.id)")
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
	
	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return true
	}
		
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		guard editingStyle == .delete else {return}
		if let tchekId = tchekIdList?[indexPath.row] {
			showAlert(title: nil,
					  msg: "Delete Tchek",
					  style: .actionSheet,
					  btnCancel: "Cancel",
					  btnOk: "Delete",
					  btnOkStyle: .destructive) {
				TchekSdk.deleteTchek(tchekId: tchekId) {
					self.showAlert(title: nil,
								   msg: "Delete Tchek Failed",
								   style: .alert,
								   btnCancel: nil,
								   btnOk: "OK",
								   btnOkStyle: .default,
								   onBtnOk: nil)
				} onSuccess: {
					self.tableView.beginUpdates()
					self.tchekIdList?.remove(at: indexPath.row)
					self.tableView.deleteRows(at: [indexPath], with: .automatic)
					self.tableView.endUpdates()
				}
			}
		}
	}
	
	// UITableViewDelegate
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tchekIdList?.count ?? 0
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if indexPath.row == tchekIndexSelected {
			tchekIndexSelected = nil
			tableView.deselectRow(at: indexPath, animated: true)
		} else {
			tchekIndexSelected = indexPath.row
		}
	}
}
