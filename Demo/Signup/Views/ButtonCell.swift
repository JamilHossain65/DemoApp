//
//  DataCell.swift
//  Demo
//
//  Created by Jamil on 08/11/21.
//

import UIKit

class ButtonCell: UITableViewCell {

    @IBOutlet weak var bgView   : UIView!
    @IBOutlet weak var titleButton: UIButton!
    var title:String = ""
    var selectedTitle:String = ""
    
    //var onAction: (() -> ())?
    var onAction: ((_ button: UIButton) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.backgroundColor = kBgColor
        
        if let _titleButton = titleButton {
            _titleButton.setTitle(title, for: .normal)
            _titleButton.setTitle(selectedTitle, for: .selected)
            _titleButton.setTitleColor(kBgColor, for: .normal)
            
            //set font
            _titleButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16.scalef())
            
//            bgView.layer.borderWidth  = 0.0
//            bgView.layer.cornerRadius = 10.0
//            bgView.layer.borderColor = kBgColor.cgColor
            bgView.backgroundColor  = kBgColor
            
            _titleButton.layer.borderWidth  = 0.5
            _titleButton.layer.cornerRadius = 10.0
            _titleButton.layer.borderColor = kYellowColor.cgColor
            _titleButton.backgroundColor  = kYellowColor
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
   }
    
    @IBAction func buttonAction(sender:UIButton){
        self.onAction?(sender)
    }
}

