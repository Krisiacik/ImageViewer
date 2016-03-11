//
//  GalleryCollectionViewController.swift
//  ImageViewer
//
//  Created by Kristian Angyal on 10/03/2016.
//  Copyright © 2016 MailOnline. All rights reserved.
//

import UIKit

public extension UIViewController {
    
    public func presentCollectionImageGallery(gallery: GalleryCollectionViewController, completion: (Void -> Void)? = {}) {
        presentViewController(gallery, animated: true, completion: completion)
    }
}

public class GalleryCollectionViewController: UIViewController, UIViewControllerTransitioningDelegate, ImageViewControllerDelegate {
    
    //DATA
    private let viewModel: GalleryViewModel
    private let collectionView: UICollectionView
    private var collectionViewDelegate = GalleryCollectionViewDelegate()
    private var collectionViewDataSource: GalleryCollectionViewDataSource!
    
    //LOCAL CONFIGURATION
    private let presentTransitionDuration = 0.25
    
    //TRANSITIONS
    let presentTransition: GalleryPresentTransition
    
    init(viewModel: GalleryViewModel) {
        
        self.viewModel = viewModel
        self.collectionView = UICollectionView(frame: UIScreen.mainScreen().bounds, collectionViewLayout: GalleryCollectionViewFlowLayout())
        self.presentTransition = GalleryPresentTransition(duration: presentTransitionDuration, displacedView: self.viewModel.displacedView)
        
        /****************************************************/ super.init(nibName: nil, bundle: nil)
        
        collectionViewDataSource = GalleryCollectionViewDataSource(viewModel: viewModel, imageControllerDelegate: self)
        
        configure()
        configureCollectionView()
        createViewHierarchy()
    }
    
    func configure() {
        
        self.modalPresentationStyle = .Custom
        self.transitioningDelegate = self
    }
    
    func configureCollectionView() {
        
        collectionView.delegate = self.collectionViewDelegate
        collectionView.dataSource = self.collectionViewDataSource
        
        collectionView.pagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        
        collectionView.decelerationRate = UIScrollViewDecelerationRateFast
        
        self.collectionView.bounds = self.view.bounds
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.collectionView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        self.collectionView.registerClass(GalleryCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
    }
    
    func createViewHierarchy() {
        
        self.view.addSubview(collectionView)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.blackColor()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    public override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        print("TRANSITION")
        
        collectionViewDelegate.updatedSize = size
        
        let visibleIndexPaths = self.collectionView.indexPathsForVisibleItems()
        print(visibleIndexPaths.first?.row)
        let newHorizontalOffset = CGFloat(visibleIndexPaths.first!.row) * size.width
        let newContentOffset = CGPoint(x: newHorizontalOffset, y: 0)
        
        coordinator.animateAlongsideTransition({ coordinatorContext in
            
            self.collectionView.setContentOffset(newContentOffset, animated: false)
            self.collectionView.performBatchUpdates({ () -> Void in
                
                }, completion: { (finished) -> Void in
            })
            }) { coordinatorContext in
                
                print("CONTENTSIZE \(self.collectionView.contentSize)")
        }
    }
    
    public func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return presentTransition
    }
    
    func imageViewController(controller: ImageViewController, didSwipeToDismissWithDistanceToEdge distance: CGFloat) {
        
    }
    
    func imageViewControllerDidSingleTap(controller: ImageViewController) {
        
    }
}

