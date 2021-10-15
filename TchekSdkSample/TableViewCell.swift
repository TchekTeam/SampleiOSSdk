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
	
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
	
	func data(tchekId: String) {
		lblTchekId.text = "Tchek: \(tchekId)"
	}

}
