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


class MemeEditorViewController: UIViewController {
  @IBOutlet weak var topTextField: UITextField!
  @IBOutlet weak var bottomTextField: UITextField!
  @IBOutlet weak var memeImageView: UIImageView!
  
  @IBOutlet weak var cameraBarButtonItem: UIBarButtonItem!
  
  @IBOutlet weak var actionBarButtonItem: UIBarButtonItem!
  @IBOutlet weak var topTextViewTopLayOutConstraint: NSLayoutConstraint!
  @IBOutlet weak var bottomTextFieldBottomLayoutConstraint: NSLayoutConstraint!
  
  var isTopTextFieldEdited: Bool = false
  var isBottomTextFieldEdited: Bool = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let memeTextParagraphStyle:NSMutableParagraphStyle = NSMutableParagraphStyle()
    memeTextParagraphStyle.alignment = .center
    
    let memeTextAttributes:[String:Any] = [
      NSStrokeColorAttributeName: UIColor.black,
      NSStrokeWidthAttributeName: -3.0,
      NSForegroundColorAttributeName: UIColor.white,
      NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
      NSParagraphStyleAttributeName: memeTextParagraphStyle
    ]
    
    topTextField.defaultTextAttributes = memeTextAttributes
    bottomTextField.defaultTextAttributes = memeTextAttributes
    topTextField.text = "TOP"
    bottomTextField.text = "BOTTOM"
    topTextField.delegate = self
    bottomTextField.delegate = self
    actionBarButtonItem.isEnabled = false
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
  
  @IBAction func pickPhoto(_ sender: AnyObject?) {
    checkPhotoLibraryAccessPermission { 
      let status = self.startCameraController(from: self.navigationController!, sourceType: .photoLibrary, delegate: self)
      if !status {
        print("Source type not available")
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
      if let moc = (UIApplication.shared.delegate as? AppDelegate)?.moc
      , let meme = Meme.meme(moc) {
        meme.bottomText = self.bottomTextField.text
        meme.topText = self.topTextField.text
        meme.image = self.memeImageView.image
        meme.memedImage = memedImage
        do {
          try moc.save()
        } catch {
          print(error)
        }
      }
      
    }
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
    if (bottomTextField.isFirstResponder) {
      view.frame.origin.y -= getKeyboardHeight(notification)
    }
  }
  
  func keyboardWillHide(_ notification:Notification) {
    if (bottomTextField.isFirstResponder) {
      self.view.frame.origin.y = 0
    }
  }
  
  func getKeyboardHeight(_ notification:Notification) -> CGFloat {
    let userInfo = notification.userInfo
    let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
    return keyboardSize.cgRectValue.height
  }
  
}

extension MemeEditorViewController {

}


