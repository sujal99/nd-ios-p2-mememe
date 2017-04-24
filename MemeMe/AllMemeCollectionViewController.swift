//
//  AllMemeCollectionViewController.swift
//  MemeMe
//
//  Created by Sujal Ghosh on 09/04/17.
//  Copyright © 2017 Sujal. All rights reserved.
//

import UIKit
import CoreData

class AllMemeCollectionViewController: UICollectionViewController {
  var moc: NSManagedObjectContext?
  var dataSource: CollectionViewDataSource<AllMemeCollectionViewController>!
  var sentMemeViewNavigationBehavior: SentMemeViewNavigationBehavior!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    sentMemeViewNavigationBehavior = SentMemeViewNavigationBehavior(with: self)
    guard let moc = (UIApplication.shared.delegate as? AppDelegate)?.moc else {
      fatalError("Moc Unavailable.")
    }
    
    let request = Meme.sortedFetchRequest()
    let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
    dataSource = CollectionViewDataSource(collectionView: collectionView!, cellIdentifier: "AllMemeCollectionViewCell", fetchedResultsController: frc, delegate: self)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    navigationController?.tabBarController?.tabBar.isHidden = false
    super.viewWillAppear(animated)
  }
  
}

extension AllMemeCollectionViewController: CollectionViewDataSourceDelegate {
  func configure(_ cell: AllMemeCollectionViewCell, for object: Meme) {
    cell.memeImageView?.image = object.memedImageThumbnail
  }
  
  func showDetail(for object: Meme) {
    sentMemeViewNavigationBehavior.showMeme(object)
  }
  
}
