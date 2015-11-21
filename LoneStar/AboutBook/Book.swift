//  Book
//
//  Created by sandeep on 10/30/15.
//  Copyright © 2015 Medpresso. All rights reserved.


import UIKit

@objc class Book: NSObject {

    convenience init (dict: NSDictionary) {
        self.init()
        self.dict = dict
    }
    
    var dict: NSDictionary?
    
    func coverImage () -> UIImage? {
        let cover = dict?["cover"]
        if ((cover as? String) != nil) {
            return UIImage(named: cover as! String)
        } else if ((cover as? UIImage) != nil) {
            return (cover as! UIImage)
        }
        return nil
    }
    
    func pageImage (index: Int) -> UIImage? {
        if let pages = dict?["pages"] as? NSArray {
            let page = pages[index]
            if ((page as? String) != nil) {
                return UIImage(named: page as! String)
            } else if ((page as? UIImage) != nil) {
                return page as? UIImage
            }
        }
        return nil
    }
    
    func numberOfPages () -> Int {
        if let pages = dict?["pages"] as? NSArray {
            return pages.count
        }
        return 0
    }
    
    func title () -> String {
        return (dict?["name"])! as! String
    }
    
    func editor () -> String {
        return (dict?["editor"])! as! String
    }
}
