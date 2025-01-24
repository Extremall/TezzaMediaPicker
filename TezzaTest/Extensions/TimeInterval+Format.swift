//
//  TimeInterval+Format.swift
//  TezzaTest
//
//  Created by Extremall on 24/01/2025.
//

import Foundation

extension TimeInterval {
	var time: String {
		let secons = Int(self)
		let hours = secons / 3600
		let minutes = (secons % 3600) / 60
		let remainingSeconds = secons % 60

		if hours > 0 {
			return String(format: "%02d:%02d:%02d", hours, minutes, remainingSeconds)
		} else {
			return String(format: "%02d:%02d", minutes, remainingSeconds)
		}
	}
}
