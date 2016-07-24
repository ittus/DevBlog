//
//  PostCell.swift
//  DevBlog
//
//  Created by Minh Thang Vu on 7/17/16.
//  Copyright © 2016 Minh Thang Vu. All rights reserved.
//

import UIKit
import Alamofire
import Firebase

class PostCell: UITableViewCell {
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var showcaseImage: UIImageView!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var ivLike: UIImageView!
    
    var post: Post!
    var request: Request?
    var likeRef: FIRDatabaseReference!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: "likeTapped:")
        tap.numberOfTapsRequired = 1
        ivLike.addGestureRecognizer(tap)
        ivLike.userInteractionEnabled = true
    }
    
    override func drawRect(rect: CGRect) {
        profileImg.layer.cornerRadius = profileImg.frame.size.width / 2
        profileImg.clipsToBounds = true
        
        showcaseImage.clipsToBounds = true
    }
    
    func configureCell(post: Post, img: UIImage?) {
        self.post = post
        likeRef = DataService.ds.REF_USER_CURRENT.childByAppendingPath("likes").childByAppendingPath(post.postKey)
        
        self.descriptionText.text = post.postDescription
        self.likesLbl.text = "\(post.likes)"
        
        if post.imageUrl != nil {
            self.showcaseImage.hidden = false
            if img != nil {
                self.showcaseImage.image = img
            } else {
                request = Alamofire.request(.GET, post.imageUrl!).validate(contentType: ["image/*"]).response(completionHandler: { (request: NSURLRequest?, response: NSHTTPURLResponse?, data: NSData?, err: NSError?) in
                    if err == nil {
                        let img = UIImage(data: data!)!
                        self.showcaseImage.image = img
                        FeedVC.imageCache.setObject(img, forKey: self.post.imageUrl!)
                        
                        
                    } else {
                        print(err.debugDescription)
                    }
                });
            }
        } else {
            self.showcaseImage.hidden = true
        }
        
        
        likeRef.observeSingleEventOfType(.Value) { (snapshot: FIRDataSnapshot) in
            if let doesNotExist = snapshot.value as? NSNull {
                // not like yet
                self.ivLike.image = UIImage(named: "heart-empty") 
            } else {
                self.ivLike.image = UIImage(named: "heart-full")
            }
        }
        
    }
    
    func likeTapped(sender: UITapGestureRecognizer) {
        likeRef.observeSingleEventOfType(.Value) { (snapshot: FIRDataSnapshot) in
            if let doesNotExist = snapshot.value as? NSNull {
                // not like yet
                self.ivLike.image = UIImage(named: "heart-full")
                self.post.adjustLike(true)
                self.likeRef.setValue(true)
            } else {
                self.ivLike.image = UIImage(named: "heart-empty")
                self.post.adjustLike(false)
                self.likeRef.removeValue()
            }
        }
    }
}
