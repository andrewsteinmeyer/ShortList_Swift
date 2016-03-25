//
//  FetchedResultsCollectionViewDataSource.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 3/22/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//

import UIKit
import CoreData

@objc public protocol FetchedResultsCollectionViewDataSourceDelegate: NSObjectProtocol {
  optional func dataSource(dataSource: FetchedResultsCollectionViewDataSource, didFailWithError error: NSError)
  optional func dataSource(dataSource: FetchedResultsCollectionViewDataSource, cellReuseIdentifierForObject object: NSManagedObject, atIndexPath indexPath: NSIndexPath) -> String
  optional func dataSource(dataSource: FetchedResultsCollectionViewDataSource, configureCell cell: UICollectionViewCell, forObject object: NSManagedObject, atIndexPath indexPath: NSIndexPath)
  optional func dataSource(dataSource: FetchedResultsCollectionViewDataSource, deleteObject object: NSManagedObject, atIndexPath indexPath: NSIndexPath)
}

public class FetchedResultsCollectionViewDataSource: FetchedResultsDataSource, UICollectionViewDataSource {
  weak var collectionView: UICollectionView!
  weak var delegate: FetchedResultsCollectionViewDataSourceDelegate?
  
  init(collectionView: UICollectionView, fetchedResultsController: NSFetchedResultsController) {
    self.collectionView = collectionView
    
    super.init(fetchedResultsController: fetchedResultsController)
  }
  
  override func didFailWithError(error: NSError) {
    delegate?.dataSource?(self, didFailWithError: error)
  }
  
  // MARK: - UICollectionViewDataSource
  
  public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return numberOfSections
  }
  
  public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return numberOfItemsInSection(section)
  }
  
  public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let object = objectAtIndexPath(indexPath)
    let reuseIdentifier = cellReuseIdentifierForObject(object, atIndexPath: indexPath)
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath)
    configureCell(cell, forObject: object, atIndexPath: indexPath)
    return cell
  }
  
  //TODO: Handle delete of Collection View Cell
  
  /*
  public func collectionView(collectionView: UICollectionView, commitEditingStyle editingStyle: UICollectionViewEd, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
      let object = objectAtIndexPath(indexPath)
      delegate?.dataSource?(self, deleteObject: object, atIndexPath: indexPath)
    }
  }
  */
  
  // MARK: Cell Configuration
  
  func cellReuseIdentifierForObject(object: NSManagedObject, atIndexPath indexPath: NSIndexPath) -> String {
    return delegate?.dataSource?(self, cellReuseIdentifierForObject: object, atIndexPath: indexPath) ?? "Cell"
  }
  
  func configureCell(cell: UICollectionViewCell, forObject object: NSManagedObject, atIndexPath indexPath: NSIndexPath) {
    delegate?.dataSource?(self, configureCell: cell, forObject: object, atIndexPath: indexPath)
  }
  
  // MARK: - Change Notification
  
  override func reloadData() {
    collectionView.reloadData()
  }
  
  override func didChangeContent(changes: [ChangeDetail]) {
    // Don't perform incremental updates when the collection view is not currently visible
    if collectionView.window == nil {
      reloadData()
      return;
    }
    
    collectionView?.performBatchUpdates({
    
    for change in changes {
      switch(change) {
      case .SectionInserted(let sectionIndex):
        self.collectionView.insertSections(NSIndexSet(index: sectionIndex))
      case .SectionDeleted(let sectionIndex):
        self.collectionView.deleteSections(NSIndexSet(index: sectionIndex))
      case .ObjectInserted(let newIndexPath):
        self.collectionView.insertItemsAtIndexPaths([newIndexPath])
      case .ObjectDeleted(let indexPath):
        self.collectionView.deleteItemsAtIndexPaths([indexPath])
      case .ObjectUpdated(let indexPath):
      if let cell = self.collectionView.cellForItemAtIndexPath(indexPath) {
          let object = self.objectAtIndexPath(indexPath)
          self.configureCell(cell, forObject: object, atIndexPath: indexPath)
        }
      case .ObjectMoved(let indexPath, let newIndexPath):
        self.collectionView.moveItemAtIndexPath(indexPath, toIndexPath: newIndexPath)
      }
    }
    
    }, completion: nil)
  }
  
  // MARK: - Selection
  
  
  var selectedObject: NSManagedObject? {
    if let selectedIndexPaths = collectionView.indexPathsForSelectedItems() {
      return objectAtIndexPath(selectedIndexPaths.first!)
    } else {
      return nil
    }
  }
}
