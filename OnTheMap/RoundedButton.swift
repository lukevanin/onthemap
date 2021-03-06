//
//  RoundedButton.swift
//  OnTheMap
//
//  Created by Luke Van In on 2017/01/17.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import UIKit

class RoundedButton: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 4
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let diameter = min(bounds.width, bounds.height)
        layer.cornerRadius = diameter * 0.5
    }
}
