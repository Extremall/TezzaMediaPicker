//
//  MediaGridView.swift
//  TezzaTest
//
//  Created by Extremall on 22/01/2025.
//

import SwiftUI

struct MediaGridView: View {
	@State private var isPhotoPickerPresented = false
	@State private var isFullPickerPresented = false
	
	@StateObject var viewModel = MediaGridViewModel()
	@State private var isSelectState = false
	@State private var selected = Set<String>()

	@State var selectedIndex: Int = 0
	
	let columns = [
			GridItem(.flexible(), spacing: 4),
			GridItem(.flexible(), spacing: 4),
			GridItem(.flexible(), spacing: 4)
		]
	
	var body: some View {
		ZStack {
			VStack {
				HStack(spacing: 30) {
					Button("Import") {
						isPhotoPickerPresented.toggle()
					}
					
					if selected.count > 0 {
						Button("Remove") {
							viewModel.removeAssets(ids: selected)
							selected.removeAll()
							isSelectState = false
						}
					}
					Spacer()
				}
				.padding(.bottom, 40)
				.padding(.horizontal, 20)
				GeometryReader { geo in
					ScrollView {
						LazyVGrid(columns: columns, spacing: 20) {
							ForEach(viewModel.importedMedia, id: \.phAssetID) { item in
								MediaGridCellView(
									assetEntity: item,
									size: (geo.size.width - 16) / 3,
									selected: selected.contains(item.phAssetID)
								)
								.gesture(
									TapGesture()
										.onEnded {
											if selected.contains(item.phAssetID) {
												selected.remove(item.phAssetID)
											} else {
												selected.insert(item.phAssetID)
											}
										}
										.simultaneously(with:
											TapGesture(count: 2)
												.onEnded {
													selectedIndex = viewModel.importedMedia.firstIndex(of: item) ?? 0
													isFullPickerPresented = true
												}
									)
								)
							}
						}
					}
				}
			}
			ProgressView(viewModel: viewModel.progressViewModel)
				.opacity(viewModel.isImporting ? 1.0 : 0.0)
			
		}
		.sheet(isPresented: $isPhotoPickerPresented) {
			MediaPickerView { assets in
				viewModel.importAssets(assets: assets)
				selected.removeAll()
			}
		}
		.sheet(isPresented: $isFullPickerPresented){
			MediaFullScreenView(importedMedia: viewModel.importedMedia, selectedIndex: $selectedIndex)
		}
		.onAppear {
			viewModel.fetchImported()
		}
	}
}
