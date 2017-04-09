//
//  SentMemeViewController.swift
//  MemeMe
//
//  Created by Sujal Ghosh on 13/03/17.
//  Copyright © 2017 Sujal. All rights reserved.
//

import UIKit    

class SentMemeViewNavigationBehavior: NSObject {
  let viewController: UIViewController
  let storyBoard = UIStoryboard(name: "Main", bundle: nil)
  init(with viewController: UIViewController) {
    self.viewController = viewController
    super.init()
    addNavigationItems()
  }
  
  func addNavigationItems() {
    viewController.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addMemeAction(_:)))
    viewController.navigationItem.title = "Sent Memes"
  }
  
  func addMemeAction(_ sender: Any?) {
    let memeEditorViewController = storyBoard.instantiateViewController(withIdentifier: "MemeEditorViewControllerSBID")
    viewController.present(memeEditorViewController, animated: true, completion: nil)
  }
  
  func showMeme(_ meme: Meme){
    let memeDeatilViewController = storyBoard.instantiateViewController(withIdentifier: "MemeDetailViewController") as! MemeDetailViewController
    memeDeatilViewController.meme = meme
    viewController.navigationController?.pushViewController(memeDeatilViewController, animated: true)
  }
}
