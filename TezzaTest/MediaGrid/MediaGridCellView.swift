//
//  MediaGridCellView.swift
//  TezzaTest
//
//  Created by Extremall on 24/01/2025.
//

import SwiftUI

struct MediaGridCellView: View {
	let assetEntity: AssetEntity
	let size: CGFloat
	let selected: Bool
	
	var body: some View {
		VStack {
			if let thumbnail = assetEntity.getThumbnailImage() {
				Image(uiImage: thumbnail)
					.resizable()
					.scaledToFill()
					.frame(width: size, height: size)
					.clipShape(Rectangle())
					.contentShape(Rectangle())
					.overlay {
						Rectangle()
							.stroke(selected ? Color.red : Color.clear, lineWidth: 3)
							.frame(width: size - 3, height: size - 3)
					}
			} else {
				Image(systemName: "photo")
			}
		}
	}
}
