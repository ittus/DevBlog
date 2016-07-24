//
//  FeedVC.swift
//  DevBlog
//
//  Created by Minh Thang Vu on 7/17/16.
//  Copyright © 2016 Minh Thang Vu. All rights reserved.
//

import UIKit
import Firebase
import Alamofire

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var txtPOst: MaterialTextField!
    
    @IBOutlet weak var ivImageSelected: UIImageView!
    
    var posts = [Post]()
    static var imageCache = NSCache()
    var imageSelected = false
    
    var imagePicker: UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = 393
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        DataService.ds.REF_POSTS.observeEventType(FIRDataEventType.Value, withBlock: { (snapshot) in
            print(snapshot.value)
            
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshots {
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let post = Post(postKey: key, dictionary: postDict)
                        self.posts.append(post)
                    }
                }
            }
            
            self.tableView.reloadData()
        })
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]
        print(post.postDescription)
        if let cell = tableView.dequeueReusableCellWithIdentifier("postCell") as? PostCell {
            
            cell.request?.cancel()
            
            var img: UIImage?
            
            if let url = post.imageUrl {
                img = FeedVC.imageCache.objectForKey(url) as? UIImage
            }
            cell.configureCell(post, img: img)
            return cell
        } else {
            return PostCell()
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let post = posts[indexPath.row]
        
        if post.imageUrl == nil {
            return 200
        } else {
            return tableView.estimatedRowHeight
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        ivImageSelected.image = image
        imageSelected = true
    }
    
    @IBAction func selectImageTap(sender: UITapGestureRecognizer) {
        presentViewController(imagePicker, animated: true, completion: nil)
        
        
    }
    @IBAction func postButtonPressed(sender: UIButton) {
        if let txt = txtPOst.text where txt != "" {
            if let img = ivImageSelected.image where imageSelected == true {
                // TODO: Make sure image is not camera image
                let urlStr = "https://post.imageshack.us/upload_api.php"
                let url = NSURL(string: urlStr)!
                let imgData = UIImageJPEGRepresentation(img, 0.2)!

                let keyData = ""
                .dataUsingEncoding(NSUTF8StringEncoding)!
                
                let keyJSON = "json".dataUsingEncoding(NSUTF8StringEncoding)!
                
                Alamofire.upload(.POST, url, multipartFormData: { (multipartFormData: MultipartFormData) in
                    multipartFormData.appendBodyPart(data: imgData, name: "fileupload", fileName: "image", mimeType: "image/jpg")
                    multipartFormData.appendBodyPart(data: keyData, name: "key")
                    multipartFormData.appendBodyPart(data: keyJSON, name: "format")
                    }, encodingCompletion: { (encodeResult: Manager.MultipartFormDataEncodingResult) in
                        switch encodeResult {
                        case .Success(let upload, _ , _):
                            upload.responseJSON(completionHandler: { (response: Response<AnyObject, NSError>) in
                                if let info = response.result.value as? Dictionary<String, AnyObject> {
                                    if let links = info["links"] as? Dictionary<String, AnyObject> {
                                        if let imgLink = links["image_link"] as? String {
                                            print("Link \(imgLink)")
                                            self.postToFirebase(imgLink)
                                        }
                                    }
                                }
                            })
                        case .Failure(let error):
                            print(error)
                        }
                })
                
            } else {
                self.postToFirebase(nil)
            }
        }
    }
    
    func postToFirebase(imgUrl: String?) {
        var posts: Dictionary<String, AnyObject> = [
            "description": txtPOst.text!,
            "likes": 0
        ]
        
        if imgUrl != nil {
            posts["imageUrl"] = imgUrl!
        }
        
        let newPost = DataService.ds.REF_POSTS.childByAutoId()
        newPost.setValue(posts)
        
        txtPOst.text = ""
        ivImageSelected.image = UIImage(named: "camera")
        imageSelected = false
        
        tableView.reloadData()
    }
    
    
    
}
