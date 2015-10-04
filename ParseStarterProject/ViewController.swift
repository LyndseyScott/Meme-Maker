//
//  ViewController.swift
//  Meme Maker
//
//  Created by Lyndsey Scott on 10/1/15.
//

import UIKit

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var memeArray:[(image: UIImage, topText: String, bottomText: String)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        imageView.layer.borderColor = UIColor.blackColor().CGColor
        imageView.layer.borderWidth = 1
        
        tableView.layer.borderColor = UIColor.blackColor().CGColor
        tableView.layer.borderWidth = 1
        
        if let savedMemes = NSUserDefaults.standardUserDefaults().valueForKey("meme_array") as? [[AnyObject]] {
            for meme in savedMemes {
                memeArray += [(image:UIImage(data: meme[0] as! NSData)!, topText:meme[1] as! String, bottomText:meme[2] as! String)]
            }
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func selectImage(sender: AnyObject) {
        self.view.endEditing(true)
        let imagePickerActionSheet = UIAlertController(title: "Get Photo",
            message: nil, preferredStyle: .ActionSheet)
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            let cameraButton = UIAlertAction(title: "Take Photo",
                style: .Default) { (alert) -> Void in
                    let imagePicker = UIImagePickerController()
                    imagePicker.delegate = self
                    imagePicker.sourceType = .Camera
                    self.presentViewController(imagePicker,
                        animated: true,
                        completion: nil)
            }
            imagePickerActionSheet.addAction(cameraButton)
        }
        
        let libraryButton = UIAlertAction(title: "Choose Existing",
            style: .Default) { (alert) -> Void in
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .PhotoLibrary
                self.presentViewController(imagePicker,
                    animated: true,
                    completion: nil)
        }
        imagePickerActionSheet.addAction(libraryButton)
        
        let cancelButton = UIAlertAction(title: "Cancel",
            style: .Cancel) { (alert) -> Void in
        }
        imagePickerActionSheet.addAction(cancelButton)
        
        presentViewController(imagePickerActionSheet, animated: true,
            completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = pickedImage.normalizedImage().cropImageIntoSquare().scaleImage(self.view.frame.size.width*2)
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func submitImage(sender: AnyObject) {
        self.view.endEditing(true)
        if let image = imageView.image, let topText = topTextField.text, let bottomText = bottomTextField.text {
            
            memeArray.insert((image: image, topText: topText, bottomText: bottomText), atIndex: 0)
            tableView.reloadData()
            
            topTextField.text = nil
            bottomTextField.text = nil
            imageView.image = nil
            
            var arrayToSave:[[AnyObject]] = []
            for meme in memeArray {
                let objectArray:[AnyObject] = [UIImagePNGRepresentation(meme.image)!, meme.topText, meme.bottomText]
                arrayToSave += [objectArray]
            }
            
            NSUserDefaults.standardUserDefaults().setValue(arrayToSave, forKey: "meme_array")
            
        }
    }
    
    @IBAction func textFieldFinished(sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memeArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MemeCell", forIndexPath: indexPath) 
        cell.imageView?.image = memeArray[indexPath.row].image
        cell.textLabel?.text = "+ \"\(memeArray[indexPath.row].topText)\" + \"\(memeArray[indexPath.row].bottomText)\""
        cell.textLabel?.numberOfLines = 4
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("ShowMeme", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "ShowMeme") {
            if let row = tableView.indexPathForSelectedRow?.row {
                let vc = segue.destinationViewController as! MemeViewController
                vc.topText = memeArray[row].topText
                vc.bottomText = memeArray[row].bottomText
                vc.image = memeArray[row].image
            }
        }
    }
}
