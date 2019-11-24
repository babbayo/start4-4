//
//  ViewController.swift
//  start4-4
//
//  Created by MacBook on 24/11/2019.
//  Copyright © 2019 yaco. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController, PHPhotoLibraryChangeObserver, UICollectionViewDataSource {
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    var fetchResult: PHFetchResult<PHAssetCollection>!
    let imageManager: PHCachingImageManager = PHCachingImageManager()
    let cellIdentifier: String = "cell"
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResult.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellIdentifier, for: indexPath) as! FirstCollectionViewCell
        
        
        let assetCollection = fetchResult.object(at: indexPath.row)
        
        if let title = assetCollection.localizedTitle {
            cell.label1.text = title
        }
        
        let count = assetCollection.estimatedAssetCount
        //        print(count)
        cell.label2.text = String(count)
        
        if count == 0 {
            return cell
        }
        
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        let assets = PHAsset.fetchAssets(in: assetCollection, options: allPhotosOptions)
        if assets.count == 0 {
            print("wrong")
            return cell
        }
        
        
        let asset = assets[0]
        cell.imageView?.layer.cornerRadius = 5
        imageManager.requestImage(for: asset,
                                  targetSize: CGSize(width: 200, height: 200),
                                  contentMode: .aspectFill, options: nil, resultHandler: { image, _ in cell.imageView?.image  = image})
        return cell
    }
    
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let changes = changeInstance.changeDetails(for: fetchResult) else { return }
        
        fetchResult = changes.fetchResultAfterChanges
        
        OperationQueue.main.addOperation {
            self.collectionView.reloadSections(IndexSet(0...0))
        }
    }
    
    func requestCollection() {
        
        let folders = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil)
        fetchResult = folders
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setToolbarHidden(true, animated: false)
//        self.navigationController?.isNavigationBarHidden = true
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets.zero // inset 을 업애달라
        flowLayout.minimumInteritemSpacing = 5 // 아이템간 거리
        flowLayout.minimumLineSpacing = 2 // 줄간 거리
        
        
        let halfWidth: CGFloat = UIScreen.main.bounds.width / 2.0 // 2개씩 배치
        let customHeight: CGFloat = halfWidth + 30.0
        let customWidth: CGFloat = halfWidth - 5
        flowLayout.itemSize = CGSize(width: customWidth, height: customHeight)
        //        flowLayout.estimatedItemSize = CGSize(width: customWidth, height: customHeight)
        
        self.collectionView.collectionViewLayout = flowLayout
        
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        switch photoAuthorizationStatus {
        case .authorized:
            print("접근 허가됨")
            self.requestCollection()
            self.collectionView.reloadData()
        case .denied:
            print("접근 불허")
        case .notDetermined:
            print("아직 대답하지 않음")
            PHPhotoLibrary.requestAuthorization({ (status) in switch status {
            case .authorized:
                self.requestCollection()
                OperationQueue.main.addOperation {
                    self.collectionView.reloadData()
                }
            default: break
                }
            })
        case .restricted:
            print("접근 제한")
        }
        PHPhotoLibrary.shared().register(self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let nextViewController = segue.destination as? SecondViewController else {
            return
        }
        
        guard let cell: FirstCollectionViewCell = sender as? FirstCollectionViewCell else {
            return
        }
        guard let index: IndexPath = self.collectionView.indexPath(for: cell) else {
            return
        }
        
        nextViewController.collection = self.fetchResult[index.row]
        nextViewController.navigationController?.setToolbarHidden(true, animated: false)
//        self.navigationController?.setToolbarHidden(true, animated: false)
    }
    
    
}

