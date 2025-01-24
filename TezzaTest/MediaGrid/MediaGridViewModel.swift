//
//  MediaGridViewModel.swift
//  TezzaTest
//
//  Created by Extremall on 22/01/2025.
//

import Photos
import Foundation

final class MediaGridViewModel: ObservableObject {
	@Published var importedMedia: [AssetEntity] = []
	@Published var isImporting: Bool = false
	var progressViewModel = GridProgressViewModel()

	func fetchImported() {
		let database = DatabaseManager.shared
		importedMedia = database.fetchAssets()
	}

	func importAssets(assets: [PHAsset]) {
		isImporting = true
		Task {
			await processAssets(assets: assets) { [weak self] progress in
				print("progress: \(progress) of \(assets.count)")
				DispatchQueue.main.async { [weak self] in
					self?.progressViewModel.progress = Double(progress) / Double(assets.count)
				}
			}
			await MainActor.run {
				isImporting = false
				fetchImported()
			}
		}
	}

	func removeAssets(ids: Set<String>) {
		importedMedia = importedMedia.filter { !ids.contains($0.phAssetID) }

		for assetID in ids {
			DatabaseManager.shared.deleteAsset(phAssetID: assetID)
		}
	}

	func processAssets(assets: [PHAsset], progressHandler: @escaping (Int) -> Void) async {
		var savedAssetsCount = 0
		let storage = FileStorageManager.shared
		let database = DatabaseManager.shared
		
		for asset in assets {
			do {
				let thumbnailName = try await storage.saveImageThumbnailAssetToAppDirectory(asset: asset)
				if asset.mediaType == .image {
					let fileName = try await storage.saveImageAssetToAppDirectory(asset: asset)
					database.saveAsset(phAssetID: asset.localIdentifier, localPath: fileName, thumbnailPath: thumbnailName)
				} else if asset.mediaType == .video {
					let fileName = try await storage.saveVideoAssetToAppDirectory(asset: asset)
					database.saveAsset(phAssetID: asset.localIdentifier, localPath: fileName, thumbnailPath: thumbnailName)
				}

				savedAssetsCount += 1
				progressHandler(savedAssetsCount)
			} catch {
				print("Error for asset: \(asset.localIdentifier): \(error)")
			}
		}
	}
}
