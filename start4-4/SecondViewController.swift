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
    @IBOutlet weak var toolBarActionItem: UIBarButtonItem!
    @IBOutlet weak var toolBarSortingItem: UIBarButtonItem!
    @IBOutlet weak var toolBarTrashItem: UIBarButtonItem!
    @IBOutlet weak var naviBarEditItem: UIBarButtonItem!
    var isRecentSorting = true;
    var isEditableMode = false;
    
    var collection: PHAssetCollection!
    var fetchResult: PHFetchResult<PHAsset>!
    let imageManager: PHCachingImageManager = PHCachingImageManager()
    let cellIdentifier: String = "cell2"
    var selectedList : [IndexPath] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
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
                                  contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
                                    guard let img = image else { return }
                                    cell.imageView.image  = img}
        )
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("when click cell")
        if isEditableMode {
            if let cell = collectionView.cellForItem(at: indexPath) {
                if let selectedIndex = selectedList.firstIndex(of: indexPath) {
                    cell.layer.borderWidth = 0
                    cell.alpha = 1
                    selectedList.remove(at: selectedIndex)
                } else {
                    cell.layer.borderWidth = 3
                    cell.layer.borderColor = UIColor.black.cgColor
                    cell.alpha = 0.5
                    
                    selectedList.append(indexPath)
                }
            }
        } else {
            print("segue")
            self.performSegue(withIdentifier: "segueForThirdView", sender: indexPath)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nextController = segue.destination as? ThirdViewController {
            if let indexPath = sender as? IndexPath {
                nextController.fetchResult = fetchResult.object(at: indexPath.row) 
            }
        }
    }
    
    @IBAction func touchUpEditingMode(_ sender: UIBarButtonItem) {
        if isEditableMode {
            isEditableMode = false
            sender.title = "편집"
            if let title = collection.localizedTitle {
                self.navigationItem.title = title
            }
            self.selectedList.forEach { (index: IndexPath) in
                if let cell = self.collectionView.cellForItem(at: index) {
                    cell.layer.borderWidth = 0
                    cell.alpha = 1
                }
            }
            self.selectedList = [];
            
            self.toolBarTrashItem.isEnabled = false
            self.toolBarActionItem.isEnabled = false
            self.toolBarSortingItem.isEnabled = true
        } else {
            isEditableMode = true
            sender.title = "취소"
            self.navigationItem.title = "항목 선택"
            self.toolBarTrashItem.isEnabled = true
            self.toolBarActionItem.isEnabled = true
            self.toolBarSortingItem.isEnabled = false
        }
        print("isEditable: \(isEditableMode)")
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
    
    @IBAction func touchUpAction(_ sender: UIBarButtonItem) {
        if isEditableMode {
            print("action")
            self.selectedList.forEach { (index: IndexPath) in
                let asset = self.fetchResult.object(at: index.row)
                imageManager.requestImage(for: asset, targetSize: CGSize(width: 100, height: 100), contentMode: .aspectFill, options: nil) { (image, _) in
                    DispatchQueue.main.async {
                        let activityViewController = UIActivityViewController(
                            activityItems: [image],
                            applicationActivities: nil)
                        activityViewController.popoverPresentationController?.sourceView = self.view
                        self.present(activityViewController, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    @IBAction func touchUpTrash(_ sender: UIBarButtonItem) {
        if isEditableMode {
            print("trash")
            PHPhotoLibrary.shared().performChanges({
                let removeList = self.selectedList.map({ (index: IndexPath) -> PHAsset in
                    return self.fetchResult.object(at: index.row)
                })
                PHAssetChangeRequest.deleteAssets(removeList as NSArray)
            }, completionHandler: nil)
            
        }
    }
    
    private func setupUI() {
        // 타이틀
        if let title = collection.localizedTitle {
            self.navigationItem.title = title
        }
        self.toolBarTrashItem.isEnabled = false
        self.toolBarActionItem.isEnabled = false
        
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
        
        PHPhotoLibrary.shared().register(self)
    }
    
}
