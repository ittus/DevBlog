//
//  MaterialButton.swift
//  DevBlog
//
//  Created by Minh Thang Vu on 7/16/16.
//  Copyright © 2016 Minh Thang Vu. All rights reserved.
//

import UIKit

class MaterialButton: UIButton {
    override func awakeFromNib() {
        layer.cornerRadius = 2.0
        layer.shadowColor = UIColor(red: SHADOW_COLOR, green: SHADOW_COLOR, blue: SHADOW_COLOR, alpha: 0.5).CGColor
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 5.0
        layer.shadowOffset = CGSize(width: 0, height: 2)
    }
}
