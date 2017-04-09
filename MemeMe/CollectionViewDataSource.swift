//
//  CollectionViewDataSource.swift
//  MemeMe
//
//  Created by Sujal Ghosh on 09/04/17.
//  Copyright © 2017 Sujal. All rights reserved.
//

import UIKit
import CoreData

protocol CollectionViewDataSourceDelegate: class {
  associatedtype Object: NSFetchRequestResult
  associatedtype Cell: UICollectionViewCell
  func configure(_ cell: Cell, for object: Object)
  func showDetail(for object: Object)
}

class CollectionViewDataSource<Delegate: CollectionViewDataSourceDelegate>: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, NSFetchedResultsControllerDelegate {
  typealias Cell = Delegate.Cell
  typealias Object = Delegate.Object
  
  fileprivate weak var delegate: Delegate!
  fileprivate let fetchedResultsController: NSFetchedResultsController<Object>
  fileprivate let collectionView: UICollectionView
  fileprivate let cellIdentifier: String
  
  init(collectionView: UICollectionView, cellIdentifier: String,
       fetchedResultsController:NSFetchedResultsController<Object>,
       delegate: Delegate) {
    self.collectionView = collectionView
    self.cellIdentifier = cellIdentifier
    self.fetchedResultsController = fetchedResultsController
    self.delegate = delegate
    super.init()
    self.fetchedResultsController.delegate = self
    try! fetchedResultsController.performFetch()
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.reloadData()
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    guard let section = fetchedResultsController.sections?[section] else {
      return 0
    }
    return section.numberOfObjects
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let object = fetchedResultsController.object(at: indexPath)
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier:cellIdentifier, for: indexPath) as? Cell
      else { fatalError("Unexpected cell type at \(indexPath)") }
    delegate.configure(cell, for: object)
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let object = fetchedResultsController.object(at: indexPath)
    collectionView.deselectItem(at: indexPath, animated: true)
    delegate.showDetail(for: object)
  }
  
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    collectionView.reloadData()
  }
}
