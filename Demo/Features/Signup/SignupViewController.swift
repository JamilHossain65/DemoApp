//
//  SignupViewController.swift
//  Demo
//
//  Created by Jamil on 08/11/21.
//

import UIKit
import Firebase

class SignupViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var dataArray:[AnyObject] = []
    
    let signupModel = SignupModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set header title
        self.title = "アカウント登録"
        self.view.backgroundColor = kBgColor
        
        //ui test
        /*
        let window = UIApplication.shared.windows.last!
            //= UIColor.init(patternImage: UIImage(named: "signup")!)
        
        let imageView = UIImageView(image: UIImage(named: "signup")!)
        
        print("window::\(window.frame)")
        imageView.frame = window.frame
        imageView.alpha = 0.5
        self.view.addSubview(imageView)
        */
        
        //set navigation bar color and text
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: kTitleTextColor]
        //navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.setBackgroundImage(UIImage(named:"nav_bar"), for: .default)
        
        let indexButton = UIBarButtonItem(title: "1/3", style: .plain, target: self, action: #selector(rightBarButtonAction))
        indexButton.setTitleTextAttributes([.foregroundColor: kTitleTextColor], for: .normal)
        navigationItem.rightBarButtonItem = indexButton
        
        
        //set tableview data source and delegate to this view
        tableView.dataSource = self
        tableView.delegate   = self
        
        //set cell seperator none
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.allowsSelection = false
        tableView.showsVerticalScrollIndicator = false
        
        //register tableview cell
        registerCell("TextInputCell")
        registerCell("ButtonCell")
        registerCell("FooterCell")
        
        //add input data mannually
        addDataMannually()
    }
    
    func addDataMannually(){
        //add name
        var inputData = InputData()
        inputData.title = "氏名"
        inputData.placeholder = "壮名"
        dataArray.append(inputData)
        
        //add email
        inputData = InputData()
        inputData.title = "メールアドレス"
        inputData.placeholder = "メールアドレス"
        dataArray.append(inputData)
        
        //add password
        inputData = InputData()
        inputData.title = "バスワード"
        inputData.placeholder = "半角英数数字、記号 8文字以上"
        dataArray.append(inputData)
        
        //add create button
        let buttonCell = ButtonCell()
        dataArray.append(buttonCell)
        
        //add create button
        let footerCell = FooterCell()
        dataArray.append(footerCell)
    }
    
    @objc func rightBarButtonAction(){
        print("rightBarButtonAction")
    }
    
    /*
    func refreshData() {
        //request api data from sever
        self.view.showProgressHUD()
        fetchDataForPage(currentPageIndex, completion: { responseDataArray in
            self.view.hideProgressHUD()
            
            self.dataArray += responseDataArray
            
            self.currentPageIndex += 1
            self.refreshControl.endRefreshing()
            self.tableView.reloadData()
            log("\n data count :\(String(describing: self.dataArray.count))")
        })
    }
    
    */
}

//MARK: ==== Table View ====
extension SignupViewController: UITableViewDataSource, UITableViewDelegate{
    
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
        if data.isKind(of: FooterCell.self){ return 200.scaleh() }
        if data.isKind(of: ButtonCell.self){ return 80.scaleh() }
        
        return 85.scaleh()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = dataArray[indexPath.row]
        
        if data.isKind(of: ButtonCell.self){
            let cell = tableView.dequeueReusableCell(withIdentifier: "ButtonCell", for: indexPath) as! ButtonCell
            
            if let _titleButton = (data as! ButtonCell).titleButton {
                cell.titleButton.titleLabel?.text = _titleButton.titleLabel?.text
            }
            
            cell.titleButton.setTitle("次へ", for: .normal)
            
            //action on button
            cell.onAction = { button in
                self.view.showProgressHUD()
                
                let email = self.signupModel.email    ?? ""
                let pass  = self.signupModel.password ?? ""
                print("email:\(email)")
                print("pass:\(pass)")
                
                
                Auth.auth().createUser(withEmail: email, password:pass ) { authResult, error in
                    self.view.hideProgressHUD()
                    
                    if error != nil {
                        showAlertOkay(title: "Can' login", message: error?.localizedDescription , completion: {_ in})
                    }else{
                        self.showLoginView()
                    }
                }
                
            }
            
            return cell
        } else if data.isKind(of: InputData.self) {
            //Cell type TextField
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextInputCell", for: indexPath) as! TextInputCell

            if let _data = data as? InputData {
                if let _title = _data.title {
                    cell.titleLabel.text = _title
                }
            }
            
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
                case 0:
                    print("name:\(textField?.text)")
                    self.signupModel.name = textField?.text
                case 1:
                    print("email:\(textField?.text)")
                    self.signupModel.email = textField?.text
                default:
                    print("pass:\(textField?.text)")
                    self.signupModel.password = textField?.text
                }
            }
            return cell
        } else if data.isKind(of: FooterCell.self){
            //Cell type footer
            let cell = tableView.dequeueReusableCell(withIdentifier: "FooterCell", for: indexPath) as! FooterCell
            
            //action on button
            cell.onAction = { button in
                self.showLoginView()
            }
            
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func showLoginView(){
        let storyboard: UIStoryboard = UIStoryboard.init(name: "Main",bundle: nil);
        let viewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
