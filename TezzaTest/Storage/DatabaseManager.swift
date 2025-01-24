//
//  DatabaseManager.swift
//  TezzaTest
//
//  Created by Extremall on 22/01/2025.
//

import RealmSwift
import Foundation

final class DatabaseManager {
	static let shared = DatabaseManager()
	let queue = DispatchQueue(label: "realm.queue")

	init() {
	}

	func saveAsset(phAssetID: String, localPath: String, thumbnailPath: String) {
		queue.sync {
			let realm = try! Realm()
			let assetEntity = AssetEntity()
			assetEntity.phAssetID = phAssetID
			assetEntity.localPath = localPath
			assetEntity.thumbnailPath = thumbnailPath
			
			try! realm.write {
				realm.add(assetEntity, update: .modified)
			}
		}
	}

	func fetchAssets() -> [AssetEntity] {
		queue.sync {
			let realm = try! Realm()
			let assets = realm.objects(AssetEntity.self)
			return Array(assets)
		}
	}

	func fetchAssetByID(phAssetID: String) -> AssetEntity? {
		queue.sync {
			let realm = try! Realm()
			return realm.object(ofType: AssetEntity.self, forPrimaryKey: phAssetID)
		}
	}

	func deleteAsset(phAssetID: String) {
		queue.sync {
			let realm = try! Realm()
			if let asset = realm.object(ofType: AssetEntity.self, forPrimaryKey: phAssetID) {
				FileStorageManager.shared.removeFile(fileName: asset.localPath)
				FileStorageManager.shared.removeFile(fileName: asset.thumbnailPath)
				try! realm.write {
					realm.delete(asset)
				}
			}
		}
	}
}
