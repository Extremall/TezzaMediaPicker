//
//  ProgressView.swift
//  TezzaTest
//
//  Created by Extremall on 24/01/2025.
//

import SwiftUI

struct GridProgressView: View {
	@ObservedObject var viewModel: GridProgressViewModel
	
	var body: some View {
		ZStack {
			Color.white.opacity(0.7)
				.ignoresSafeArea(.all)
			VStack {
				Group {
					Text("\(Int(viewModel.progress * 100))%")
					ProgressView("Importing", value: viewModel.progress, total: 1.0)
						.progressViewStyle(LinearProgressViewStyle())
				}.padding(12)
			}
			.background {
				RoundedRectangle(cornerRadius: 20)
					.fill(Color.yellow)
					.stroke(Color.red, lineWidth: 2)
			}
			.padding(32)
		}
	}
}

final class GridProgressViewModel: ObservableObject {
	@Published var progress: Double = 0
}
