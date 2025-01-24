//
//  AssetEntity.swift
//  TezzaTest
//
//  Created by Extremall on 23/01/2025.
//

import UIKit
import RealmSwift

enum AssetEntityType {
	case photo
	case video
}

class AssetEntity: Object {
	@objc dynamic var phAssetID: String = ""
	@objc dynamic var localPath: String = ""
	@objc dynamic var thumbnailPath: String = ""

	override static func primaryKey() -> String? {
		return "phAssetID"
	}
}

extension AssetEntity {
	func getFilePath() -> URL? {
		let fileURL = FileStorageManager.shared.fileUrl(fileName: localPath)
		return fileURL
	}
	
	func getThumbnailFilePath() -> URL? {
		let fileURL = FileStorageManager.shared.fileUrl(fileName: thumbnailPath)
		return fileURL
	}

	func getImage() -> UIImage? {
		guard let path = getFilePath() else { return nil }
		guard let data = try? Data(contentsOf: path) else { return nil }
		return UIImage(data: data)
	}
	
	func getThumbnailImage() -> UIImage? {
		guard let path = getThumbnailFilePath() else { return nil }
		guard let data = try? Data(contentsOf: path) else { return nil }
		return UIImage(data: data)
	}

	var type: AssetEntityType {
		localPath.hasSuffix("jpg") ? .photo : .video
	}
}
