//
//  MemeDetailViewController.swift
//  MemeMe
//
//  Created by Sujal Ghosh on 09/04/17.
//  Copyright © 2017 Sujal. All rights reserved.
//

import UIKit

class MemeDetailViewController: UIViewController {
  var meme: Meme!
  @IBOutlet weak var memeImageView: UIImageView!
  override func viewDidLoad() {
    memeImageView.image = meme.memedImage
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editMeme(_:)))
    super.viewDidLoad()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    navigationController?.tabBarController?.tabBar.isHidden = true
    super.viewWillAppear(animated)
  }
  
  func editMeme(_ sender: Any?) {
    let storyBoard = UIStoryboard(name: "Main", bundle: nil)
    let memeEditorNavViewController = storyBoard.instantiateViewController(withIdentifier: "MemeEditorViewControllerSBID") as! UINavigationController
    let memeEditorViewController = memeEditorNavViewController.topViewController as! MemeEditorViewController
    memeEditorViewController.topText = meme.topText
    memeEditorViewController.bottomText = meme.bottomText
    memeEditorViewController.memeOrigImage = meme.originalImage
    memeEditorViewController.enableShareButton = true
    self.navigationController?.present(memeEditorNavViewController, animated: true, completion: nil)
    self.navigationController?.popViewController(animated: false)
  }
  
}
