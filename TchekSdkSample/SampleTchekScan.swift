//
//  SampleTchekScan.swift
//  TchekSDKSample
//
//  Created by Silvio Pulitano on 23/02/2022.
//

import Foundation

class SampleTchekScan: Codable {
	var tchekScanId: String
	var label: String
	var timestamp: Double
	
	init(tchekScanId: String, label: String, timestamp: Double) {
		self.tchekScanId = tchekScanId
		self.label = label
		self.timestamp = timestamp
	}
	
	func toData() -> Data? {
		do {
			let encoder = JSONEncoder()
			let data = try encoder.encode(self)
			return data
		} catch {
			return nil
		}
	}
	
	static func fromData(data: Data) -> SampleTchekScan? {
		do {
			let decoder = JSONDecoder()
			return try decoder.decode(SampleTchekScan.self, from: data)
		} catch {
			return nil
		}
	}
}
