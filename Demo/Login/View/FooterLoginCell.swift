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
    @IBOutlet weak var nextButton: UIButton!

    var onAction: ((_ button: UIButton) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = .clear
        
        //set color yellow
        termsLabel.attributedText = getAttributedText(termsLabel.text ?? "" , "登録はどちら", kYellowColor)
    }
    
    @IBAction func buttonAction(sender:UIButton){
        self.onAction?(sender)
    }
}
