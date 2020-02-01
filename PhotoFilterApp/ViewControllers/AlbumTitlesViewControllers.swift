//
//  ViewController.swift
//  PhotoFilterApp
//
//  Created by Tutku Bide on 19.01.2020.
//  Copyright © 2020 Tutku Bide. All rights reserved.
//

import UIKit
import Photos

class AlbumTitlesViewControllers: UIViewController {
    
    @IBOutlet weak var albumTitleCollectionView: UICollectionView!
    @IBOutlet weak var galleryCollectionView: UICollectionView!
    @IBOutlet weak var albumTitleView: UIView!
    @IBOutlet weak var galleryView: UIView!
    @IBOutlet weak var cornerView: UIView!
    
    var selectedIndex: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        PHPhotoLibrary.requestAuthorization { (status) in
            switch status {
            case .notDetermined:
                print("izin yok")
            case .authorized:
                DispatchQueue.main.async {
                    self.fetchPhotos()
                    self.cornerRadius()
                }
            case .denied:
                DispatchQueue.main.async {
                    self.makeAlert()
                }
                print("reddilmiş")
            case .restricted: break
            default: break
            }
        }
        setupCollectionViews()
    }
    
    
    
    func cornerRadius() {
        galleryCollectionView.layer.cornerRadius = 20
        cornerView.layer.cornerRadius = 20
        galleryView.layer.cornerRadius = 20
       
        
        
    }
    
    func setupCollectionViews() {
        galleryCollectionView.delegate = self
        galleryCollectionView.dataSource = self
        albumTitleCollectionView.register(UINib(nibName: "albumTitleCell", bundle: nil), forCellWithReuseIdentifier: "albumTCell")
        galleryCollectionView.register(UINib(nibName: "galleryCell", bundle: nil), forCellWithReuseIdentifier: "photoGalleryCell")
    }
    
    
    func makeAlert() {
        let alert = UIAlertController(title: "Galeriye ulaşmak için izin gerekiyor.", message: "Ayarlara Git", preferredStyle: UIAlertController.Style.alert)
        let button = UIAlertAction(title: "Ayarlar", style: UIAlertAction.Style.default) { (UIAlertAction) in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: {(success)in
                    print("Ayarlar açıldı: \(success)")
                    
                })
            }
        }
        alert.addAction(button)
        self.present(alert, animated: true, completion: nil)
    }
    
    func fetchPhotos() {
        PhotoAlbumManager.shared.fetchAlbums()
        PhotoAlbumManager.shared.getPhotos(with: PhotoAlbumManager.shared.titleArray[0])
        self.albumTitleCollectionView.reloadData()
        self.galleryCollectionView.reloadData()
        
    }
}

extension AlbumTitlesViewControllers: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == galleryCollectionView {
            return PhotoAlbumManager.shared.imageArray.count
        }
        return PhotoAlbumManager.shared.titleArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let galleryCell = galleryCollectionView.dequeueReusableCell(withReuseIdentifier: "photoGalleryCell", for: indexPath) as! galleryCell
        galleryCell.imageView.image = PhotoAlbumManager.shared.imageArray[indexPath.row]
        
        if (collectionView == albumTitleCollectionView) {
            let albumCell = albumTitleCollectionView.dequeueReusableCell(withReuseIdentifier: "albumTCell", for: indexPath) as! albumTitleCell
            albumCell.titleLabel.text = PhotoAlbumManager.shared.titleArray[indexPath.row]
            
            if indexPath.row == 0 {
                albumCell.lineView.isHidden = false
            }else {
                albumCell.lineView.isHidden = true
            }
            return albumCell
        }
        return galleryCell
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == albumTitleCollectionView  {
            
            if self.selectedIndex?.row ?? -1 >= 0 {
                if let cell = albumTitleCollectionView.cellForItem(at: self.selectedIndex!) as? albumTitleCell {
                    cell.lineView.isHidden = true
                    cell.titleLabel.textColor = .lightGray
                }
            }
            
            if let cell = albumTitleCollectionView.cellForItem(at: indexPath) as? albumTitleCell {
                cell.lineView.isHidden = false
                cell.titleLabel.textColor = .white
                self.selectedIndex = indexPath
            }
            PhotoAlbumManager.shared.getPhotos(with: PhotoAlbumManager.shared.titleArray[indexPath.row])
            self.galleryCollectionView.reloadData()
            
        }
        
        if collectionView == galleryCollectionView {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let imageCustomVC = storyboard.instantiateViewController(withIdentifier: "filterVC") as! filterViewControllers
            imageCustomVC.originalImage = PhotoAlbumManager.shared.imageArray[indexPath.row]
            self.navigationController?.pushViewController(imageCustomVC, animated: true)
        }
    }
    
}






