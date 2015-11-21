//  BookCoverCell
//
//  Created by sandeep on 10/30/15.
//  Copyright © 2015 Medpresso. All rights reserved.

import UIKit

@objc class BookCoverCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var book: Book? {
        didSet {
            image = book?.coverImage()
        }
    }
    
    var image: UIImage? {
        didSet {
            let corners: UIRectCorner = [.TopRight, .BottomRight]
            imageView.image = image!.imageByScalingAndCroppingForSize(bounds.size).imageWithRoundedCornersSize(10, corners: corners)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
	
}
