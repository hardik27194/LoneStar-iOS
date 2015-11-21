//  BookPageCell
//
//  Created by sandeep on 10/30/15.
//  Copyright © 2015 Medpresso. All rights reserved.


import UIKit

@objc class BookPageCell: UICollectionViewCell {
	
	@IBOutlet var textLabel: UILabel!
	@IBOutlet weak var imageView: UIImageView!
	

	var book: Book?
	var isRightPage: Bool = false
	var shadowLayer: CAGradientLayer = CAGradientLayer()
	
	override var bounds: CGRect {
		didSet {
			shadowLayer.frame = bounds
		}
	}
	
	var image: UIImage? {
		didSet {
            let corners: UIRectCorner = isRightPage ? UIRectCorner.TopRight.union(.BottomRight) : UIRectCorner.TopLeft.union(.BottomLeft)
			imageView.image = image!.imageByScalingAndCroppingForSize(bounds.size).imageWithRoundedCornersSize(10, corners: corners)
		}
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		setupAntialiasing()
		initShadowLayer()
	}
	
	
	func setupAntialiasing() {
		layer.allowsEdgeAntialiasing = true
		imageView.layer.allowsEdgeAntialiasing = true
	}
	
	func initShadowLayer() {
		let shadowLayer = CAGradientLayer()
		
		shadowLayer.frame = bounds
		shadowLayer.startPoint = CGPointMake(0, 0.5)
		shadowLayer.endPoint = CGPointMake(1, 0.5)
		
		self.imageView.layer.addSublayer(shadowLayer)
		self.shadowLayer = shadowLayer
	}
	
	func getRatioFromTransform() -> CGFloat {
		var ratio: CGFloat = 0
		
		let rotationY = CGFloat(layer.valueForKeyPath("transform.rotation.y")!.floatValue!)
		if !isRightPage {
			let progress = -(1 - rotationY / CGFloat(M_PI_2))
			ratio = progress
		}
			
		else {
			let progress = 1 - rotationY / CGFloat(-M_PI_2)
			ratio = progress
		}
		
		return ratio
	}
	
	func updateShadowLayer(animated: Bool = false) {
//		var ratio: CGFloat = 0
		
		// Get ratio from transform. Check BookCollectionViewLayout for more details
		let inverseRatio = 1 - abs(getRatioFromTransform())
		
		if !animated {
			CATransaction.begin()
			CATransaction.setDisableActions(!animated)
		}
		
		if isRightPage {
			// Right page
			shadowLayer.colors = NSArray(objects:
				UIColor.darkGrayColor().colorWithAlphaComponent(inverseRatio * 0.45).CGColor,
				UIColor.darkGrayColor().colorWithAlphaComponent(inverseRatio * 0.40).CGColor,
				UIColor.darkGrayColor().colorWithAlphaComponent(inverseRatio * 0.55).CGColor
			) as! [UIColor]
			shadowLayer.locations = NSArray(objects:
				NSNumber(float: 0.00),
				NSNumber(float: 0.02),
				NSNumber(float: 1.00)
			) as? [NSNumber]
		} else {
			// Left page
			shadowLayer.colors = NSArray(objects:
				UIColor.darkGrayColor().colorWithAlphaComponent(inverseRatio * 0.30).CGColor,
				UIColor.darkGrayColor().colorWithAlphaComponent(inverseRatio * 0.40).CGColor,
				UIColor.darkGrayColor().colorWithAlphaComponent(inverseRatio * 0.50).CGColor,
				UIColor.darkGrayColor().colorWithAlphaComponent(inverseRatio * 0.55).CGColor
			) as! [UIColor]
			shadowLayer.locations = NSArray(objects:
				NSNumber(float: 0.00),
				NSNumber(float: 0.50),
				NSNumber(float: 0.98),
				NSNumber(float: 1.00)
			) as? [NSNumber]
		}
		
		if !animated {
			CATransaction.commit()
		}
	}
	
	override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes) {
		super.applyLayoutAttributes(layoutAttributes)
		if layoutAttributes.indexPath.item % 2 == 0 {
			// The book's spine is on the left of the page
			layer.anchorPoint = CGPointMake(0, 0.5)
			isRightPage = true
		} else {
			// The book's spine is on the right of the page
			layer.anchorPoint = CGPointMake(1, 0.5)
			isRightPage = false
		}
		
		self.updateShadowLayer()
	}
	
}
