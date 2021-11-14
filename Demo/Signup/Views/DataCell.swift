//
//  DataCell.swift
//  Demo
//
//  Created by Jamil on 08/11/21.
//

import UIKit

class DataCell: UITableViewCell {

    @IBOutlet weak var bgView   : UIView!
    @IBOutlet weak var dataTitle: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        bgView.layer.borderWidth  = 0.5
        bgView.layer.cornerRadius = 10.0
        
        bgView.layer.borderColor = UIColor.gray.cgColor
        bgView.backgroundColor  = .white
        self.backgroundColor = kBgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
   }
}
