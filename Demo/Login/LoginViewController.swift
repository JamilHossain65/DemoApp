//
//  LoginViewController.swift
//  Demo
//
//  Created by Jamil on 11/11/21.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var dataArray:[AnyObject] = []
    let loginModel = LoginModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //set bg color and navigation bar hidden
        self.view.backgroundColor = kBgColor
        self.navigationController?.isNavigationBarHidden = true
        
        /*
        //test UI
        let window = UIApplication.shared.windows.last!
        let imageView = UIImageView(image: UIImage(named: "login")!)
        
        print("window::\(window.frame)")
        imageView.frame = window.frame
        imageView.alpha = 0.5
        self.view.addSubview(imageView)
        */
        
        //set tableview data source and delegate to this view
        tableView.dataSource = self
        tableView.delegate   = self
        
        //set cell seperator none
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.allowsSelection = false
        tableView.showsVerticalScrollIndicator = false
        
        //register tableview cell
        registerCell("LogoCell")
        registerCell("TextInputLoginCell")
        registerCell("ButtonCell")
        registerCell("TextLabelCell")
        registerCell("FooterLoginCell")
        
        //add input data mannually
        addDataMannually()
    }
    
    func addDataMannually(){
        
        //add logo
        let logoCell = LogoCell()
        dataArray.append(logoCell)
        
        //add name
        var inputData = InputData()
        inputData.placeholder = "メールアドレス"
        dataArray.append(inputData)
        
        //add email
        inputData = InputData()
        inputData.placeholder = "バスワード"
        dataArray.append(inputData)
        
        //add data button
        let dataCell = TextLabelCell()
        //TextLabelCell.dataTitle.text  = "Jamil"
        dataArray.append(dataCell)
        
        //add login button
        let buttonCell = ButtonCell()
        dataArray.append(buttonCell)
        
        //add footer view
        let footerCell = FooterLoginCell()
        dataArray.append(footerCell)
    }
    
    @objc func rightBarButtonAction(){
        print("rightBarButtonAction") //todo
    }
}

//MARK: ==== Table View ====
extension LoginViewController: UITableViewDataSource, UITableViewDelegate{
    
    func registerCell(_ className:String) {
        let identifer = className
        let nib = UINib(nibName: identifer, bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier:identifer)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let data = dataArray[indexPath.row]
        
        //return cell height
        if data.isKind(of: LogoCell.self){ return 125.scaleh() }
        if data.isKind(of: TextLabelCell.self){ return 23.scaleh() }
        if data.isKind(of: ButtonCell.self){ return 90.scaleh() }
        if data.isKind(of: FooterLoginCell.self){ return 200.scaleh() }
        
        return 52.scaleh()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = dataArray[indexPath.row]
        
        if data.isKind(of: LogoCell.self){
            let cell = tableView.dequeueReusableCell(withIdentifier: "LogoCell", for: indexPath) as! LogoCell
            return cell
        } else if data.isKind(of: InputData.self) {
            //Cell type TextField
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextInputLoginCell", for: indexPath) as! TextInputLoginCell
            
            cell.backgroundColor = kBgColor
            cell.inputField.attributedPlaceholder = NSAttributedString(
                string: (data as! InputData).placeholder ?? "",
                attributes: [NSAttributedString.Key.foregroundColor: kPlaceholderTextColor]
            )
            
            cell.inputField.layer.cornerRadius = 10.0
            
            cell.inputField.tag = indexPath.row
            cell.accesorryButton.isHidden = indexPath.row == 2 ? false:true
            cell.inputField.isSecureTextEntry = indexPath.row == 2 ? true:false
            
            //action on button
            cell.onAction = { button in
                cell.inputField.isSecureTextEntry = button.isSelected
                button.isSelected = !button.isSelected
            }
            
            //text editing end
            cell.didCompleteEdit = {textField in
                
                switch textField?.tag {
                case 1:
                    self.loginModel.email = textField?.text
                    print("email: \(self.loginModel.email)")
                default:
                    self.loginModel.password = textField?.text
                    print("pass: \(self.loginModel.password)")
                }
            }
            return cell
        } else if data.isKind(of: TextLabelCell.self){
            //Cell type footer
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextLabelCell", for: indexPath) as! TextLabelCell
            return cell
        } else if data.isKind(of: ButtonCell.self){
            let cell = tableView.dequeueReusableCell(withIdentifier: "ButtonCell", for: indexPath) as! ButtonCell
            
            if let _titleButton = (data as! ButtonCell).titleButton {
                cell.titleButton.titleLabel?.text = _titleButton.titleLabel?.text
            }
            
            cell.titleButton.setTitle("ログイン", for: .normal)
            
            //action on button
            cell.onAction = { button in

                /*
                 let firebaseAuth = Auth.auth()
             do {
               try firebaseAuth.signOut()
             } catch let signOutError as NSError {
               print("Error signing out: %@", signOutError)
             }
                 */
                self.view.showProgressHUD()
                if let email = self.loginModel.email, let pass = self.loginModel.password {
                    Auth.auth().signIn(withEmail: email, password: pass) { authResult, error in
                        self.view.hideProgressHUD()
                        
                        if error != nil {
                            showAlertOkay(title: "Can't login", message: error?.localizedDescription , completion: {_ in})
                        }else{
                            //show map view
                            self.showMapView()
                        }
                    }
                }
                
                
                
                
            }
            
            return cell
        } else if data.isKind(of: FooterLoginCell.self){
            //Cell type footer
            let cell = tableView.dequeueReusableCell(withIdentifier: "FooterLoginCell", for: indexPath) as! FooterLoginCell
            
            //action on button
            cell.onAction = { button in
                //show signup view
                self.navigationController?.popViewController(animated: false)
            }
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func showMapView(){
        let storyboard: UIStoryboard = UIStoryboard.init(name: "Main",bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
