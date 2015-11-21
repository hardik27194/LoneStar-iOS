//
//  MobiusoCircularCardController.swift
//
//  Sandeep Shah - 20150923
//  Copyright (c) 2015 - Sandeep Shah
//

import UIKit

let reuseIdentifier = "Cell"

class MobiusoCircularCardController: UICollectionViewController {
  
    
    // Unused
//    var images: [String] // = NSBundle.mainBundle().pathsForResourcesOfType("jpg", inDirectory: "ImagesTemp")
    
  var songs: [AnyObject]! /* = MoMediaCache.loadSongs() */
  
//    var instanceOfCustomObject: CustomObject = CustomObject()
//    instanceOfCustomObject.someProperty = "Hello World"
//    println(instanceOfCustomObject.someProperty)
//    instanceOfCustomObject.someMethod()
    
    var someList = [String]()
    var somestring: String = ""
    var delegate: MoAudioPlaybackViewController! = nil
   
  override func viewDidLoad() {
    super.viewDidLoad()
    // Register cell classes
    collectionView!.registerNib(UINib(nibName: "CircularCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
    let imageView = UIImageView(image: UIImage(named: "bg-dark.jpg"))
    imageView.contentMode = UIViewContentMode.ScaleAspectFill
    collectionView!.backgroundView = imageView
    
    // Dismiss Button
//    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    closeButton.frame = CGRectMake(frame.size.width - 52, 8, 44, 44);
//    [closeButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
//    //    [closeButton setImage:[UIImage imageNamed:@"dismissButt"] forState:UIControlStateNormal];   // SimpleCloseLine.png
//    
//    [closeButton setImage:[UIImage imageNamed:@"dismissButton"] forState:UIControlStateNormal];
//    [self.view addSubview: closeButton];

    // Add Close button
    let closeButton = UIButton()
    let frame = self.view.bounds
    closeButton.frame = CGRectMake(frame.size.width / 2 - 22, frame.size.height - 64, 44, 44)
    closeButton.addTarget(self, action: "close:", forControlEvents: .TouchUpInside)
    closeButton.setImage(UIImage(named: "dismissButton"), forState: .Normal)

    
//    closeButton.setImage(UIImage(RemapColor:UIColor(white: 1.0, alpha: 1.0), maskImage: UIImage(named: "dismissButton")), forState: .Normal)
    self.view.addSubview(closeButton)
//    print("string initialized \(somestring)")
    
    // Load the songs
    if (songs == nil) {
        songs = MoMediaCache.loadSongs()
    }
  }
    // Hide Status Bar
    override func prefersStatusBarHidden() -> Bool {
        return true;
    }

    // MARK: close action
    func close(sender: UIButton!) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
  
}

extension MobiusoCircularCardController /*: UICollectionViewDataSource */{
  
  // MARK: UICollectionViewDataSource
  
  override func collectionView(collectionView: UICollectionView,
    numberOfItemsInSection section: Int) -> Int {
      return (songs.count)
  }
  
  override func collectionView(collectionView: UICollectionView,
    cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
      let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CircularCollectionViewCell
        // Fake the image for now
//      cell.imageName = images[indexPath.row % images.count]
        // get the dictionary item
        let item: Dictionary<String, AnyObject> = songs[indexPath.row % songs.count] as! Dictionary<String, AnyObject>
        
        print("item value: \(item)")
//        let url: NSURL! = NSURL.fileURLWithPath(item["path"] as! String)
//
//        cell.imageView!.image = MoMediaCache.loadFromThumb(url)
        cell.imageView!.image = MoMediaCache.loadThumbIfAvailable(item)

      return cell
  }
    
  
}

extension MobiusoCircularCardController /*: UICollectionViewDelegate */ {
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let item: Dictionary<String, AnyObject> = songs[indexPath.row % songs.count] as! Dictionary<String, AnyObject>
        let name: String = item["path"] as! String
        print("Tapped \(indexPath.row) the name is \(name)")
        
        delegate?.didPickSong(indexPath.row)
        
        self.close(nil)
        
    }

}