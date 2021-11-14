//
//  DataCell.swift
//  Demo
//
//  Created by Jamil on 08/11/21.
//

import UIKit

class FooterCell: UITableViewCell {

    @IBOutlet weak var bgView    : UIView!
    @IBOutlet weak var dataLabel : UILabel!
    @IBOutlet weak var agreeLabel: UILabel!
    @IBOutlet weak var termsLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    
    var onAction: ((_ button: UIButton) -> Void)?

    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = .clear
        
        //set attributed color
        agreeLabel.attributedText = getAttributedText(agreeLabel.text ?? "" , "  I  ", kPlaceholderTextColor)
        
        termsLabel.attributedText = getAttributedText(termsLabel.text ?? "" , "ログイン", kYellowColor)
    }

    @IBAction func buttonAction(sender:UIButton){
        self.onAction?(sender)
    }
}
