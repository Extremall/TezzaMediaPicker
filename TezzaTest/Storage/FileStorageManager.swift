//
//  FileStorageManager.swift
//  TezzaTest
//
//  Created by Extremall on 23/01/2025.
//

import UIKit
import Photos

final class FileStorageManager {
	static let shared = FileStorageManager()

	func fileUrl(fileName: String) -> URL {
		let fileManager = FileManager.default
		let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
		let fileURL = documentDirectory.appendingPathComponent(fileName)
		return fileURL
	}
	
	func saveVideoAssetToAppDirectory(asset: PHAsset) async throws -> String {
		let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
		if status == .denied || status == .restricted {
			throw NSError(domain: "MediaPickerError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Access to the photo library is denied or restricted."])
		}
		
		let options = PHAssetResourceRequestOptions()
		options.isNetworkAccessAllowed = true

		guard let resource = PHAssetResource.assetResources(for: asset).first(where: { $0.type == .video }) else {
			throw NSError(domain: "MediaPickerError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Video not found"])
		}

		let identifier = asset.localIdentifier.replacingOccurrences(of: "/", with: "")
		let fileName = "\(identifier).mp4"
		let fileURL = fileUrl(fileName: fileName)

		
		return try await withCheckedThrowingContinuation { continuation in
			let resourceManager = PHAssetResourceManager.default()
			resourceManager.writeData(for: resource, toFile: fileURL, options: options) { error in
				if let error = error {
					continuation.resume(throwing: error)
				} else {
					continuation.resume(returning: fileName)
				}
			}
		}
	}

	func saveImageAssetToAppDirectory(asset: PHAsset) async throws -> String {
		let image = try await loadImage(for: asset)
		if let imageData = image?.jpegData(compressionQuality: 1.0) {
			let identifier = asset.localIdentifier.replacingOccurrences(of: "/", with: "")
			let fileName = "\(identifier).jpg"
			let fileURL = fileUrl(fileName: fileName)
			
			do {
				try imageData.write(to: fileURL)
				return fileName
			} catch {
				throw NSError(domain: "ImageError",
						  code: -1,
						  userInfo: [NSLocalizedDescriptionKey: "Can't save the image"]
					  )
			}
		} else {
			throw NSError(domain: "ImageError",
					  code: -1,
					  userInfo: [NSLocalizedDescriptionKey: "Can't convert the image to jpeg"]
				  )
		}
	}

	func saveImageThumbnailAssetToAppDirectory(asset: PHAsset) async throws -> String {
		let image = try await loadImage(for: asset, size: CGSize(width: 150, height: 150))
		if let imageData = image?.jpegData(compressionQuality: 1.0) {
			let identifier = asset.localIdentifier.replacingOccurrences(of: "/", with: "")
			let fileName = "\(identifier)_thumbnail.jpg"
			let fileURL = fileUrl(fileName: fileName)
			
			do {
				// Сохраняем изображение в файл
				try imageData.write(to: fileURL)
				return fileName
			} catch {
				throw NSError(domain: "ImageError",
						  code: -1,
						  userInfo: [NSLocalizedDescriptionKey: "Can't save the image"]
					  )
			}
		} else {
			throw NSError(domain: "ImageError",
					  code: -1,
					  userInfo: [NSLocalizedDescriptionKey: "Can't convert the image to jpeg"]
				  )
		}
	}

	func loadImage(for asset: PHAsset, size: CGSize = CGSize(
		width: CGFloat.greatestFiniteMagnitude,
		height: CGFloat.greatestFiniteMagnitude
	)) async throws -> UIImage? {
		let requestOptions = PHImageRequestOptions()
		requestOptions.isSynchronous = false
		
		return try await withCheckedThrowingContinuation { continuation in
			PHImageManager.default().requestImage(
				for: asset,
				targetSize: size,
				contentMode: .aspectFill,
				options: requestOptions
			) { result,info in
				if let info = info, let isCancelled = info[PHImageCancelledKey] as? Bool, isCancelled {
					continuation.resume(throwing: NSError(domain: "ImageError", code: -2, userInfo: [NSLocalizedDescriptionKey: "Image request was cancelled"]))
					return
				}
				
				if let error = info?[PHImageErrorKey] as? NSError {
					continuation.resume(throwing: error)
					return
				}
				
				if let info = info, let isDegraded = info[PHImageResultIsDegradedKey] as? Bool, isDegraded {
					return
				}

				if let result = result {
					continuation.resume(returning: result)
				} else {
					continuation.resume(throwing: NSError(domain: "ImageError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Can't load the image"]))
				}
			}
		}
	}

	func removeFile(fileName: String) {
		let fileURL = fileUrl(fileName: fileName)
		let fileManager = FileManager.default
		try? FileManager.default.removeItem(at: fileURL)
	}
}
