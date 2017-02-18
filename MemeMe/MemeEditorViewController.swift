//
//  MemeEditorViewController.swift
//  MemeMe
//
//  Created by Sujal Ghosh on 31/12/16.
//  Copyright © 2016 Sujal. All rights reserved.
//

import UIKit
import RxSwift
import Photos


fileprivate let photoPermissionObsevable  = Observable<PHAuthorizationStatus>.create { (authStatusObserver) -> Disposable in
  let authStatus = PHPhotoLibrary.authorizationStatus()
  switch authStatus {
  case .authorized, .denied, .restricted:
    authStatusObserver.onNext(authStatus)
    authStatusObserver.onCompleted()
  case .notDetermined:
    PHPhotoLibrary.requestAuthorization { authStatus in
      authStatusObserver.onNext(authStatus)
      authStatusObserver.onCompleted()
    }
  }
  return Disposables.create()
}

class MemeEditorViewController: UIViewController {
  @IBOutlet weak var topTextField: UITextField!
  @IBOutlet weak var bottomTextField: UITextField!
  @IBOutlet weak var memeImageView: UIImageView!
  
  @IBOutlet weak var cameraBarButtonItem: UIBarButtonItem!
  
  
  var isTopTextFieldEdited: Bool = false
  var isBottomTextFieldEdited: Bool = false
  
  let photoPermissionStatus = Variable(PHAuthorizationStatus.notDetermined)
  
  let disposeBag = DisposeBag()
  
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
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    if !UIImagePickerController.isSourceTypeAvailable(.camera) {
      cameraBarButtonItem.isEnabled = false
    }
    
    photoPermissionStatus.asObservable().subscribe(onNext: { [weak self] authStatus in
      switch authStatus {
      case .denied:
        self?.showPhotoLibraryAccessErrorAlert(stataus: authStatus)
      case .restricted:
        self?.showPhotoLibraryAccessErrorAlert(stataus: authStatus)
      default: break
      }
    }).addDisposableTo(disposeBag)
    
    photoPermissionObsevable.subscribe(onNext: { [weak self] authStatus in
      self?.photoPermissionStatus.value = authStatus
    }).addDisposableTo(disposeBag)
  }
  
  
  @IBAction func pickPhoto(_ sender: AnyObject?) {
    let status = startCameraController(from: navigationController!, sourceType: .photoLibrary, delegate: self)
    if !status {
      
    }
  }
  
  
}


extension MemeEditorViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func showPhotoLibraryAccessErrorAlert(stataus: PHAuthorizationStatus) {
    
  }
  
  func showCameraAccessErrorAlert(stataus: PHAuthorizationStatus) {
    
  }
  
  func startCameraController(from: UIViewController, sourceType:UIImagePickerControllerSourceType, delegate: UIImagePickerControllerDelegate & UINavigationControllerDelegate) -> Bool {
    guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
      return false
    }
    let imagePickerController = UIImagePickerController()
    imagePickerController.sourceType = sourceType
    imagePickerController.delegate = delegate
    imagePickerController.allowsEditing = true
    from.show(imagePickerController, sender: self)
    return true
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    memeImageView.image = info[UIImagePickerControllerEditedImage] as? UIImage
    picker.dismiss(animated: true, completion: nil)
  }
}

extension MemeEditorViewController: UITextFieldDelegate {
  func textFieldDidBeginEditing(_ textField: UITextField) {
    if (!isTopTextFieldEdited && textField == topTextField)
    || (!isBottomTextFieldEdited && textField == bottomTextField) {
      textField.text = nil
    }
  }
}

