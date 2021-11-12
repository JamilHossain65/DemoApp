//
//  DataCell.swift
//  Demo
//
//  Created by Jamil on 08/11/21.
//

import UIKit

class FooterLoginCell: UITableViewCell {

    @IBOutlet weak var bgView   : UIView!
    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var agreeLabel: UILabel!
    @IBOutlet weak var termsLabel: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = .clear
        
        //set color yellow
        termsLabel.attributedText = getAttributedText(termsLabel.text ?? "" , "登録はどちら", kYellowColor)
    }
}
