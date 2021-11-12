//
//  DataCell.swift
//  Demo
//
//  Created by Jamil on 08/11/21.
//

import UIKit

class TextInputLoginCell: UITableViewCell {

    @IBOutlet weak var bgView    : UIView!
    //@IBOutlet weak var titleLabel : UILabel!
    @IBOutlet weak var inputField : UITextField!
    @IBOutlet weak var accesorryButton: UIButton!

    var didCompleteEdit: ((UITextField?) -> Void)?
    var onAction: ((_ button: UIButton) -> Void)?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //set text color
        inputField.backgroundColor = kPlaceholderBgColor
        inputField.textColor = kTitleTextColor
        
        //coner radious
        //inputField.layer.cornerRadius = 10.0
        
        // Create left padding
        inputField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: inputField.frame.size.height))
        inputField.leftViewMode = .always
        
        //set delegate
        inputField.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
   }
    
    @IBAction func buttonAction(sender:UIButton){
        self.onAction?(sender)
    }
}


//MARK: - UITextFieldDelegate Methods
extension TextInputLoginCell : UITextFieldDelegate {
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        didCompleteEdit?(textField)
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true
    }
    
//    func textFieldShouldClear(_ textField: UITextField) -> Bool {
//        return true
//    }
}
