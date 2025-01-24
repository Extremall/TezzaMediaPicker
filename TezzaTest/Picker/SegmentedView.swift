//
//  SegmentedView.swift
//  TezzaTest
//
//  Created by Extremall on 23/01/2025.
//

import SwiftUI

struct SegmentedView: View {
	@Binding var selectedTab: Int
	
	var body: some View {
		Picker("Select Category", selection: $selectedTab) {
			Text("ALL").tag(0)
			Text("PHOTO").tag(1)
			Text("VIDEO").tag(2)
		}
		.pickerStyle(SegmentedPickerStyle())
		.padding()
	}
}
