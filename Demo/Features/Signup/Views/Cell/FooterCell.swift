//
//  DataCell.swift
//  Demo
//
//  Created by Jamil on 08/11/21.
//

import UIKit

class FooterCell: UITableViewCell {

    @IBOutlet weak var bgView   : UIView!
    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var agreeLabel: UILabel!
    @IBOutlet weak var termsLabel: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = .clear
        
        //set attributed color
        agreeLabel.attributedText = getAttributedText(agreeLabel.text ?? "" , "  I  ", kPlaceholderTextColor)
        
        termsLabel.attributedText = getAttributedText(termsLabel.text ?? "" , "ログイン", kYellowColor)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
   }
}
