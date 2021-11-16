//
//  TextLabelCell.swift
//  Demo
//
//  Created by Jamil on 08/11/21.
//

import UIKit

class TextLabelCell: UITableViewCell {

    @IBOutlet weak var textLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        
        //set font
        textLbl.font = UIFont.boldSystemFont(ofSize: 13.scalef())
    }
}
