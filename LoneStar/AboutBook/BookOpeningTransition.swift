//
//  BookOpeningTransition.swift
//  LoneStar
//
//  Created by sandeep on 10/30/15.
//  Copyright © 2015 Medpresso. All rights reserved.


import UIKit


//1
@objc class BookOpeningTransition: NSObject, UIViewControllerAnimatedTransitioning {
  
  // MARK: Stored properties
  var transforms = [UICollectionViewCell: CATransform3D]() //2
  var toViewBackgroundColor: UIColor? //3
  var isPush = true //4
  
  //5
  // MARK: UIViewControllerAnimatedTransitioning
  func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
    if isPush {
      return 1
    } else {
      return 1
    }
  }
  
  // MARK: Interaction Controller
  var interactionController: UIPercentDrivenInteractiveTransition?
  
  func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
    //1
    let container = transitionContext.containerView()
    //2
    if isPush {
      //3
      let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as! ViewController
      let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as! BookViewController
      //4
      container!.addSubview(toVC.view)
      
      // Perform transition
      //5
      self.setStartPositionForPush(fromVC, toVC: toVC)
      
      UIView.animateWithDuration(self.transitionDuration(transitionContext), delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: [], animations: {
        //6
        self.setEndPositionForPush(fromVC, toVC: toVC)
        }, completion: { finished in
          //7
          self.cleanupPush(fromVC, toVC: toVC)
          //8
          transitionContext.completeTransition(finished)
      })
    } else {
      //1
      let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as! BookViewController
      let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as! ViewController
      
      //2
      container!.insertSubview(toVC.view, belowSubview: fromVC.view)
      
      //3
      setStartPositionForPop(fromVC, toVC: toVC)
      UIView.animateWithDuration(self.transitionDuration(transitionContext), animations: {
        //4
        self.setEndPositionForPop(fromVC, toVC: toVC)
        }, completion: { finished in
          //5
          self.cleanupPop(fromVC, toVC: toVC)
          //6
          transitionContext.completeTransition(finished)
      })
    }
  }
  
  // MARK: Helper Methods
  func makePerspectiveTransform() -> CATransform3D {
    var transform = CATransform3DIdentity
    transform.m34 = 1.0 / -2000
    return transform
  }
  
  func closePageCell(cell : BookPageCell) {
    // 1
    var transform = self.makePerspectiveTransform()
    // 2
    if cell.layer.anchorPoint.x == 0 {
      // 3
      transform = CATransform3DRotate(transform, CGFloat(0), 0, 1, 0)
      // 4
      transform = CATransform3DTranslate(transform, -0.7 * cell.layer.bounds.width / 2, 0, 0)
      // 5
      transform = CATransform3DScale(transform, 0.7, 0.7, 1)
    }
      // 6
    else {
      // 7
      transform = CATransform3DRotate(transform, CGFloat(-M_PI), 0, 1, 0)
      // 8
      transform = CATransform3DTranslate(transform, 0.7 * cell.layer.bounds.width / 2, 0, 0)
      // 9
      transform = CATransform3DScale(transform, 0.7, 0.7, 1)
    }
    
    //10
    cell.layer.transform = transform
  }
  
  func setStartPositionForPush(fromVC: ViewController, toVC: BookViewController) {
    // 1
    toViewBackgroundColor = UIColor.blackColor(); //  fromVC.collectionView?.backgroundColor
    toVC.collectionView?.backgroundColor = nil
    
    //2
    #if false
    fromVC.selectedCell()?.alpha = 0
        #endif
    
    
    //3
    for cell in toVC.collectionView!.visibleCells() as! [BookPageCell] {
      //4
      transforms[cell] = cell.layer.transform
      //5
      closePageCell(cell)
      cell.updateShadowLayer()
      //6
      if let indexPath = toVC.collectionView?.indexPathForCell(cell) {
        if indexPath.row == 0 {
          cell.shadowLayer.opacity = 0
        }
      }
    }
  }
  
  func setEndPositionForPush(fromVC: ViewController, toVC: BookViewController) {
    //1
    #if false
    for cell in fromVC.collectionView!.visibleCells() as! [BookCoverCell] {
      cell.alpha = 0
    }
    #endif
    
    //2
    for cell in toVC.collectionView!.visibleCells() as! [BookPageCell] {
      cell.layer.transform = transforms[cell]!
      cell.updateShadowLayer(true)
    }
  }
  
  func cleanupPush(fromVC: ViewController, toVC: BookViewController) {
    // Add background back to pushed view controller
    toVC.collectionView?.backgroundColor = toViewBackgroundColor
    
    // Pass the gesture recognizer
    toVC.recognizer = fromVC.recognizer
  }
  
  // MARK: Pop methods
  func setStartPositionForPop(fromVC: BookViewController, toVC: ViewController) {
    // Remove background from the pushed view controller
    toViewBackgroundColor = UIColor.whiteColor(); // fromVC.collectionView?.backgroundColor
    fromVC.collectionView?.backgroundColor = nil
  }
  
  func setEndPositionForPop(fromVC: BookViewController, toVC: ViewController) {
    //1
    let coverCell = toVC.ipv
    //2
    #if false
    for cell in toVC.collectionView!.visibleCells() as! [BookCoverCell] {
      if cell != coverCell {
        cell.alpha = 1
      }
    }
        #endif
    //3
    for cell in fromVC.collectionView!.visibleCells() as! [BookPageCell] {
      closePageCell(cell)
    }
  }
  
  func cleanupPop(fromVC: BookViewController, toVC: ViewController) {
    // Add background back to pushed view controller
    fromVC.collectionView?.backgroundColor = self.toViewBackgroundColor
    
    // Pass the gesture recognizer
    toVC.recognizer = fromVC.recognizer
    
    // Unhide the original book cover
    #if false
    toVC.selectedCell()?.alpha = 1
    #endif
  }
}