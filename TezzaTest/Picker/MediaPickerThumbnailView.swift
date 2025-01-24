//
//  MediaPickerThumbnailView.swift
//  TezzaTest
//
//  Created by Extremall on 23/01/2025.
//

import SwiftUI
import Photos

struct MediaPickerThumbnailView: View {
	let asset: PHAsset
	let selectedNumber: Int?
	let size: CGFloat
	let action: () -> Void

	@State private var image: UIImage? = nil

	var body: some View {
		ZStack {
			if let image = image {
				Image(uiImage: image)
					.resizable()
					.scaledToFill()
					.frame(width: size, height: size)
					.clipShape(Rectangle())
					.contentShape(Rectangle())
					.overlay(
						Rectangle()
							.stroke(selectedNumber != nil ? Color.red : Color.clear, lineWidth: 3)
							.frame(width: size - 3, height: size - 3)
					)
					.onTapGesture {
						action()
					}
			} else {
				Image(systemName: "photo")
					.resizable()
					.scaledToFit()
					.frame(height: size)
					.padding()
					.onAppear {
						Task {
							await loadImage()
						}
					}
			}
			if let selectedNumber {
				HStack {
					VStack {
						ZStack {
							Circle()
								.fill(.red)
								.stroke(.white, lineWidth: 2)
								.frame(width: 20, height: 20)
								.padding(5)
							Text("\(selectedNumber + 1)")
								.foregroundStyle(.white)
								.font(.subheadline)
						}
						Spacer()
					}
					Spacer()
				}
			}
			if asset.mediaType == .video {
				HStack{
					Spacer()
					VStack {
						Image(systemName: "video.fill")
							.foregroundColor(Color.white)
							.frame(width: 20, height: 20)
							.padding(8)
						Spacer()
						Text(asset.duration.time)
							.font(.subheadline)
							.foregroundStyle(Color.white)
							.padding(8)
					}
				}
			}
		}
	}

	private func loadImage() async {
		let size = CGSize(width: size, height: size)
		let requestOptions = PHImageRequestOptions()
		requestOptions.isSynchronous = true

		do {
			if let result = try await PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: requestOptions) {
				self.image = result
			}
		} catch {
			print("Ошибка загрузки изображения: \(error)")
		}
	}
}

extension PHImageManager {
	func requestImage(for asset: PHAsset, targetSize: CGSize, contentMode: PHImageContentMode, options: PHImageRequestOptions) async throws -> UIImage? {
		return try await withCheckedThrowingContinuation { continuation in
			requestImage(for: asset, targetSize: targetSize, contentMode: contentMode, options: options) { result, info in
				if let result = result {
					continuation.resume(returning: result)
				} else {
					continuation.resume(throwing: NSError(domain: "PHImageManagerError", code: -1, userInfo: nil))
				}
			}
		}
	}
}
