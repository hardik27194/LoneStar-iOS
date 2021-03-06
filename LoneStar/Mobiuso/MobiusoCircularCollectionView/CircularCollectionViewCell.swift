//
//  CircularCollectionViewCell.swift
//

import UIKit

class CircularCollectionViewCell: UICollectionViewCell {
  
  var imageName = "" {
    didSet {
      imageView!.image = UIImage(named: imageName)
    }
  }
  
  @IBOutlet weak var imageView: UIImageView?
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    contentView.layer.cornerRadius = 5
    contentView.layer.borderColor = UIColor.blackColor().CGColor
    contentView.layer.borderWidth = 1
    contentView.layer.shouldRasterize = true
    contentView.layer.rasterizationScale = UIScreen.mainScreen().scale
    contentView.clipsToBounds = true
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    imageView!.contentMode = .ScaleAspectFill
  }
  
  override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes) {
    super.applyLayoutAttributes(layoutAttributes)
    let circularlayoutAttributes = layoutAttributes as! CircularCollectionViewLayoutAttributes
    self.layer.anchorPoint = circularlayoutAttributes.anchorPoint
    self.center.y += (circularlayoutAttributes.anchorPoint.y - 0.5)*CGRectGetHeight(self.bounds)
  }
  
}
