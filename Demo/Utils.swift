//
//  Utils.swift
//  Demo
//
//  Created by Jamil on 08/11/21.
//

import UIKit
import MBProgressHUD

let kBgColor = UIColor.init(red: 28/255, green: 29/255, blue: 36/255, alpha: 1)
let kPlaceholderTextColor = UIColor.init(red: 69/255, green: 70/255, blue: 73/255, alpha: 1)
let kPlaceholderBgColor = UIColor.init(red: 22/255.0, green: 23/255.0, blue: 28/255.0, alpha: 1)
let kTitleTextColor = UIColor.init(red: 196/255, green: 197/255, blue: 198/255, alpha: 1)
let kYellowColor = UIColor.init(red: 255/255, green: 159/255, blue: 73/255, alpha: 1)

//set aspect ration for various size ios devices
let baseW:CGFloat = 320
let baseH:CGFloat = 568

func log(_ msg: Any?) {
    #if DEBUG
    if let _msg = msg { print(String(describing: _msg)) }
    #endif
}

func showAlertOkay(title: String? = "", message:String? = "", completion: @escaping (Bool) -> () = {_ in}) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    //alert.view.tintColor = UIColor.hex_17181a()
    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (_) in
        completion(true)
    }))

    let window = UIApplication.shared.keyWindow
    window?.rootViewController?.present(alert, animated: true, completion: nil)
}

func getAttributedText(_ mainText:String,_ targetedText:String,_  color:UIColor) -> NSMutableAttributedString {
    let range = mainText.range(of: targetedText)!
    
    let mutableAttributedString = NSMutableAttributedString.init(string: mainText)
    mutableAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: NSRange(range, in: mainText))
    return mutableAttributedString
}

/*
//Fetch data from api for current page
func fetchDataForPage(_ index:Int, completion: @escaping([Data1]) -> ()) {
    //request api data from sever
    let dataModel = DataModel()
    dataModel.userId = index
    
    //self.view.showProgressHUD()
    dataModel.doDataRequest(completion: {(success,errorModel) in
        //self.view.hideProgressHUD()
        if let _dataArray = dataModel.dataArray {
            completion(_dataArray)
        }
    })
}
*/

//class Utils:NSObject{
//
//}

//MARK: - Extension
extension UIView{
    func showProgressHUD(){
        let hud = MBProgressHUD.showAdded(to: self, animated: true)
        hud.label.text = ""
        hud.isUserInteractionEnabled = false
    }
    
    func hideProgressHUD(){
        MBProgressHUD.hide(for: self, animated: true)
    }
}

//maintain aspect ration of various device size by this extention method
extension Int{
    func scale() -> CGFloat {
        return CGFloat(self)*(UIScreen.main.bounds.width/baseW)
    }
    
    func scaleh() -> CGFloat {
        return CGFloat(self)*(UIScreen.main.bounds.height/baseH)
    }
}

extension CGFloat{
    func scale() -> CGFloat {
        return CGFloat(self)*(UIScreen.main.bounds.width/baseW)
    }
    
    func scaleh() -> CGFloat {
        return CGFloat(self)*(UIScreen.main.bounds.height/baseH)
    }
}

extension Double{
    func scale() -> CGFloat {
        return CGFloat(self)*(UIScreen.main.bounds.width/baseW)
    }
    
    func scaleh() -> CGFloat {
        return CGFloat(self)*(UIScreen.main.bounds.height/baseH)
    }
}
