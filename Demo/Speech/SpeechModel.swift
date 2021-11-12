//
//  SpeechModel.swift
//  Demo
//
//  Created by Jamil on 2/3/21.
//

import UIKit

class SpeechModel {
    static let sharedModel = SpeechModel()
    var convertedText:String = ""
    var fileUrl:URL?
    
    func doTranslate2(_ completion: @escaping (Errors?) -> ()) {
        doTranslateRequest2(completion: completion)
    }
    
    func doTranslateRequest2(completion: @escaping (Errors?) -> ()) {
        var params:[String:Any] = [:]
        params[APIKey.file_url] = self.fileUrl
        let header = [APIKey.content_type:APIKey.multipart_form]
        let method = APIKey.POST
        let url = BASE_URL_TRANSLATE + API_TRANSLATE
        
        
        self.requestMultipartForm(url,method,header,params) { (result, error) in
            DispatchQueue.main.async {
                if let _result = result {
                    //todo refactor this line
                    let response = _result as? [String:Any]
                    self.convertedText = response?[APIKey.converted_text] as? String ?? ""
                    completion(nil)
                } else {
                    let _error = Errors(message: error?.localizedDescription)
                    completion(_error)
                }
            }
        }
    }
    
    //do request if params are inside of url request body
    func requestMultipartFormData(url: String, method: String?, header: [String:String]?, params: [String:Any]?, completion: @escaping(Any?, Error?) -> ()){
        requestMultipartForm(url, method, header, params, completion: completion)
    }
    
    //do request if params are inside of url request body
    func requestMultipartForm(_ url: String, _ method: String?, _ header: [String:String]?, _ params: [String:Any]?, completion: @escaping(Response?, Error?) -> ()) {
        
        //check internet
        if !Reachability.isConnectedToNetwork() {
            //ProgressHUD.shared.hide()
            //showAlertOkay(message: "Not connected to the internet")
            return
        }
        
        // debug print
        if let _header = header {
            print("[REQUEST HEADER]: \(_header)")
        }
        
        if let _param = params {
            print("[REQUEST PARAM]: \(_param)")
        }
        
        print("[REQUEST URL]: \(url)")
        
        /*
        let filename = "hello (16bit PCM).wav"//"good-morning-google.flac" //"hello (16bit PCM).wav"
        let fileUrl = Bundle.main.path(forResource: filename, ofType: nil)
        guard let data = try? Data(contentsOf:URL(fileURLWithPath:fileUrl!)) else { return }
        
        */
        
        let filename = "recording.flac"
        let fileUrl:URL = params?[APIKey.file_url] as! URL
        guard let data = try? Data(contentsOf:fileUrl) else { return }
        //print("fileUrl:: \(fileUrl)")
        
        let lang = params?[APIKey.language]
        
        let request = APIRequest(url)
        request.uploadFile(params: ["lang":lang ?? "en"] ,paramName: "file", fileName: filename, fileData: data, mimeType: "audio/wav",completion: { (response,error) in
            if let _response = response {
                let json = _response as? [String:Any]
                self.convertedText = json?[APIKey.converted_text] as? String ?? ""
                completion(Response(json),nil)
            } else {
                completion(nil,error)
            }
        })
    }
}
