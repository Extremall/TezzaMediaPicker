//
//  ProgressView.swift
//  TezzaTest
//
//  Created by Extremall on 24/01/2025.
//

import SwiftUI

struct ProgressView: View {
	@ObservedObject var viewModel: ProgressViewModel
	
	var body: some View {
		ZStack {
			Color.white.opacity(0.7)
				.ignoresSafeArea(.all)
			VStack {
				Text("\(Int(viewModel.progress * 100))%")
			}
		}
	}
}

final class ProgressViewModel: ObservableObject {
	@Published var progress: Double = 0
}
