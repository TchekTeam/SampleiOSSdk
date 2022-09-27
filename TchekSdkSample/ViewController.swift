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
	
	private var dynamicTchekScans: [SampleTchekScan] = []
	
	private var currentScans: [SampleTchekScan] = []
	
	private let preferences = Preferences()
	
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var stackViewButton: UIStackView!
	@IBOutlet weak var switchSSO: UISwitch!
	@IBOutlet weak var txtFieldSSO: UITextField!
	@IBOutlet weak var txtFieldTchekId: UITextField!
	
	private var tchekSocketManager: TchekSocketManager?
	private var newTchekEmitter: NewTchekEmitter?
	private var detectionFinishedEmitter: DetectionFinishedEmitter?
	private var createReportEmitter: CreateReportEmitter?
	private var deleteTchekEmitter: DeleteTchekEmitter?
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView.dataSource = self
		tableView.delegate = self
		
		let btnNavBar = UIBarButtonItem(title: "Custom UI: \(AppDelegate.CUSTOM_UI)", style: .plain, target: self, action: #selector(actionCustomUI))
		btnNavBar.tintColor = .white
		navigationItem.setRightBarButton(btnNavBar, animated: true)
		
		let savedScans = preferences.previousScans
		
		dynamicTchekScans.append(contentsOf: savedScans)
		
		currentScans.append(contentsOf: dynamicTchekScans)
		currentScans.sort { lhs, rhs in
			return lhs.timestamp < rhs.timestamp
		}
		
		updateAdapterAndPreferences()
		tableView.reloadData()
		
		configure(show: false)
		
		txtFieldSSO.delegate = self
		txtFieldTchekId.delegate = self
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		darkNavBarWithLogo()
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		tchekSocketManager?.destroy()
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .darkContent
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
	
	private func updateAdapterAndPreferences() {
		//Fire and forget
		preferences.saveSampleScans(dynamicTchekScans)
		
		currentScans.removeAll()
		currentScans.append(contentsOf: dynamicTchekScans)
	}
	
	private func configure(show: Bool) {
		if show {
			stackViewButton.isHidden = false
			tableView.isHidden = false
		} else {
			stackViewButton.isHidden = true
			tableView.isHidden = true
		}
	}
	
	@IBAction func actionConfigure(_ sender: Any) {
		configure(show: false)
		let builder = TchekBuilder(userId: "your_user_id", ui: { builder in
			if AppDelegate.CUSTOM_UI {
				builder.alertButtonText = .orange
				builder.accentColor = .orange
			}
		})
		if switchSSO.isOn {
			TchekSdk.configure(keySSO: txtFieldSSO.text ?? "",
							   builder: builder) { apiError in
				print("\(self): configure-onFailure-apiError: \(apiError))")
				self.showAlert(title: nil, msg: "\(apiError)", style: .alert, btnCancel: nil, btnOk: "OK", btnOkStyle: .default, onBtnOk: nil)
			} onSuccess: { tchekSSO in
				print("\(self): configure-onSuccess-tchekSSO: \(String(describing: tchekSSO)))")
				self.configure(show: true)
				self.socketSubscriber()
			}
		} else {
			TchekSdk.configure(key: "6d52f1de4ffda05cb91c7468e5d99714f5bf3b267b2ae9cca8101d7897d2",
							   builder: builder) {
				self.configure(show: true)
				self.socketSubscriber()
			}
		}
	}
	
	@IBAction func actionLoadAll(_ sender: Any) {
		TchekSdk.loadAllTchek(type: .mobile, deviceId: nil, search: nil, limit: 50, page: 0) { error in
			self.showAlert(title: "Error", msg: error.errorMsg, style: .alert, btnCancel: nil, btnOk: "OK", btnOkStyle: .default, onBtnOk: nil)
		} onSuccess: { tcheks in
			tcheks.forEach { tchek in
				print("\(self)-tchek.id: \(tchek.id), tchek.status: \(tchek.status), tchek.scanSync: \(tchek.scanSync), tchek.thumbnailUrl: \(String(describing: tchek.thumbnailUrl))")
			}
		}
	}
	
	@IBAction func actionGetReportUrl(_ sender: Any) {
		let tchekId = txtFieldTchekId.text ?? ""
		TchekSdk.getReportUrl(tchekId: tchekId,
							  validity: 1,
							  cost: false) { error in
			self.showAlert(title: nil,
						   msg: error.errorMsg,
						   style: .alert,
						   btnCancel: nil,
						   btnOk: "OK",
						   btnOkStyle: .default,
						   onBtnOk: nil)
		} onSuccess: { url in
			self.showAlert(title: nil,
						   msg: url,
						   style: .alert,
						   btnCancel: "OK",
						   btnOk: "Open in Browser",
						   btnOkStyle: .default) {
				guard let url = URL(string: url) else {
					return
				}
				UIApplication.shared.open(url, options: [:], completionHandler: nil)
			}
		}
	}
	
	private func socketSubscriber() {
		tchekSocketManager = TchekSdk.socketManager(type: TchekScanType.mobile, device: nil)
		
		newTchekEmitter = NewTchekEmitter { tchek in
			print("\(self)-newTchekEmitter-NewTchek-tchek.id: \(tchek.id), tchek.vehicle?.immat: \(String(describing: tchek.vehicle?.immat)), tchek.detectionFinished: \(tchek.detectionFinished), tchek.detectionInProgress: \(tchek.detectionInProgress)")
			self.addNewScan(tchek.id)
		}
		
		detectionFinishedEmitter = DetectionFinishedEmitter { tchek in
			print("\(self)-detectionFinishedEmitter-detectionFinished-tchek.id: \(tchek.id), tchek.vehicle?.immat: \(String(describing: tchek.vehicle?.immat)), tchek.detectionFinished: \(tchek.detectionFinished), tchek.detectionInProgress: \(tchek.detectionInProgress)")
		}

		createReportEmitter = CreateReportEmitter { tchek in
			print("\(self)-createReportEmitter-createReport-tchek.id: \(tchek.id), tchek.vehicle?.immat: \(String(describing: tchek.vehicle?.immat)), tchek.detectionFinished: \(tchek.detectionFinished), tchek.detectionInProgress: \(tchek.detectionInProgress)")
		}

		deleteTchekEmitter = DeleteTchekEmitter { tchekId in
			print("\(self)-deleteTchekEmitter-deleteTchek-tchekId: \(tchekId)")
		}
				
		tchekSocketManager!.subscribe(newTchekEmitter!)
		tchekSocketManager!.subscribe(detectionFinishedEmitter!)
		tchekSocketManager!.subscribe(createReportEmitter!)
		tchekSocketManager!.subscribe(deleteTchekEmitter!)
	}
	
	@IBAction func actionShootInspect(_ sender: Any) {
		shootInspect()
	}
	
	private func shootInspect(tchekScanId: String? = nil) {
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
			builder = TchekShootInspectBuilder(delegate: self)
		}
		let viewController: UIViewController
		if let tchekScanId = tchekScanId {
			builder.endBg = .black
			builder.endNavBarBg = .purple
			builder.endNavBarText = .red
			viewController = TchekSdk.shootInspectEnd(tchekId: tchekScanId, builder: builder)
		} else {
			viewController = TchekSdk.shootInspect(builder: builder)
		}
		navigationController?.pushViewController(viewController, animated: true)
	}
	
	private func fastTrack(tchekScanId: String) {
		let builder: TchekFastTrackBuilder
		if AppDelegate.CUSTOM_UI {
			builder = TchekFastTrackBuilder(tchekId: tchekScanId, delegate: self) { builder in
				builder.navBarBg = .purple
				builder.navBarText = .red
				builder.fastTrackBg = .lightGray
				builder.fastTrackText = .purple
				builder.damageLocation = .red
				builder.damageLocationText = .orange
				builder.cardBg = .purple
				builder.pageIndicatorDot = .systemPink
				builder.pageIndicatorDotSelected = .blue
				
				builder.damageConfidence0 = .red
				builder.damageConfidenceText0 = .white
				builder.damageConfidence1 = .orange
				builder.damageConfidenceText1 = .white
				builder.damageConfidence2 = .green
				builder.damageConfidenceText2 = .white
				builder.damageType = .orange
				builder.damageTypeText = .white
				builder.damageLocation = .blue
				builder.damageLocationText = .white
				builder.damageDate = .white
				builder.damageDateText = .darkGray
				builder.damageNew = .green
				builder.damageNewText = .white
				builder.damageOld = .red
				builder.damageOldText = .white
				
				builder.damageCellBorder = .red
				builder.damageCellText = .white
				builder.damagesListBg = .purple
				builder.damagesListText = .red
				
				builder.vehiclePatternStroke = .white
				builder.vehiclePatternDamageFill = .orange
				builder.vehiclePatternOldDamageFill = .yellow
				builder.vehiclePatternDamageStroke = .red
				
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
			builder = TchekFastTrackBuilder(tchekId: tchekScanId, delegate: self)
		}
		
		let viewController = TchekSdk.fastTrack(builder: builder)
		self.present(viewController, animated: true, completion: nil)
	}
	
	private func report(tchekScanId: String) {
		let builder: TchekReportBuilder
		if AppDelegate.CUSTOM_UI {
			builder = TchekReportBuilder(tchekId: tchekScanId, delegate: self) { builder in
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
				builder.vehiclePatternOldDamageFill = .yellow
				builder.vehiclePatternDamageStroke = .red
				
				builder.buyBackSectionCellBg = .darkGray
				builder.buyBackSectionCellText = .red
				builder.buyBackCellBg = .yellow
				builder.buyBackCellText = .cyan
				builder.buyBackCheckboxButton = .black
				builder.buyBackCheckboxButtonSelected = .red
				builder.buyBackListSeparator = .green
				
				builder.extraDamageBg = .purple
				builder.btnValidateExtraDamage = .yellow
				builder.btnValidateExtraDamageText = .cyan
				builder.btnDeleteExtraDamage = .red
				builder.btnDeleteExtraDamageText = .white
				builder.btnEditDamage = .purple
				builder.btnEditDamageText = .white
			}
		} else {
			builder = TchekReportBuilder(tchekId: tchekScanId, delegate: self)
		}
		
		let viewController = TchekSdk.report(builder: builder)
		navigationController?.pushViewController(viewController, animated: true)
	}
	
	private func addNewScan(_ tchekScanId: String) {
		let scanExist = dynamicTchekScans.first { $0.tchekScanId == tchekScanId }
		if scanExist == nil {
			tableView.beginUpdates()
			dynamicTchekScans.insert(SampleTchekScan(tchekScanId: tchekScanId, label: "By Me", timestamp: Date().timeIntervalSince1970), at: 0)
			updateAdapterAndPreferences()
			tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
			tableView.endUpdates()
		}
	}
	
}

// MARK: Delegate TchekShootInspectDelegate
extension ViewController: TchekShootInspectDelegate {
	func onDetectionInProgress() {
		print("\(self): onDetectionInProgress")
	}
	
	func onDetectionEnd(tchekScan: TchekScan, immatriculation: String?) {
		addNewScan(tchekScan.id)
	}
}

// MARK: Delegate TchekFastTrackDelegate
extension ViewController: TchekFastTrackDelegate {
	func onReportCreated(tchekScan: TchekScan) {
		print("\(self): onReportCreated: tchekScan: \(tchekScan.id)")
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
		if let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCell.IDENTIFIER, for: indexPath) as? TableViewCell {
			let item = currentScans[indexPath.row]
			cell.data(sampleTchekScan: item, actionShootInspect: { tchekScanId in
				self.shootInspect(tchekScanId: tchekScanId)
			},actionFastTrack: { tchekScanId in
				self.fastTrack(tchekScanId: tchekScanId)
			},actionReport: { tchekScanId in
				self.report(tchekScanId: tchekScanId)
			})
			return cell
		}
		return UITableViewCell()
	}
	
	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return true
	}
	
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		guard editingStyle == .delete else {return}
		let item = currentScans[indexPath.row]
		let tchekId = item.tchekScanId
		
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
				if let index = self.dynamicTchekScans.firstIndex(where: { sampleTchekScan in
					sampleTchekScan.tchekScanId == tchekId
				}) {
					self.dynamicTchekScans.remove(at: index)
				}
				
				self.currentScans.remove(at: indexPath.row)
				self.updateAdapterAndPreferences()
				self.tableView.deleteRows(at: [indexPath], with: .automatic)
				self.tableView.endUpdates()
			}
		}
	}
	
	// UITableViewDelegate
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return currentScans.count
	}
}

extension ViewController: UITextFieldDelegate {
	func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
		return true
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		view.endEditing(true)
		return true
	}
}
