//
//  RoundButton.swift
//  HR Monitor App
//
//  Created by Zackarin Necesito on 3/5/19.
//  Copyright © 2019 Zack Necesito. All rights reserved.
//

import UIKit

var cornerRadius: CGFloat = 15 {
    didSet {
        refreshCorners(value: cornerRadius)
    }
}

@IBDesignable class RoundButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    override func prepareForInterfaceBuilder() {
        sharedInit()
    }
    
    func sharedInit() {
        // Common logic goes here
    }
    
    func refreshCorners(value: CGFloat) {
        layer.cornerRadius = value
    }
    
}
