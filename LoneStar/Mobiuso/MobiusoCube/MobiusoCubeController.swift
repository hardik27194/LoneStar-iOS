//
//  MobiusoCubeController.swift
//  FAVbox
//
//  Created by Sandeep Shah on 09/23/2015.
//  Copyright (c) 2015 Sandeep Shah. All rights reserved.
//

import UIKit
import ObjectiveC

func degreesToRadians(degrees: Double) -> CGFloat {
    return CGFloat(degrees * M_PI / 180.0)
}

func radiansToDegrees(radians: Double) -> CGFloat {
    return CGFloat(radians / M_PI * 180.0)
}

var  nameKey = "name" as NSObject!

class MobiusoCubeController: UIViewController {

    private struct AssociatedKeys {
        static var DescriptiveName = "descriptiveName"
    }

    @IBOutlet weak var boxTappedLabel: UILabel!
    @IBOutlet weak var viewForTransformLayer: UIView!
    @IBOutlet var colorAlphaSwitches: [UISwitch]!
    var cubeFaceLayers: [CALayer]!    // find the relevant layer
    
    var beginPoint: CGPoint = CGPoint()
    var beginTimeStamp: NSTimeInterval = 0.0
    
    enum Color: Int {
        case Red,   // Front
        Orange,     // Right
        Yellow,     // Back
        Green,      // Left
        Blue,       // Top
        Purple      // Bottom
    }
    
    enum CubeFace: Int {
        case Front,   // Front
        Right,     // Right
        Back,     // Back
        Left,      // Left
        Top,       // Top
        Bottom      // Bottom
    }

    let sideLength = CGFloat(160.0)
    let reducedAlpha = CGFloat(0.8)
    
    var transformLayer: CATransformLayer!
    let swipeMeTextLayer = CATextLayer()
    var redColor = UIColor.redColor()
    var orangeColor = UIColor.orangeColor()
    var yellowColor = UIColor.yellowColor()
    var greenColor = UIColor.greenColor()
    var blueColor = UIColor.blueColor()
    var purpleColor = UIColor.purpleColor()
    
    var trackBall: TrackBall?
    

    
    func setUpSwipeMeTextLayer() {
        swipeMeTextLayer.frame = CGRect(x: 10.0, y: sideLength - 44.0, width: sideLength - 20.0, height: 20.0)
        swipeMeTextLayer.string = "FAVbox"
        swipeMeTextLayer.alignmentMode = kCAAlignmentCenter
        swipeMeTextLayer.foregroundColor = UIColor.whiteColor().CGColor
        let fontName = "BebasNeue" /* "Noteworthy-Light" */ as CFString
        let fontRef = CTFontCreateWithName(fontName, 8.0, nil)
        swipeMeTextLayer.font = fontRef
        swipeMeTextLayer.contentsScale = UIScreen.mainScreen().scale
    }
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        redColor = colorForColor(redColor, withAlpha: reducedAlpha)
        orangeColor = colorForColor(orangeColor, withAlpha: reducedAlpha)
        yellowColor = colorForColor(yellowColor, withAlpha: reducedAlpha)
        greenColor = colorForColor(greenColor, withAlpha: reducedAlpha)
        blueColor = colorForColor(blueColor, withAlpha: reducedAlpha)
        purpleColor = colorForColor(purpleColor, withAlpha: reducedAlpha)

        setUpSwipeMeTextLayer()
        buildCube()
        setupView()
        addCloseButton()
    }
    
    func setupView() {
        let frame = self.view.bounds
        let image =  Utilities.createGradientImageFromColor(redColor, toColor: orangeColor, withSize: frame.size)
        // self.view.backgroundColor = UIColor.grayColor()
        self.view.layer.contents = image.CGImage
 
        redColor = colorForColor(redColor, withAlpha: reducedAlpha)
        orangeColor = colorForColor(orangeColor, withAlpha: reducedAlpha)
        yellowColor = colorForColor(yellowColor, withAlpha: reducedAlpha)
        greenColor = colorForColor(greenColor, withAlpha: reducedAlpha)
        blueColor = colorForColor(blueColor, withAlpha: reducedAlpha)
        purpleColor = colorForColor(purpleColor, withAlpha: reducedAlpha)

        
    }
    
    func addCloseButton() {
        // Add Close button
        let closeButton = UIButton()
        let frame = self.view.bounds
        closeButton.frame = CGRectMake(frame.size.width / 2 - 22, frame.size.height - 64, 44, 44)
        closeButton.addTarget(self, action: "close:", forControlEvents: .TouchUpInside)
        closeButton.setImage(UIImage(named: "dismissButton"), forState: .Normal)
        self.view.addSubview(closeButton)
        
    }
    // MARK: - IBActions
    
    @IBAction func colorAlphaSwitchChanged(sender: UISwitch) {
        let alpha = sender.on ? 1.0 : reducedAlpha
        
        switch (colorAlphaSwitches as NSArray).indexOfObject(sender) {
        case Color.Red.rawValue:
            redColor = colorForColor(redColor, withAlpha: alpha)
        case Color.Orange.rawValue:
            orangeColor = colorForColor(orangeColor, withAlpha: alpha)
        case Color.Yellow.rawValue:
            yellowColor = colorForColor(yellowColor, withAlpha: alpha)
        case Color.Green.rawValue:
            greenColor = colorForColor(greenColor, withAlpha: alpha)
        case Color.Blue.rawValue:
            blueColor = colorForColor(blueColor, withAlpha: alpha)
        case Color.Purple.rawValue:
            purpleColor = colorForColor(purpleColor, withAlpha: alpha)
        default:
            break
        }
        
        transformLayer.removeFromSuperlayer()
        buildCube()
    }
    
    // MARK: - Triggered actions
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch =  touches.first as UITouch! {
            let location = touch.locationInView(viewForTransformLayer)
            beginPoint = location
            beginTimeStamp = touch.timestamp
            if trackBall != nil {
                trackBall?.setStartPointFromLocation(location)
            } else {
                trackBall = TrackBall(location: location, inRect: viewForTransformLayer.bounds)
            }
            
            for layer in transformLayer.sublayers! {
                //                if let hitLayer = layer.hitTest(location)
                let point = transformLayer.convertPoint(location, toLayer: layer)
                print("at location \(location) - \(point)")
                
                if layer.containsPoint(location)
                {
                    showBoxTappedLabel()
                    
                    var whichFace = "saywhat?"
                    
                    switch ((cubeFaceLayers as NSArray).indexOfObject(layer)) {
                    case CubeFace.Back.rawValue:
                        whichFace = "BACK"
                    case CubeFace.Front.rawValue:
                        whichFace = "FRONT"
                    case CubeFace.Right.rawValue:
                        whichFace = "RIGHT"
                    case CubeFace.Left.rawValue:
                        whichFace = "LEFT"
                    case CubeFace.Top.rawValue:
                        whichFace = "TOP"
                    case CubeFace.Bottom.rawValue:
                        whichFace = "BOTTOM"
                    default:
                        break
                        
                    }
                    print("Hit on \(whichFace)")
                    break
                }
            }
            
        }
    }
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch =  touches.first as UITouch! {
            let location = touch.locationInView(viewForTransformLayer)
            print("touch moved \(location)")

            if let transform = trackBall?.rotationTransformForLocation(location) {
                viewForTransformLayer.layer.sublayerTransform = transform
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch =  touches.first as UITouch! {
            let location = touch.locationInView(viewForTransformLayer)
            
            let timestamp = touch.timestamp
            print("touch ended \(location) & \(timestamp)")

            trackBall?.finalizeTrackBallForLocation(location)
            
            if ( (fabs(location.x - beginPoint.x) < 5 && (fabs(location.y - beginPoint.y) < 5)) &&
                ( (timestamp - beginTimeStamp) < 2) )
            {
                print("Single Tap");
                // try to make smaller
                if let transform = trackBall?.rotationTransformForLocation(location) {
                    let scaletransform = CATransform3DMakeScale(0.5, 0.5, 0.5)
                    let finaltransform = CATransform3DConcat(transform, scaletransform)
                    
                    UIView.animateWithDuration(0.8, animations: {
                        self.viewForTransformLayer.layer.sublayerTransform = finaltransform
                        }, completion: { finished in
                            print("done!")
                        })

                }
                

            }

        }
    }
    
    func showBoxTappedLabel() {
        boxTappedLabel.alpha = 1.0
        boxTappedLabel.hidden = false
        
        UIView.animateWithDuration(0.5, animations: {
            self.boxTappedLabel.alpha = 0.0
            }, completion: {
                [unowned self] _ in
                self.boxTappedLabel.hidden = true
            })
    }
    
    
    // MARK: - Helpers
    
    func buildCube() {
        transformLayer = CATransformLayer()
        
        cubeFaceLayers = [CALayer](count: 6, repeatedValue: CALayer())
        
        // red - Front
        var layer = sideLayerWithColor(redColor)
        layer.addSublayer(swipeMeTextLayer)
        layer.contents = UIImage(named: "Box-512")?.CGImage
        #if false
            // The following causes a problem to send the reference key to SwiftUtilities
            MoSwiftUtilities.setAssociatedObject(layer, setValue: &AssociatedKeys.DescriptiveName, forKey: "Front-Red");
            let name = MoSwiftUtilities.getAssociatedObject(layer, forKey: &AssociatedKeys.DescriptiveName)
            print("layer name: \(name)")
        #endif
    
        transformLayer.addSublayer(layer)
        layer.name = "front"

        cubeFaceLayers[CubeFace.Front.rawValue] = layer;
        
        layer = sideLayerWithColor(orangeColor)
        layer.contents = UIImage(named: "Music-512")?.CGImage
        
        var transform = CATransform3DMakeTranslation(sideLength / 2.0, 0.0, sideLength / -2.0)
        transform = CATransform3DRotate(transform, degreesToRadians(90.0), 0.0, 1.0, 0.0)
        layer.transform = transform
        transformLayer.addSublayer(layer)
        layer.name = "right"

        cubeFaceLayers[CubeFace.Right.rawValue] = layer;

        layer = sideLayerWithColor(yellowColor)
        layer.contents = UIImage(named: "Video-512")?.CGImage
        layer.transform = CATransform3DMakeTranslation(0.0, 0.0, -sideLength)
        transformLayer.addSublayer(layer)
        layer.name = "back"

        cubeFaceLayers[CubeFace.Back.rawValue] = layer;
        
        layer = sideLayerWithColor(greenColor)
        transform = CATransform3DMakeTranslation(sideLength / -2.0, 0.0, sideLength / -2.0)
        transform = CATransform3DRotate(transform, degreesToRadians(90.0), 0.0, 1.0, 0.0)
        layer.transform = transform
        transformLayer.addSublayer(layer)
        cubeFaceLayers[CubeFace.Left.rawValue] = layer;
        
        layer = sideLayerWithColor(blueColor)
        transform = CATransform3DMakeTranslation(0.0, sideLength / -2.0, sideLength / -2.0)
        transform = CATransform3DRotate(transform, degreesToRadians(90.0), 1.0, 0.0, 0.0)
        layer.transform = transform
        transformLayer.addSublayer(layer)
        layer.name = "top"

        cubeFaceLayers[CubeFace.Top.rawValue] = layer;
        
        layer = sideLayerWithColor(purpleColor)
        transform = CATransform3DMakeTranslation(0.0, sideLength / 2.0, sideLength / -2.0)
        transform = CATransform3DRotate(transform, degreesToRadians(90.0), 1.0, 0.0, 0.0)
        layer.transform = transform
        transformLayer.addSublayer(layer)
        layer.name = "bottom"
        cubeFaceLayers[CubeFace.Bottom.rawValue] = layer;
        
        transformLayer.anchorPointZ = sideLength / -2.0
        viewForTransformLayer.layer.addSublayer(transformLayer)
    }
    
    func sideLayerWithColor(color: UIColor) -> CALayer {
        let layer = CALayer()
        layer.frame = CGRect(origin: CGPointZero, size: CGSize(width: sideLength, height: sideLength))
        layer.position = CGPoint(x: CGRectGetMidX(viewForTransformLayer.bounds), y: CGRectGetMidY(viewForTransformLayer.bounds))
        layer.backgroundColor = color.CGColor
        return layer
    }
    
    func colorForColor(var color: UIColor, withAlpha newAlpha: CGFloat) -> UIColor {
        var red = CGFloat()
        var green = red, blue = red, alpha = red
        
        if color.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            color = UIColor(red: red, green: green, blue: blue, alpha: newAlpha)
        }
        
        return color
    }
    
    // MARK: close action
    func close(sender: UIButton!) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
}

#if false
    // This could work, except OBJC_ASSOCIATION_RETAIN does not seem to work at present - 20150922
extension UIViewController {
    private struct AssociatedKeys {
        static var DescriptiveName = "nsh_DescriptiveName"
    }
    
    var descriptiveName: String? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.DescriptiveName) as? String
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(
                    self,
                    &AssociatedKeys.DescriptiveName,
                    newValue as NSString?,
                    OBJC_ASSOCIATION_RETAIN
                )
            }
        }
    }
}
#endif
