//
//  MediaPickerViewModel.swift
//  TezzaTest
//
//  Created by Extremall on 23/01/2025.
//

import Foundation
import Photos
import Combine

enum MediaPickerViewSourceType: Int {
	case all = 0
	case photo = 1
	case video = 2
}

final class MediaPickerViewModel: ObservableObject {
	@Published var assets: [PHAsset] = []
	@Published var sourceType: MediaPickerViewSourceType = .all
	@Published var sourceNum: Int = 0
	@Published var selectedAssets: Array<PHAsset> = []
	var cancellable = Set<AnyCancellable>()

	init() {
		$sourceNum.sink { [weak self] value in
			self?.sourceType = MediaPickerViewSourceType(rawValue: value) ?? .all
		}.store(in: &cancellable)

		$sourceType.sink { [weak self] value in
			self?.fetchItems()
			if value != .all {
				self?.selectedAssets.removeAll()
			}
		}.store(in: &cancellable)
	}
	
	func fetchItems() {
		PHPhotoLibrary.requestAuthorization { [weak self] status in
			guard let self else { return }
			if status == .authorized {
				let fetchOptions = PHFetchOptions()
				fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
				switch self.sourceType {
					case .all:
						fetchOptions.predicate = NSPredicate(format: "mediaType = %d || mediaType = %d", PHAssetMediaType.image.rawValue, PHAssetMediaType.video.rawValue)
					case .photo:
						fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
					case .video:
						fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.video.rawValue)
				}
				
				let fetchResult = PHAsset.fetchAssets(with: fetchOptions)
				
				DispatchQueue.main.async {
					self.assets.removeAll()
					fetchResult.enumerateObjects { (asset, _, _) in
						self.assets.append(asset)
					}
				}
			}
		}
	}
}
