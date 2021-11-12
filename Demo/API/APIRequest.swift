//
//  APIRequest.swift
//  Demo
//
//  Created by Jamil on 08/11/21.
//

import UIKit

enum Method {
    case GET, POST
}

enum MimeType {
    case Image, Audio
}

struct APIRequest {
    private let boundary: String = UUID().uuidString
    private var httpBody = NSMutableData()
    let url: URL

    init(_ url: String) {
        if let _url = URL(string: url){
            self.url = _url
        }else{
            self.url = URL(string: "")!
        }
    }
    
    //MARK:- REQUEST API WITH PARAMETERS
    func params(_ params:[String: Any], method:Method,header:String, completion:@escaping (Response?, Errors?) -> () ){
        //Debug Prints
        print("calling api....")

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, error == nil {
                let jsonData = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
                if let json = jsonData as? [String: Any] {
                    DispatchQueue.main.async {
                        completion(Response(json),nil)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    let message = error?.localizedDescription ?? ""
                    var errors = Errors(message: message)
                    errors.error_code = 0
                    completion(nil,errors)
                }
            }
        }
        task.resume()
    }
    
    /*func uploadFile(paramName: String, fileName: String, fileData: Data, mimeType:String,completion:@escaping (Any?, Error?) -> Void) {
        //https://stackoverflow.com/questions/41032678/upload-image-to-server-swift-3
        print("calling api.....")
        //let url = URL(string: "http://jamilhossain.pythonanywhere.com/test/file/")
        
        // generate boundary string using a unique per-app string
        let boundary = UUID().uuidString
        let session = URLSession.shared
        
        // Set the URLRequest to POST and to the specified URL
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        
        // Set Content-Type Header to multipart/form-data, this is equivalent to submitting form data with file upload in a web browser
        // And the boundary is also set here
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var data = Data()
        
        // Add the image data to the raw http request data
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"\(paramName)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)//image/png
        data.append(fileData)
        
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        // Send a POST request to the URL, with the data we created earlier
        session.uploadTask(with: urlRequest, from: data, completionHandler: { responseData, response, error in
            if error == nil {
                let jsonData = try? JSONSerialization.jsonObject(with: responseData!, options: .allowFragments)
                completion(jsonData,nil)
                if let json = jsonData as? [String: Any] {
                    print(json)
                }
            }else{
                completion(nil,error)
            }
        }).resume()
    }
    */
    
    func uploadFile(params: [String:Any],paramName:String, fileName: String, fileData: Data, mimeType:String,completion:@escaping (Any?, Error?) -> Void) {
        //https://stackoverflow.com/questions/41032678/upload-image-to-server-swift-3
        print("calling api.....")
        
        // generate boundary string using a unique per-app string
        let boundary = UUID().uuidString
        let session = URLSession.shared
        
        // Set the URLRequest to POST and to the specified URL
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 8
        
        
        // Set Content-Type Header to multipart/form-data, this is equivalent to submitting form data with file upload in a web browser
        // And the boundary is also set here
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var bodyData = Data()
        
        for (key, value) in params {
            //add param into body
            bodyData.NappendStringN("--\(boundary)")
            bodyData.appendStringNN("Content-Disposition: form-data; name=\(key)")//lang
            bodyData.appendString("\(value)")//bn
        }
        
        // Add the file data to the raw http request data
        bodyData.NappendStringN("--\(boundary)")
        bodyData.appendStringN("Content-Disposition: form-data; name=\"\(paramName)\"; filename=\"\(fileName)\"")
        bodyData.appendStringN("Content-Type: \(mimeType)")//image/png
        bodyData.appendString("\r\n")
        bodyData.append(fileData)
        bodyData.NappendStringN("--\(boundary)--")
        
        //let bodyData2 = bodyData.data(using: .utf8)
        //print("body::\(bodyData)")
        
        // Send a POST request to the URL, with the data we created earlier
        session.uploadTask(with: request, from: bodyData, completionHandler: { responseData, response, error in
            if error == nil {
                let jsonData = try? JSONSerialization.jsonObject(with: responseData!, options: .allowFragments)
                if let json = jsonData as? [String: Any] {
                    completion(json,nil)
                    print(json)
                }
            }else{
                completion(nil,error)
            }
        }).resume()
    }
    
    /*
    func asURLRequest() -> URLRequest {
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        httpBody.append("--\(boundary)--")
        //httpBody.appendString("--\(boundary)--")
        request.httpBody = httpBody as Data
        return request
    }
    */
    
    func addTextField(named name: String, value: String) {
        httpBody.append(textFormField(named: name, value: value))
    }
    
    private func textFormField(named name: String, value: String) -> String {
        var fieldString = "--\(boundary)\r\n"
        fieldString += "Content-Disposition: form-data; name=\"\(name)\"\r\n"
        fieldString += "Content-Type: text/plain; charset=ISO-8859-1\r\n"
        fieldString += "Content-Transfer-Encoding: 8bit\r\n"
        fieldString += "\r\n"
        fieldString += "\(value)\r\n"
        return fieldString
    }
    
    func addDataField(named name: String, data: Data, mimeType: String) {
        httpBody.append(dataFormField(named: name, data: data, mimeType: mimeType))
    }
    
    private func dataFormField(named name: String,
                               data: Data,
                               mimeType: String) -> Data {
        let fieldData = NSMutableData()
        
        fieldData.append("--\(boundary)\r\n")
        fieldData.append("Content-Disposition: form-data; name=\"\(name)\"\r\n")
        fieldData.append("Content-Type: \(mimeType)\r\n")
        fieldData.append("\r\n")
        fieldData.append(data)
        fieldData.append("\r\n")
        
        return fieldData as Data
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        //print("path::\(paths)")
        return paths[0]
    }
}

//MARK:- CONVERT STRING TO DATA
extension NSMutableData {
    func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            self.append(data)
        }
    }
}

extension Data {
    mutating func appendString(_ string: String) {
        if let data = "\(string)".data(using: .utf8) {
            self.append(data)
        }
    }
    
    mutating func NappendString(_ string: String) {
        if let data = "\r\n\(string)".data(using: .utf8) {
            self.append(data)
        }
    }

    mutating func appendStringN(_ string: String) {
        if let data = "\(string)\r\n".data(using: .utf8) {
            self.append(data)
        }
    }

    mutating func NappendStringN(_ string: String) {
        if let data = "\r\n\(string)\r\n".data(using: .utf8) {
            self.append(data)
        }
    }

    mutating func appendStringNN(_ string: String) {
        if let data = "\(string)\r\n\r\n".data(using: .utf8) {
            self.append(data)
        }
    }
}

