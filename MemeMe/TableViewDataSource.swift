//
//  MemeListBehaviour.swift
//  MemeMe
//
//  Created by Sujal Ghosh on 26/03/17.
//  Copyright © 2017 Sujal. All rights reserved.
//

import UIKit
import CoreData

protocol TableViewDataSourceDelegate: class {
  associatedtype Object: NSFetchRequestResult
  associatedtype Cell: UITableViewCell
  func configure(_ cell: Cell, for object: Object)
  func showDetail(for object: Object)
}


class TableViewDataSource<Delegate: TableViewDataSourceDelegate>: NSObject, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
  typealias Cell = Delegate.Cell
  typealias Object = Delegate.Object
  
  fileprivate weak var delegate: Delegate!
  fileprivate let fetchedResultsController: NSFetchedResultsController<Object>
  fileprivate let tableView: UITableView
  fileprivate let cellIdentifier: String
  
  init(tableView: UITableView, cellIdentifier: String,
       fetchedResultsController:NSFetchedResultsController<Object>,
       delegate: Delegate) {
    self.tableView = tableView
    self.cellIdentifier = cellIdentifier
    self.fetchedResultsController = fetchedResultsController
    self.delegate = delegate
    super.init()
    self.fetchedResultsController.delegate = self
    try! fetchedResultsController.performFetch()
    tableView.dataSource = self
    tableView.delegate = self
    tableView.reloadData()
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let section = fetchedResultsController.sections?[section] else {
      return 0
    }
    return section.numberOfObjects
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let object = fetchedResultsController.object(at: indexPath)
    guard let cell = tableView.dequeueReusableCell(withIdentifier:cellIdentifier, for: indexPath) as? Cell
      else { fatalError("Unexpected cell type at \(indexPath)") }
    delegate.configure(cell, for: object)
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let object = fetchedResultsController.object(at: indexPath)
    delegate.showDetail(for: object)
  }
  
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    tableView.reloadData()
  }
  
}
