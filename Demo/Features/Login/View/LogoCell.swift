//
//  DataCell.swift
//  Demo
//
//  Created by Jamil on 08/11/21.
//

import UIKit

class LogoCell: UITableViewCell {

    @IBOutlet weak var logoButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = kBgColor
//        var mFrame = logoButton.frame
//        print("frame:\(mFrame)")
//        mFrame.size.width  = mFrame.size.width.scale()
//        mFrame.size.height = mFrame.size.height.scaleh()
//        print("mframe:\(mFrame)")
//        logoButton.center = self.center
//        logoButton.frame  = mFrame
    }
}

