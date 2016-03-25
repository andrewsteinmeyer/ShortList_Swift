//
//  FetchedResultsCollectionViewController.swift
//  ShortList
//
//  Created by Andrew Steinmeyer on 3/22/16.
//  Copyright © 2016 Andrew Steinmeyer. All rights reserved.
//


import UIKit
import CoreData

class FetchedResultsCollectionViewController: UICollectionViewController, ContentLoading, SubscriptionLoaderDelegate, FetchedResultsCollectionViewDataSourceDelegate {
  // MARK: - Lifecycle
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
  
  // MARK: - Model
  
  var managedObjectContext: NSManagedObjectContext!
  
  func saveManagedObjectContext() {
    var error: NSError?
    do {
      try managedObjectContext!.save()
    } catch let error1 as NSError {
      error = error1
      print("Encountered error saving managed object context: \(error)")
    }
  }
  
  // MARK: - View Lifecyle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    updatePlaceholderView()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    loadContentIfNeeded()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    placeholderView?.frame = collectionView!.bounds
  }
  
  // MARK: - Content Loading
  
  private(set) var contentLoadingState: ContentLoadingState = .Initial  {
    didSet {
      if isViewLoaded() {
        updatePlaceholderView()
      }
    }
  }
  
  var isContentLoaded: Bool {
    switch contentLoadingState {
    case .Loaded:
      return true
    default:
      return false
    }
  }
  
  private(set) var needsLoadContent: Bool = true
  
  func setNeedsLoadContent() {
    needsLoadContent = true
    if isViewLoaded() {
      loadContentIfNeeded()
    }
  }
  
  func loadContentIfNeeded() {
    if needsLoadContent {
      loadContent()
    }
  }
  
  func loadContent() {
    needsLoadContent = false
    
    subscriptionLoader = SubscriptionLoader()
    subscriptionLoader!.delegate = self
    
    configureSubscriptionLoader(subscriptionLoader!)
    
    subscriptionLoader!.whenReady { [weak self] in
      self?.setUpDataSource()
      self?.contentLoadingState = .Loaded
    }
    
    if !subscriptionLoader!.isReady {
      if Meteor.connectionStatus == .Offline {
        contentLoadingState = .Offline
      } else {
        contentLoadingState = .Loading
      }
    }
  }
  
  func resetContent() {
    dataSource = nil
    collectionView!.dataSource = nil
    collectionView!.reloadData()
    subscriptionLoader = nil
    contentLoadingState = .Initial
  }
  
  private var subscriptionLoader: SubscriptionLoader?
  
  func configureSubscriptionLoader(subscriptionLoader: SubscriptionLoader) {
  }
  
  var dataSource: FetchedResultsCollectionViewDataSource!
  
  func setUpDataSource() {
    if let fetchedResultsController = createFetchedResultsController() {
      dataSource = FetchedResultsCollectionViewDataSource(collectionView: collectionView!, fetchedResultsController: fetchedResultsController)
      dataSource.delegate = self
      collectionView!.dataSource = dataSource
      dataSource.performFetch()
    }
  }
  
  func createFetchedResultsController() -> NSFetchedResultsController? {
    return nil
  }
  
  // MARK: SubscriptionLoaderDelegate
  
  func subscriptionLoader(subscriptionLoader: SubscriptionLoader, subscription: METSubscription, didFailWithError error: NSError) {
    contentLoadingState = .Error(error)
  }
  
  // MARK: Connection Status Notification
  
  func connectionStatusDidChange() {
    if !isContentLoaded && Meteor.connectionStatus == .Offline {
      contentLoadingState = .Offline
    }
  }
  
  // MARK: - Placeholder View
  
  private var placeholderView: PlaceholderView?
  
  func updatePlaceholderView() {
    if isContentLoaded {
      if placeholderView != nil {
        placeholderView?.removeFromSuperview()
        placeholderView = nil
      }
    } else {
      if placeholderView == nil {
        placeholderView = PlaceholderView()
        collectionView!.addSubview(placeholderView!)
      }
    }
    
    switch contentLoadingState {
    case .Loading:
      placeholderView?.showLoadingIndicator()
    case .Offline:
      placeholderView?.showTitle("Could not establish connection to server", message: nil)
    case .Error(let error):
      placeholderView?.showTitle(error.localizedDescription, message: error.localizedFailureReason)
    default:
      break
    }
  }
  
  // MARK: - FetchedResultsCollectionViewDataSourceDelegate
  
  func dataSource(dataSource: FetchedResultsCollectionViewDataSource, didFailWithError error: NSError) {
    print("Data source encountered error: \(error)")
  }
}
