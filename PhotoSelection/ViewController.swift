//
//  ViewController.swift
//  PhotoSelection
//
//  Created by StemDot on 10/17/18.
//  Copyright © 2018 Stemdot Business Solution. All rights reserved.
//

import UIKit
import Photos
class ViewController: UICollectionViewController, UIGestureRecognizerDelegate  {

    var imageArray = [UIImage]()
   var _selectedCells = [UIImage]()
    
    override func viewDidLoad() {
        collectionView.allowsMultipleSelection = true
        grabPhotos()
    }
    
    var selectMode = true
    var lastSelectedCell = IndexPath()
    
    func selectCell(_ indexPath: IndexPath, selected: Bool) {
        if let cell = collectionView.cellForItem(at: indexPath) {
            if cell.isSelected {
                collectionView.deselectItem(at: indexPath, animated: true)
                collectionView.scrollToItem(at: indexPath, at: UICollectionView.ScrollPosition.centeredVertically, animated: true)
                
                
                cell.layer.borderWidth = 5.0
                cell.layer.borderColor = UIColor.red.cgColor
            } else {
                collectionView.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionView.ScrollPosition.centeredVertically)
            }
            if let numberOfSelections = collectionView.indexPathsForSelectedItems?.count {
                title = "\(numberOfSelections) items selected"
                print(title ?? "pawan")
            }
        }
    }
    
    @objc func didPan(toSelectCells panGesture: UIPanGestureRecognizer) {
        print("pan is started \(selectMode)")
        if !selectMode {
            collectionView?.isScrollEnabled = true
            return
        } else {
            if panGesture.state == .began {
                collectionView?.isUserInteractionEnabled = false
                collectionView?.isScrollEnabled = false
            }
            else if panGesture.state == .changed {
                let location: CGPoint = panGesture.location(in: collectionView)
                if let indexPath: IndexPath = collectionView?.indexPathForItem(at: location) {
                    if indexPath != lastSelectedCell {
                        print("last selected index\(indexPath)")
                        self.selectCell(indexPath, selected: true)
                        lastSelectedCell = indexPath
                    }
                }
            } else if panGesture.state == .ended {
                collectionView?.isScrollEnabled = true
                collectionView?.isUserInteractionEnabled = true
                //swipeSelect = false
            }
        }
    }
    func grabPhotos(){
        let imgManager = PHImageManager.default()
        
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode = .highQualityFormat
        
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        //now fetch photos
        if let fetchResult:PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions){
            if fetchResult.count>0{
                for i in 0..<fetchResult.count{
                    imgManager.requestImage(for: fetchResult.object(at: i) , targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFill, options: requestOptions) { (image, error) in
                        self.imageArray.append(image!)
                    }
                }
            }else{
                print("There is no photo")
                self.collectionView.reloadData()
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        
        let imageView = cell.viewWithTag(1) as! UIImageView
        imageView.image = imageArray[indexPath.row]
        
        if cell.isSelected == true{
            cell.backgroundColor = UIColor.orange
        }else{
            cell.backgroundColor = UIColor.clear
        }
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(didPan(toSelectCells:)))
        panGesture.delegate = self
        collectionView.addGestureRecognizer(panGesture)
        
        return cell
    }

    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        _selectedCells.append(imageArray[indexPath.row])
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.borderWidth = 2.0
        cell?.layer.borderColor = UIColor.gray.cgColor
    }
    
    
    
    
}

