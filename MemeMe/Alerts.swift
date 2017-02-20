//
//  Alerts.swift
//  Pitch Perfect
//
//  Created by Sujal Ghosh on 25/12/16.
//  Copyright © 2016 Sujal. All rights reserved.
//

import UIKit

struct Alerts {
  static let DismissTitle = "Dismiss"
  static let ErrorTitle = "Error"
}

//Photo permissions
extension Alerts {
  static let PhotoPermissionAlertDenied = "Please enable photo library access from device settings."
  static let PhotoPermissionAlertRestricted = "You do not have access permission to photo library."
}


extension Alerts {
  static func showAlert(_ title: String, message: String, presentingViewController: UIViewController) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: Alerts.DismissTitle, style: .default, handler: nil))
    presentingViewController.present(alert, animated: true, completion: nil)
  }
}
