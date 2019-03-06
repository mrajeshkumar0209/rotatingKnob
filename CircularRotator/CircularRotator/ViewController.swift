//
//  ViewController.swift
//  CircularRotator
//
//  Created by Rajeshkumar maddi on 06/03/19.
//  Copyright © 2019 SaiRajesh. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController,
CircularRotatorDelegate, UICollectionViewDelegate,UICollectionViewDataSource {
    @IBOutlet weak var rotator: CircularRotator!
    var images = [PHAsset]()
    @IBOutlet weak var photosCollectionView: UICollectionView!
    @IBOutlet weak internal var backgroundImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rotator.startAngle = 0
        rotator.endAngle = 360
        rotator.currentAngle = 0
        
        rotator.thumbColor = UIColor(red: 242.0/255.0, green: 107.0/255.0, blue: 107.0/255.0, alpha: 1.0)
        rotator.rotatingBarColor = UIColor(red: 238.0/255.0, green: 238.0/255.0, blue: 238.0/255.0, alpha: 1.0)
        rotator.delegate = self
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    func circularRotator(_ Rotator: CircularRotator, didChangeValue value: Float) {
        rotator.thumbButton.setTitle("\(Int(value))", for: UIControl.State.normal)
        
        DispatchQueue.global(qos: .background).async {
            self.getImages(value: Int(value))
            DispatchQueue.main.async {
                // To show photos, I have taken a UICollectionView
                self.photosCollectionView.reloadData()
                let index = self.getIndex(value: Int(value), imageCount: self.images.count)
                self.backgroundImage.image = self.getAssetThumbnail(asset: self.images[index])
            }
        }
    }
    
    //MARK: Getting Images from Photo Library Or Camera Roll
    
    func getImages(value:Int) {
        self.images.removeAll()
        let assets = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: nil)
        assets.enumerateObjects({ (object, count, stop) in
            if self.images.count < 20 {
              self.images.append(object)
            }
        })
        //In order to get latest image first, we just reverse the array
        self.images.reverse()
    }
    func getIndex(value:Int,imageCount:Int)->Int{
        for item in 1...imageCount{
            if value != 0{
                let seg = Int(360/imageCount)
                if value > ((item-1)*seg) && value <= (item*seg){
                    return (item-1)
                }
            }
        }
        return 0
    }
    
    //MARK: PHAsset to UIImage
    
    func getAssetThumbnail(asset: PHAsset) -> UIImage {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var thumbnail = UIImage()
        option.isSynchronous = true
        manager.requestImage(for: asset, targetSize: CGSize(width: self.backgroundImage.frame.size.width, height: self.backgroundImage.frame.size.height), contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
            thumbnail = result!
        })
        return thumbnail
    }
    
    //MARK:CollectionView DataSource & Delegates
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photosCollectionCell", for: indexPath) as! photosCollectionCell
        let asset = images[indexPath.row]
        let manager = PHImageManager.default()
        if cell.tag != 0 {
            manager.cancelImageRequest(PHImageRequestID(cell.tag))
        }
        cell.tag = Int(manager.requestImage(for: asset,
                                            targetSize: CGSize(width: 120.0, height: 120.0),
                                            contentMode: .aspectFill,
                                            options: nil) { (result, _) in
                                                cell.photoView?.image = result
        })
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.view.frame.width * 0.32
        let height = self.view.frame.height * 0.179910045
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2.5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}



