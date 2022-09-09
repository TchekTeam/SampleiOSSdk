//
//  TableViewCell.swift
//  TchekSDKSample
//
//  Created by Silvio Pulitano on 12/10/2021.
//

import UIKit

class TableViewCell: UITableViewCell {
	
	static let IDENTIFIER = "TableViewCell"

	@IBOutlet weak var lblTchekId: UILabel!
	
	
	private var sampleTchekScan: SampleTchekScan!
	
	var actionShootInspect: ((String) -> Void)? = nil
	var actionFastTrack: ((String) -> Void)? = nil
	var actionReport: ((String) -> Void)? = nil
	
	override func layoutSubviews() {
		super.layoutSubviews()

		contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0))
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		contentView.layer.cornerRadius = 8
		contentView.layer.borderColor = UIColor.white.cgColor
		contentView.backgroundColor = .white
						
		// cell selection
		let view = UIView()
		view.backgroundColor = .clear
		selectedBackgroundView = view
	}
	
	func data(sampleTchekScan: SampleTchekScan,
			  actionShootInspect: @escaping ((String) -> Void),
			  actionFastTrack: @escaping ((String) -> Void),
			  actionReport: @escaping ((String) -> Void)) {
		self.sampleTchekScan = sampleTchekScan
		lblTchekId.text = "\(sampleTchekScan.tchekScanId) - \(sampleTchekScan.label)"
		
		self.actionShootInspect = actionShootInspect
		self.actionFastTrack = actionFastTrack
		self.actionReport = actionReport
	}

	@IBAction func actionShootInspect(_ sender: Any) {
		actionShootInspect?(sampleTchekScan.tchekScanId)
	}
	
	@IBAction func actionFastTrack(_ sender: Any) {
		actionFastTrack?(sampleTchekScan.tchekScanId)
	}
	
	@IBAction func actionReport(_ sender: Any) {
		actionReport?(sampleTchekScan.tchekScanId)
	}
	
}
