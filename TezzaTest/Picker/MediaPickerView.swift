//
//  MediaPickerView.swift
//  TezzaTest
//
//  Created by Extremall on 23/01/2025.
//

import SwiftUI
import Photos

struct MediaPickerView: View {
	@Environment(\.presentationMode) var presentationMode
	@StateObject var viewModel = MediaPickerViewModel()
	let completion: (([PHAsset]) -> Void)

	let columns = [
		GridItem(.flexible(), spacing: 2),
		GridItem(.flexible(), spacing: 2),
		GridItem(.flexible(), spacing: 2),
		GridItem(.flexible(), spacing: 2)
	]

	var body: some View {
		VStack {
			SegmentedView(selectedTab: $viewModel.sourceNum)
			
			GeometryReader { geo in
				ScrollView {
					LazyVGrid(columns: columns, spacing: 2) {
						ForEach(viewModel.assets, id: \.localIdentifier) { asset in
							MediaPickerThumbnailView(
								asset: asset,
								selectedNumber: viewModel.selectedAssets.firstIndex(of: asset),
								size: (geo.size.width - 6) / 4
							) {
								if let index = viewModel.selectedAssets.firstIndex(of: asset) {
									viewModel.selectedAssets.remove(at: index)
								} else {
									viewModel.selectedAssets.append(asset)
								}
							}
						}
					}
				}
			}

			Button("Done") {
				completion(viewModel.selectedAssets)
				presentationMode.wrappedValue.dismiss()
			}
			.padding()
			.disabled(viewModel.selectedAssets.isEmpty)
		}
		.onAppear {
			viewModel.fetchItems()
		}
		.padding(2)
	}
}
