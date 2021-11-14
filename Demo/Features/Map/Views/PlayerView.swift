//
//  MarkerInfoView.swift
//  Demo
//

import UIKit

class PlayerView: UIView {
  
    @IBOutlet weak var placePhoto: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var nameLabel : UILabel!
    var onAction: ((_ button: UIButton) -> Void)?
    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }

    @IBAction func playButtonPressed(sender:UIButton){
        onAction?(sender)
    }
}
