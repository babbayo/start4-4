//
//  SecondViewController.swift
//  start4-4
//
//  Created by MacBook on 24/11/2019.
//  Copyright © 2019 yaco. All rights reserved.
//

import UIKit
import Photos

class SecondViewController: UIViewController, UICollectionViewDelegate,  UICollectionViewDataSource, PHPhotoLibraryChangeObserver, UINavigationBarDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var toolBarSortingItem: UIBarButtonItem!
    @IBOutlet weak var naviBarEditItem: UIBarButtonItem!
    var isRecentSorting = true;
    var isEditableMode = false;
    
    var collection: PHAssetCollection!
    var fetchResult: PHFetchResult<PHAsset>!
    let imageManager: PHCachingImageManager = PHCachingImageManager()
    let cellIdentifier: String = "cell2"
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let changes = changeInstance.changeDetails(for: fetchResult) else { return }
        
        fetchResult = changes.fetchResultAfterChanges
        
        OperationQueue.main.addOperation {
            self.collectionView.reloadSections(IndexSet(0...0))
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResult.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellIdentifier, for: indexPath) as! SecondCollectionViewCell
        
        
        let asset = fetchResult.object(at: indexPath.row)
        
        imageManager.requestImage(for: asset,
                                  targetSize: CGSize(width: 100, height: 100),
                                  contentMode: .aspectFill, options: nil, resultHandler: { image, _ in cell.imageView?.image  = image})
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return isEditableMode
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("click")
        if isEditableMode {
            print("click2 아래 코드 를 실행시키고 싶어요")
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellIdentifier, for: indexPath) as! SecondCollectionViewCell
            cell.layer.borderWidth = 1
            cell.layer.borderColor = UIColor.red.cgColor
            
//            collectionView.reloadData()
        } else {
            // 선택하면 다음 페이지로 넘어가고 싶어요
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        let count = collection.estimatedAssetCount
        print(count)
        if count == 0 {
            return
        }
        
        // 레이아웃
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets.zero // inset 을 업애달라
        flowLayout.minimumInteritemSpacing = 3 // 아이템간 거리
        flowLayout.minimumLineSpacing = 3 // 줄간 거리
        
        let divied: CGFloat = UIScreen.main.bounds.width / 3.0 // 2개씩 배치
        let customWidth: CGFloat = divied - 3
        flowLayout.itemSize = CGSize(width: customWidth, height: customWidth)
        self.collectionView.collectionViewLayout = flowLayout
        
        // list set
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        let assets = PHAsset.fetchAssets(in: collection, options: allPhotosOptions)
        fetchResult = assets
    }
    
    @IBAction func touchUpEditingMode(_ sender: UIBarButtonItem) {
        if isEditableMode {
            sender.title = "편집"
            isEditableMode = false
        } else {
            sender.title = "취소"
            isEditableMode = true
        }
    }
    
    @IBAction func touchUpSorting(_ sender: UIBarButtonItem) {
        if isRecentSorting {
            sender.title = "과거순"
            let allPhotosOptions = PHFetchOptions()
            allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            let assets = PHAsset.fetchAssets(in: collection, options: allPhotosOptions)
            fetchResult = assets
            isRecentSorting = false
        } else {
            sender.title = "최신순"
            let allPhotosOptions = PHFetchOptions()
            allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
            let assets = PHAsset.fetchAssets(in: collection, options: allPhotosOptions)
            fetchResult = assets
            isRecentSorting = true
        }
        
        collectionView.reloadData()
    }

}
