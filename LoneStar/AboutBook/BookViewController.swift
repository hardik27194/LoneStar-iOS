//  BookViewController
//
//  Created by sandeep on 10/30/15.
//  Copyright © 2015 Medpresso. All rights reserved.

import UIKit

@objc protocol BookViewControllerDelegate {
    func bookPageTapped(page : NSInteger)
}

@objc class BookViewController: UICollectionViewController {
    
    var closeButton: UIButton?
    
    var splashView: UIView?
    
    var currentUser: String = "anonymous"
    
    var delegate: BookViewControllerDelegate?

    var book: Book? {
        didSet {
            collectionView?.reloadData()
        }
    }
    
    var recognizer: UIGestureRecognizer? {
        didSet {
            if let recognizer = recognizer {
                collectionView?.addGestureRecognizer(recognizer)
            }
        }
    }

    var taprecognizer: UITapGestureRecognizer? {
        didSet {
            if let taprecognizer = taprecognizer {
                collectionView?.addGestureRecognizer(taprecognizer)
            }
        }
    }

    var interactionController: UIPercentDrivenInteractiveTransition?
    
    var transition: BookOpeningTransition?
    
}

// MARK: UICollectionViewDataSource

extension BookViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        #if SPECIFIC_PRODUCT
            // We are building 5MCC, Ferri, etc.  This is not experimental version
            
        #else
            // We are building an experimental version 
            collectionView?.backgroundColor = UIColor.whiteColor()
        #endif
    
        recognizer = UIPinchGestureRecognizer(target: self, action: "handlePinch:")
        taprecognizer = UITapGestureRecognizer(target: self, action: "handleTap:")
        
        let transition = BookOpeningTransition()
        transition.isPush = true
        transition.interactionController = interactionController
        self.transition = transition
        

        let frame = self.view.bounds
        // Add Close button
        closeButton = UIButton()
        closeButton!.frame = CGRectMake(frame.size.width - 50, 8, 44, 44)
        closeButton!.addTarget(self, action: "close:", forControlEvents: .TouchUpInside)
        closeButton!.setImage(UIImage(named: "dismissButtWHITE"), forState: .Normal)
        
        // Set some layout Parameters
        let layout : BookLayout = collectionViewLayout as! BookLayout
        let size = book?.coverImage()!.size
        
//        print ("layout Ratio \(layout.widthToHeightRatio) - size: \(size?.width), \(size?.height)")
       
        // Now set the ratio for the layout to handle the images well
        layout.widthToHeightRatio = (size?.width)! / (size?.height)!
        
//        print ("New layout Ratio \(layout.widthToHeightRatio)")
       
        self.view.addSubview(closeButton!)

    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let book = book {
            return book.numberOfPages() + 1
        }
        return 0
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if indexPath.row == 0 {
            let cell = collectionView .dequeueReusableCellWithReuseIdentifier("BookCoverCell", forIndexPath: indexPath) as! BookCoverCell
            // Cover page
//            cell.textLabel.text = nil
            cell.image = book?.coverImage()
            return cell
        }
            
        else {
            let cell = collectionView .dequeueReusableCellWithReuseIdentifier("BookPageCell", forIndexPath: indexPath) as! BookPageCell
            // Page with index: indexPath.row - 1
            cell.textLabel.text = "\(indexPath.row)"
            cell.image = book?.pageImage(indexPath.row - 1)
            return cell
        }
        
    }
    
    // Hide Status Bar
    override func prefersStatusBarHidden() -> Bool {
        return true;
    }
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return (UIInterfaceOrientationMask.All)
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        let frame = closeButton?.frame
        let width = (frame?.size.width)!
        
        closeButton?.frame = CGRect(x: size.width - width - 8, y: (frame?.origin.y)!, width: width, height: (frame?.size.height)!)
    }
    

    // MARK: close action
    func close(sender: UIButton!) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    
    // MARK: Gesture recognizer action
    func handleTap(recognizer: UITapGestureRecognizer) {
        print("tapped")
        
        if (recognizer.view == collectionView) {
            
//            var cell : BookPageCell
//            cell = self.selectedCell()!
//            
//            print("Page Num \(cell.textLabel.text)")
            
            let point = recognizer.locationInView(recognizer.view)
            let addForRight = ((point.x - collectionView!.contentOffset.x) < (collectionView!.bounds.width/2)) ? 0 : 1
            let pageNum = Int(2.0 * collectionView!.contentOffset.x / collectionView!.bounds.width) + addForRight
//            print ("Point: \(point), X = \(point.x - collectionView!.contentOffset.x), Offset \(pageNum)")
            self.delegate?.bookPageTapped(pageNum)
            
            // Push another view Controller
//            imageView : UIImageView = UIImageView.init()
//            imageView.frame = self.view.bounds
//            imageView.image = book?.coverImage()
//            imageView.contentMode = UIViewContentMode.ScaleAspectFill
            let splashVC : SplashTransitionViewController = SplashTransitionViewController.init(nibName: "SplashTransitionViewController", bundle: nil)
            
            self.presentViewController(splashVC, animated: true, completion: { () -> Void in
                splashVC.signatureImageView.image = self.book?.coverImage()
                splashVC.splashDuration = 0
                splashVC.aboutTitle.text = self.book?.title()
                splashVC.moreInformation = "\(self.book!.title().uppercaseString) - licensed to \(self.currentUser.uppercaseString)"

            })

            
            
//            splashVC.signatureImageView.image = ;
//            splashVC.splashDuration = 0;
//            splashVC.aboutTitle.text = book?.title();
//            
//            splashView = splashVC.view
//
//            self.view.addSubview(splashView!)
//            self.view.bringSubviewToFront(closeButton!)
//            overlay = true
        }
    }
    
    func handlePinch(recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
        case .Began:
            //1
            interactionController = UIPercentDrivenInteractiveTransition()
            //2
            if recognizer.scale >= 1 {
                if recognizer.view == collectionView {
                    //4
                    print("Scale > 1")
                    if recognizer.view == collectionView {
                        var cell : BookPageCell
                        cell = self.selectedCell()!
                        print("Page Num \(cell.textLabel.text)")
                    }

                }
                //6
            } else {
                //7
                self.dismissViewControllerAnimated(true, completion: nil)
//                navigationController?.popViewControllerAnimated(true)
            }
        case .Changed:
            //1
            if transition!.isPush {
                //2
                let progress = min(max(abs((recognizer.scale - 1)) / 5, 0), 1)
                //3
                interactionController?.updateInteractiveTransition(progress)
                //4
            } else {
                //5
                let progress = min(max(abs((1 - recognizer.scale)), 0), 1)
                //6
                interactionController?.updateInteractiveTransition(progress)
            }
        case .Ended:
            //1
            interactionController?.finishInteractiveTransition()
            //2
            interactionController = nil
        default:
            break
        }
    }
    
    // MARK: Helpers - both are not reliable indicator for the actual page
    
    func selectedCell() -> BookPageCell? {
        if let indexPath = collectionView?.indexPathForItemAtPoint(CGPointMake(collectionView!.contentOffset.x + collectionView!.bounds.width / 2, collectionView!.bounds.height / 2)) {
            if let cell = collectionView?.cellForItemAtIndexPath(indexPath) as? BookPageCell {
                return cell
            }
        }
        return nil
    }
    
    func selectedPage() -> NSInteger {
        let indexPath = collectionView?.indexPathForItemAtPoint(CGPointMake(collectionView!.contentOffset.x + collectionView!.bounds.width / 2, collectionView!.bounds.height / 2))
        if ((indexPath) != nil) {
            return (indexPath?.row)!
        } else {
            return -1
        }
    }
    

    
}
