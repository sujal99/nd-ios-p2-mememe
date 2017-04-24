//
//  MemeListViewController.swift
//  MemeMe
//
//  Created by Sujal Ghosh on 31/12/16.
//  Copyright © 2016 Sujal. All rights reserved.
//

import UIKit
import CoreData

class AllMemeTableViewController: UITableViewController {
  var moc: NSManagedObjectContext?
  var dataSource: TableViewDataSource<AllMemeTableViewController>!
  var sentMemeViewNavigationBehavior: SentMemeViewNavigationBehavior!

  override func viewDidLoad() {
    super.viewDidLoad()
    sentMemeViewNavigationBehavior = SentMemeViewNavigationBehavior(with: self)

    
    guard let moc = (UIApplication.shared.delegate as? AppDelegate)?.moc else {
      fatalError("Moc Unavailable.")
    }
    
    let request = Meme.sortedFetchRequest()
    let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
    dataSource = TableViewDataSource(tableView: tableView, cellIdentifier: "AllMemeTableViewCell", fetchedResultsController: frc, delegate: self)
  }
  override func viewWillAppear(_ animated: Bool) {
    navigationController?.tabBarController?.tabBar.isHidden = false
    super.viewWillAppear(animated)
  }
  
}

extension AllMemeTableViewController: TableViewDataSourceDelegate {
  func configure(_ cell: AllMemeTableViewCell, for object: Meme) {
    cell.memeImageView?.image = object.memedImageThumbnail
    if let topText = object.topText, let bottomText = object.bottomText {
      cell.memeTextLabel?.text = topText + "..." + bottomText
    }
  }
  
  func showDetail(for object: Meme) {
    sentMemeViewNavigationBehavior.showMeme(object)
  }
  
}
