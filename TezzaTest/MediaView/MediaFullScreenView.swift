//
//  MediaFullScreenView.swift
//  TezzaTest
//
//  Created by Extremall on 24/01/2025.
//

import SwiftUI
import AVKit

struct MediaFullScreenView: View {
	var importedMedia: [AssetEntity] = []
	@Binding var selectedIndex: Int
	
	var body: some View {
		TabView(selection: $selectedIndex) {
			ForEach(importedMedia.indices, id: \.self) { index in
				let mediaItem = importedMedia[index]
				VStack {
					switch mediaItem.type {
						case .photo:
							if let image = mediaItem.getImage() {
								Image(uiImage: image)
									.resizable()
									.scaledToFit()
									.edgesIgnoringSafeArea(.all)
							}
						case .video:
							if let videoUrl = mediaItem.getFilePath() {
								VideoPlayerView(videoUrl: videoUrl)
							}
					}
				}
				.tag(index)
			}
		}
		.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
		.edgesIgnoringSafeArea(.all)
	}
}
