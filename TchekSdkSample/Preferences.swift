//
//  Preferences.swift
//  TchekSDKSample
//
//  Created by Silvio Pulitano on 23/02/2022.
//

import Foundation

class Preferences {
	private let PREVIOUS_SCANS: String = "PREVIOUS_SCANS"
	
	private let sharedPref: UserDefaults = UserDefaults.standard
	
	var previousScans: [SampleTchekScan] {
		get {
			if let array = sharedPref.object(forKey: PREVIOUS_SCANS) as? [Data] {
				return array.compactMap { SampleTchekScan.fromData(data: $0) }
			}
			return []
		}
	}
	
	func saveSampleScans(_ sampleTchekScans: [SampleTchekScan]) {
		let array: [Data?] = sampleTchekScans.compactMap({ it in
			if let object = it.toData() {
				return object
			} else {
				return nil
			}
		})
		sharedPref.set(array.filter { $0 != nil }, forKey: PREVIOUS_SCANS)
	}
}
