//
//  ImageViewController.swift
//  Cassini
//
//  Created by iMac21.5 on 4/23/15. from EditWaypointViewController.swift (Trax)
//  Copyright (c) 2015 Garth MacKenzie. All rights reserved.
//

import UIKit
import AssetsLibrary
import MobileCoreServices

class ImageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var image: UIImage? { // a computed property instead of func
        get { return imageView.image }
        set {
            if let image = newValue {
                imageView = UIImageView(image: image)
                imageView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: image.size)
            }
        }
    }
    // MARK: Image/Camera
    var tag: Int = 0
    var imageView = UIImageView()
    @IBOutlet weak var imageViewContainer: UIView! {
        didSet { imageViewContainer.addSubview(imageView) } }
    
    @IBAction func takePhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            let picker = UIImagePickerController()
            picker.sourceType = .Camera
            //if video check media types
            picker.mediaTypes = [kUTTypeImage]
            picker.delegate = self
            picker.allowsEditing = true
            presentViewController(picker, animated: true, completion: nil)
        }
    }
    // MARK: UIImagePickerControllerDelegate, UINavigationControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        var image = info[UIImagePickerControllerEditedImage] as? UIImage
        if image == nil {
            image = info[UIImagePickerControllerOriginalImage] as? UIImage
        }
        imageView.image = image
        makeRoomForImage()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func savePhoto(sender: UIBarButtonItem) {
        if let imageData = UIImageJPEGRepresentation(image, 1.0) {
            let library = ALAssetsLibrary()
            library.writeImageDataToSavedPhotosAlbum(imageData, metadata: nil, completionBlock: nil)
        }
    }

    @IBAction func back(sender: AnyObject) {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func makeRoomForImage() {
        var extraHeight: CGFloat = 0
        if imageView.image?.aspectRatio > 0 {
            if let width = imageView.superview?.frame.size.width {
                let height = width / imageView.image!.aspectRatio
                extraHeight = height - imageView.frame.height
                imageView.frame = CGRect(x: 0, y: 0, width: width, height: height)
            }
        } else {
            extraHeight = -imageView.frame.height
            imageView.frame = CGRectZero
        }
        preferredContentSize = CGSize(width: preferredContentSize.width, height: preferredContentSize.height + extraHeight)
    }
}

extension UIImage {
    var aspectRatio: CGFloat {
        return size.height != 0 ? size.width / size.height : 0
    }
    static func emptyImage(size: CGSize, scale: CGFloat = UIScreen.mainScreen().scale) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}


