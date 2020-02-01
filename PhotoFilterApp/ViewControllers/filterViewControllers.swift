//
//  filterVC.swift
//  PhotoFilterApp
//
//  Created by Tutku Bide on 24.01.2020.
//  Copyright © 2020 Tutku Bide. All rights reserved.
//

import UIKit

class filterViewControllers: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var backButon: UIButton!
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var filterCollectionView: UICollectionView!
    @IBOutlet weak var customizeImageView: UIImageView!
    
    var originalImage : UIImage!
    var selectedIndexPath: IndexPath?
    var context = CIContext()
    var model: [FilterModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buttonView.layer.cornerRadius = 15
        filterCollectionView.register(UINib(nibName: "filterCell", bundle: nil), forCellWithReuseIdentifier: "filterCell")
        setupCV()
        customizeImageView.image = originalImage
        backgroundBlur()
        addFilterVariables()
    }
    
    func setupCV() {
        filterCollectionView.delegate = self
        filterCollectionView.dataSource = self
    }
    
    
    func resizeImage(image: UIImage!, newWidth: CGFloat) -> UIImage {
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    func backgroundBlur() {
        let currentFilter = CIFilter(name: "CIGaussianBlur")
        let beginImage = CIImage(image: self.resizeImage(image: originalImage, newWidth: 1000))
        currentFilter!.setValue(beginImage, forKey: kCIInputImageKey)
        currentFilter!.setValue(10, forKey: kCIInputRadiusKey)
        
        let cropFilter = CIFilter(name: "CICrop")
        cropFilter!.setValue(currentFilter!.outputImage, forKey: kCIInputImageKey)
        cropFilter!.setValue(CIVector(cgRect: beginImage!.extent), forKey: "inputRectangle")
        
        let output = cropFilter!.outputImage
        let cgimg = context.createCGImage(output!, from: output!.extent)
        let processedImage = UIImage(cgImage: cgimg!)
        self.backgroundImageView.image = processedImage
        
    }
    
    func addFilterVariables() {
        
        for i in 0..<filterTypes.count {
            if filterTypes[i] == "Original" {
                self.model.append(FilterModel(name: filterTitle[i], filter: filterTypes[i], image: self.resizeImage(image: originalImage, newWidth: 100)))
            } else {
                let image = self.applyFilterToImage(with: self.resizeImage(image: originalImage, newWidth: 100), filterName: filterTypes[i])
                self.model.append(FilterModel(name: filterTitle[i], filter: filterTypes[i], image: image))
            }
        }
        self.filterCollectionView.reloadData()
    }
    
    func applyFilterToImage(with image: UIImage, filterName: String) -> UIImage {
        let ciContext = CIContext(options: nil)
        let coreImage = CIImage(image: image)
        let filter = CIFilter(name: "\(filterName)" )
        filter!.setDefaults()
        filter!.setValue(coreImage, forKey: kCIInputImageKey)
        let filteredImageData = filter!.value(forKey:kCIOutputImageKey) as! CIImage
        let filteredImageRef = ciContext.createCGImage(filteredImageData, from: filteredImageData.extent)
        let filteredİmage = UIImage(cgImage: filteredImageRef!)
        return filteredİmage
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.model.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = filterCollectionView.dequeueReusableCell(withReuseIdentifier: "filterCell", for: indexPath) as! filterCell
        cell.imageView.image = model[indexPath.row].image
        cell.filterName.text = model[indexPath.row].name
        
        if indexPath.row == 0 {
            
            cell.imageView.image = self.originalImage
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if self.selectedIndexPath?.row ?? -1 >= 0 {
            if let cell = filterCollectionView.cellForItem(at: self.selectedIndexPath!) as? filterCell {
                cell.lineView.isHidden = true
                cell.filterName.textColor = .lightGray
            }
        }
        
        if let cell = filterCollectionView.cellForItem(at: indexPath) as? filterCell {
            
            cell.filterName.textColor = .black
            cell.lineView.isHidden = false
            
            if indexPath.row != 0 {
                self.customizeImageView.image = self.applyFilterToImage(with: originalImage, filterName: self.model[indexPath.row].filter)
            } else {
                self.customizeImageView.image = originalImage
            }
            self.selectedIndexPath = indexPath
        }
        
    }
    
    @IBAction func backButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveButton(_ sender: Any) {
        UIImageWriteToSavedPhotosAlbum(self.originalImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        
        if let error = error {
            let alert = UIAlertController(title: "Kayıt Hatası", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Kayıt!", message: "Fotoğraf film rulosuna kaydedildi!.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
}
