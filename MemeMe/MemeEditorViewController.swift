//
//  MemeEditorViewController.swift
//  MemeMe
//
//  Created by Sujal Ghosh on 31/12/16.
//  Copyright © 2016 Sujal. All rights reserved.
//

import UIKit
import Photos
import AVFoundation
import CoreData


class MemeEditorViewController: UIViewController {
  
  var topText: String?
  var bottomText: String?
  var memeOrigImage: UIImage?
  
  @IBOutlet weak var topTextField: UITextField!
  @IBOutlet weak var bottomTextField: UITextField!
  @IBOutlet weak var memeImageView: UIImageView!
  
  @IBOutlet weak var cameraBarButtonItem: UIBarButtonItem!
  
  @IBOutlet weak var actionBarButtonItem: UIBarButtonItem!
  @IBOutlet weak var topTextViewTopLayOutConstraint: NSLayoutConstraint!
  @IBOutlet weak var bottomTextFieldBottomLayoutConstraint: NSLayoutConstraint!
  @IBOutlet weak var cancelBarButtonItem: UIBarButtonItem!

  var enableCancelButton = true
  var enableShareButton = false
  
  
  let memeTextAttributes:[String:Any] = {
    let memeTextParagraphStyle:NSMutableParagraphStyle = NSMutableParagraphStyle()
    memeTextParagraphStyle.alignment = .center
    return [
      NSStrokeColorAttributeName: UIColor.black,
      NSStrokeWidthAttributeName: -3.0,
      NSForegroundColorAttributeName: UIColor.white,
      NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
      NSParagraphStyleAttributeName: memeTextParagraphStyle
    ]
  }()
  
  var isTopTextFieldEdited: Bool = false
  var isBottomTextFieldEdited: Bool = false

  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    prepareTextFields(topTextField, defaultText: (topText != nil) ? topText!: "TOP")
    prepareTextFields(bottomTextField, defaultText: (bottomText != nil) ? bottomText!: "BOTTOM")
    
    if let memeOrigImage = memeOrigImage {
      memeImageView.image = memeOrigImage
    }
    
    actionBarButtonItem.isEnabled = enableShareButton
    cancelBarButtonItem.isEnabled = enableCancelButton
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    if !UIImagePickerController.isSourceTypeAvailable(.camera) {
      cameraBarButtonItem.isEnabled = false
    }
    
    let photoLibraryPermissionStatus = PHPhotoLibrary.authorizationStatus()
    if (photoLibraryPermissionStatus == .notDetermined) {
      PHPhotoLibrary.requestAuthorization({ _ in
        self.checkPhotoLibraryAccessPermission(nil)
      })
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    subscribeToKeyboardNotifications()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    unsubscribeFromKeyboardNotifications()
  }
  
  override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
    if (traitCollection.verticalSizeClass != newCollection.verticalSizeClass)
      || (traitCollection.horizontalSizeClass != newCollection.horizontalSizeClass) {
      coordinator.animate(alongsideTransition: { (_) in
        self.adjustTextField()
      }, completion: { (_) in
        self.adjustTextField()
      })
    }
  }
  
  @IBAction func pickPhoto(_ sender: UIBarButtonItem?) {
    if (sender?.tag == 0) {
      let status = self.startCameraController(from: self, sourceType: .camera, delegate: self)
      if !status {
        print("Source type not available")
      }
    } else {
      checkPhotoLibraryAccessPermission {
        let status = self.startCameraController(from: self, sourceType: .photoLibrary, delegate: self)
        if !status {
          print("Source type not available")
        }
      }
    }
  }
  
  @IBAction func activityBarButtonItemAction(_ sender: AnyObject?) {
    guard let memedImage = generateMemeImage() else {
      return
    }
    let activityViewController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
    navigationController?.present(activityViewController, animated: true, completion: nil)
    activityViewController.completionWithItemsHandler = {
      _, isCompleted, returnedItems, activityError in
      if let activityError = activityError {
        print (activityError)
        return
      }
      if !isCompleted {
        return
      }
      
      DispatchQueue.global(qos: .userInitiated).async {
        if let originalImage = self.memeImageView.image,
        let memedImageThumbnail = UIImage.generatePhotoThumbnail(image: memedImage),
        let moc = (UIApplication.shared.delegate as? AppDelegate)?.moc,
        let meme = Meme.meme(moc) {
          meme.bottomText = self.bottomTextField.text
          meme.topText = self.topTextField.text
          meme.memedImageThumbnail = memedImageThumbnail
          meme.timeStamp = Date()
          meme.saveImages(originalImage: originalImage, memedImage: memedImage,
                          memedImageThumbnail: memedImageThumbnail, timeStamp: meme.timeStamp!)
          moc.perform {
            do {
              try moc.save()
            } catch {
              print (error)
            }
          }
        }
      }
      self.dismiss(animated: true, completion: nil)
    }
  }
  
  @IBAction func cancelBarButtonItemAction(_ sender: AnyObject?) {
    dismiss(animated: true, completion: nil)
  }
  
  
  func imageRectOf(_ imageView: UIImageView ) -> CGRect? {
    /*
     Ref: http://stackoverflow.com/a/29944216/754112
     */
    guard let aspectRatio = memeImageView.image?.size else {
      return nil
    }
    return AVMakeRect(aspectRatio: aspectRatio, insideRect: memeImageView.bounds)
  }
  
  func adjustTextField() {
    guard let imageRect = imageRectOf(memeImageView) else {
      return
    }
    topTextViewTopLayOutConstraint.constant = imageRect.origin.y + 4.0
    bottomTextFieldBottomLayoutConstraint.constant = memeImageView.bounds.size.height - imageRect.origin.y - imageRect.size.height + 4.0
  }
  
  func generateMemeImage() -> UIImage? {
    guard let memeImage = memeImageView.image
    , let memeImageRect = imageRectOf(memeImageView) else {
      return nil
    }

    let r = UIGraphicsImageRenderer(size: memeImage.size)
    let im = r.image { _ in
      let hscale = memeImage.size.height / memeImageRect.size.height
      memeImage.draw(at: CGPoint(x: 0.0, y: 0.0))
      
      var topTextRect = topTextField.frame
      topTextRect.origin.y = 4.0 * hscale
      topTextRect.origin.x = 0
      topTextRect.size = memeImage.size
      
      var bottomTextRect = bottomTextField.frame
      bottomTextRect.origin.y = (memeImageRect.size.height - bottomTextRect.size.height - 4.0) * hscale
      bottomTextRect.origin.x = 0
      bottomTextRect.size = memeImage.size
      
      var attribute = topTextField.defaultTextAttributes;
      if let font = attribute[NSFontAttributeName] as? UIFont {
        let font1 = font.withSize(font.pointSize * hscale)
        attribute[NSFontAttributeName] = font1
      }

      topTextField.text?.draw(in: topTextRect, withAttributes: attribute)
      
      var attribute2 = bottomTextField.defaultTextAttributes;
      if let font = attribute2[NSFontAttributeName] as? UIFont {
        let font1 = font.withSize(font.pointSize * hscale)
        attribute2[NSFontAttributeName] = font1
      }
      
      bottomTextField.text?.draw(in: bottomTextRect, withAttributes: attribute2)
    }
    return im
  }
  
  func prepareTextFields (_ textField:UITextField, defaultText: String) {
    textField.defaultTextAttributes = memeTextAttributes
    textField.text = defaultText
    textField.delegate = self
  }
}

extension MemeEditorViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func checkPhotoLibraryAccessPermission(_ completion:(()-> Void)?) {
    let photoLibraryPermissionStatus = PHPhotoLibrary.authorizationStatus()
    switch photoLibraryPermissionStatus {
    case .denied:
      if let navigationController = navigationController {
        Alerts.showAlert(Alerts.ErrorTitle, message: Alerts.PhotoPermissionAlertDenied, presentingViewController: navigationController)
      }
    case .restricted:
      if let navigationController = navigationController {
        Alerts.showAlert(Alerts.ErrorTitle, message: Alerts.PhotoPermissionAlertRestricted, presentingViewController: navigationController)
      }
    case .authorized:
      completion?()
    default:
      break
    }
  }
  
  func startCameraController(from: UIViewController, sourceType:UIImagePickerControllerSourceType, delegate: UIImagePickerControllerDelegate & UINavigationControllerDelegate) -> Bool {
    guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
      return false
    }
    let imagePickerController = UIImagePickerController()
    imagePickerController.sourceType = sourceType
    imagePickerController.delegate = delegate
    from.show(imagePickerController, sender: self)
    return true
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    memeImageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
    actionBarButtonItem.isEnabled = true
    adjustTextField()
    picker.dismiss(animated: true, completion:nil)
  }
}

extension MemeEditorViewController: UITextFieldDelegate {
  func textFieldDidBeginEditing(_ textField: UITextField) {
    if (!isTopTextFieldEdited && textField == topTextField) {
      isTopTextFieldEdited = true
      textField.text = nil
    } else if (!isBottomTextFieldEdited && textField == bottomTextField) {
      isBottomTextFieldEdited = true
      textField.text = nil
    }
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
}

extension MemeEditorViewController {
  func subscribeToKeyboardNotifications() {
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
  }
  
  func unsubscribeFromKeyboardNotifications() {
    NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
    NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
  }
  
  func keyboardWillShow(_ notification:Notification) {
    view.frame.origin.y = getKeyboardHeight(notification) * (-1)
  }
  
  func keyboardWillHide(_ notification:Notification) {
    view.frame.origin.y = 0
  }
  
  func getKeyboardHeight(_ notification:Notification) -> CGFloat {
    let userInfo = notification.userInfo
    let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
    if bottomTextField.isFirstResponder {
      return keyboardSize.cgRectValue.height
    } else {
      return 0
    }
  }
}


