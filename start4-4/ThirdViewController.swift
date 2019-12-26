//
//  ThirdViewController.swift
//  start4-4
//
//  Created by MacBook on 24/11/2019.
//  Copyright © 2019 yaco. All rights reserved.
//

import UIKit
import Photos

class ThirdViewController: UIViewController, UIScrollViewDelegate, PHPhotoLibraryChangeObserver {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var toolBarHeartItem: UIBarButtonItem!
    
    var fetchResult: PHAsset!
    let imageManager: PHCachingImageManager = PHCachingImageManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageManager.requestImage(for: fetchResult,
                                  targetSize: CGSize(width:fetchResult.pixelWidth, height: fetchResult.pixelHeight),
                                  contentMode: .aspectFill, options: nil, resultHandler: { image, _ in self.imageView?.image  = image})
        
        let favoriteName = self.fetchResult.isFavorite ? "heart.fill" : "heart"
        self.toolBarHeartItem.image = UIImage.init(systemName: favoriteName)
        PHPhotoLibrary.shared().register(self)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let changes = changeInstance.changeDetails(for: fetchResult) else {
            print("not changed")
            return }
        
        print("changed photo")
        fetchResult = changes.objectAfterChanges
    }
    
    @IBAction func touchUpHeart(_ sender: UIBarButtonItem) {
        print("touch up heart")
        let isFavorite = !self.fetchResult.isFavorite
        PHPhotoLibrary.shared().performChanges({
            let request = PHAssetChangeRequest(for: self.fetchResult)
            request.isFavorite = isFavorite
        }, completionHandler: { success, error in
            if success {
                print("success")
                DispatchQueue.main.sync {
                    let favoriteName = isFavorite ? "heart.fill" : "heart"
                    self.toolBarHeartItem.image = UIImage.init(systemName: favoriteName)
                }
            } else {
                print("Can't mark the asset as a Favorite: \(String(describing: error))")
            }
        })
    }
    
    @IBAction func touchUpAction(_ sender: UIBarButtonItem) {
        print("action")
        imageManager.requestImage(for: self.fetchResult, targetSize: CGSize(width: 100, height: 100), contentMode: .aspectFill, options: nil) { (image, _) in
            DispatchQueue.main.async {
                let activityViewController = UIActivityViewController(
                    activityItems: [image],
                    applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = self.view
                self.present(activityViewController, animated: true, completion: nil)
            }
        }
    }
    
    
    @IBAction func touchUpTrash(_ sender: UIBarButtonItem) {
        print("trash")
        PHPhotoLibrary.shared().performChanges({
            
            let assets = [self.fetchResult]
            PHAssetChangeRequest.deleteAssets(assets as NSArray)
            
        }, completionHandler: nil)
        
        
    }
}
