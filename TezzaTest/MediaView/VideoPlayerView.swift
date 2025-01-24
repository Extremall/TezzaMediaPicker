//
//  VideoPlayerView.swift
//  TezzaTest
//
//  Created by Extremall on 24/01/2025.
//

import SwiftUI
import AVKit

struct VideoPlayerView: View {
	let videoUrl: URL
	@State private var player: AVQueuePlayer!
	
	var body: some View {
		VideoPlayer(player: player)
			.edgesIgnoringSafeArea(.all)
			.onAppear {
				setupPlayer()
			}
	}

	private func setupPlayer() {
		let asset = AVAsset(url: videoUrl)
		let item = AVPlayerItem(asset: asset)

		player = AVQueuePlayer(items: [item])
		player.play()

		player.actionAtItemEnd = .none
		NotificationCenter.default.addObserver(
			forName: .AVPlayerItemDidPlayToEndTime,
			object: item,
			queue: .main
		) { _ in
			player.seek(to: .zero)
			player.play()
		}
	}
}
