//
//  MemeViewController.swift
//  Meme Maker
//
//  Created by Lyndsey Scott on 10/1/15.
//
import UIKit

class MemeViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var image: UIImage?
    var topText: String?
    var bottomText: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        // Unwrap the topText, bottomText, and image
        if let topText = topText, let bottomText = bottomText, let image = image {
            // Combine the cropped version of the image
            let combinedImage = addTextToImage(topText.uppercaseString, bottomText: bottomText.uppercaseString, inImage: image)
            // Set the image view to contain the image
            imageView.image = combinedImage
        }
    }

    func addTextToImage(topText: String, bottomText: String, inImage: UIImage) -> UIImage {
        // Setup the image context using the passed image.
        UIGraphicsBeginImageContext(inImage.size)
        
        // Create a paragraph style with center alignment
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.Center
        
        var fontSize = inImage.size.height/8.0
        // Setup up the font attributes that will be later used to dictate how the text should be drawn
        var textFontAttributes = [
            NSFontAttributeName: UIFont(name: "Impact", size: fontSize)!,
            NSStrokeColorAttributeName : UIColor.blackColor(),
            NSForegroundColorAttributeName : UIColor.whiteColor(),
            NSStrokeWidthAttributeName : -5.0,
            NSParagraphStyleAttributeName: paragraphStyle
        ]
        
        // Put the image into a rectangle as large as the original image.
        inImage.drawInRect(CGRectMake(0, 0, inImage.size.width, inImage.size.height))
        
        // Calculate the frame of the top text given the image's width
        var topRectSize = (topText as NSString).boundingRectWithSize(CGSize(width: inImage.size.width, height: CGFloat(MAXFLOAT)),
            options: NSStringDrawingOptions.UsesLineFragmentOrigin,
            attributes: textFontAttributes,
            context: nil).size

        // While the top text's topRect frame would take up more than 1/3.5 of the image,
        // shrink the font size until it wouldn't
        while topRectSize.height > inImage.size.height/3.5 {
            fontSize--
            textFontAttributes[NSFontAttributeName] = UIFont(name: "Impact", size: fontSize)!
            topRectSize = (topText as NSString).boundingRectWithSize(CGSize(width: inImage.size.width, height: CGFloat(MAXFLOAT)),
                options: NSStringDrawingOptions.UsesLineFragmentOrigin,
                attributes: textFontAttributes,
                context: nil).size
            
        }
       
        // Calculate the frame of the bottom text given the image's width
        var bottomRectSize = (bottomText as NSString).boundingRectWithSize(CGSize(width: inImage.size.width, height: CGFloat(MAXFLOAT)),
            options: NSStringDrawingOptions.UsesLineFragmentOrigin,
            attributes: textFontAttributes,
            context: nil).size

        // While the top text's bottomRect frame would take up more than 1/3.5 of the image,
        // shrink the font size determining both the top and bottom frames
        while bottomRectSize.height > inImage.size.height/3.5 {
            fontSize--
            textFontAttributes[NSFontAttributeName] = UIFont(name: "Impact", size: fontSize)!
            bottomRectSize = (topText as NSString).boundingRectWithSize(CGSize(width: inImage.size.width, height: inImage.size.height),
                options: NSStringDrawingOptions.UsesLineFragmentOrigin,
                attributes: textFontAttributes,
                context: nil).size
            topRectSize = (topText as NSString).boundingRectWithSize(CGSize(width: inImage.size.width, height: CGFloat(MAXFLOAT)),
                options: NSStringDrawingOptions.UsesLineFragmentOrigin,
                attributes: textFontAttributes,
                context: nil).size
            
        }

        // Create the frame which will hold the top text.
        let topRect: CGRect = CGRectMake(0, 0, inImage.size.width, topRectSize.height)
        
        // Draw the top text on the image within the topRect frame.
        topText.drawInRect(topRect, withAttributes: textFontAttributes)
        
        // Create the frame which will hold the bottom text.
        let bottomRect: CGRect = CGRectMake(0, inImage.size.height-bottomRectSize.height, inImage.size.width, bottomRectSize.height)
        
        // Draw the bottom text on the image within the bottomRect frame.
        bottomText.drawInRect(bottomRect, withAttributes: textFontAttributes)
        
        // Create a new image out of the images we have created
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // End the context now that we have the image we need
        UIGraphicsEndImageContext()

        // And pass it back up to the caller.
        return newImage
        
    }
    
    @IBAction func shareMeme(sender: AnyObject) {

        // Create an activityViewController to share the image
        let activityViewController = UIActivityViewController(activityItems:
           [imageView.image!], applicationActivities: nil)
        
        // Exclude whichever share activities you can't post an image to
        // (Full list of activity types available in Apple's Documentation)
        let excludeActivities = [
            UIActivityTypeAssignToContact,
            UIActivityTypeAddToReadingList,
            UIActivityTypePostToVimeo]
        activityViewController.excludedActivityTypes = excludeActivities
        
        // Present the activity view controller
        presentViewController(activityViewController, animated: true,
            completion: nil)
    }
}

extension UIImage {
    
    // Normalize the image (to correct the rotation that happens to camera images)
    func normalizedImage() -> UIImage {
        
        if self.imageOrientation == UIImageOrientation.Up {
            return self
        }
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        self.drawInRect(rect)
        
        let normalizedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return normalizedImage
    }
    
    func scaleImage(maxDimension: CGFloat) -> UIImage {
        
        var scaledSize = CGSize(width: maxDimension, height: maxDimension)
        var scaleFactor: CGFloat
        
        if self.size.width > self.size.height {
            scaleFactor = self.size.height / self.size.width
            scaledSize.width = maxDimension
            scaledSize.height = scaledSize.width * scaleFactor
        } else {
            scaleFactor = self.size.width / self.size.height
            scaledSize.height = maxDimension
            scaledSize.width = scaledSize.height * scaleFactor
        }
        
        UIGraphicsBeginImageContext(scaledSize)
        self.drawInRect(CGRectMake(0, 0, scaledSize.width, scaledSize.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
    
    func cropImageIntoSquare() -> UIImage {
        
        // Get the original width and height
        let originalWidth  = self.size.width
        let originalHeight = self.size.height
        
        // Store the smaller of either width or height since that
        // will serve as both the width and height of the square
        var edge: CGFloat
        if originalWidth > originalHeight {
            edge = originalHeight
        } else {
            edge = originalWidth
        }
        
        // Calculate the new x and y such that it crops to show
        // the center area of the rectangle
        let posX = (originalWidth  - edge) / 2.0
        let posY = (originalHeight - edge) / 2.0
        
        // Create the frame
        let cropSquare = CGRectMake(posX, posY, edge, edge)
        
        // Perform the crop
        let imageRef = CGImageCreateWithImageInRect(self.CGImage, cropSquare)
        
        // Convert the context's CGImage into a UIImage then return the image
        return UIImage(CGImage: imageRef!, scale: UIScreen.mainScreen().scale, orientation: self.imageOrientation)
    }

}