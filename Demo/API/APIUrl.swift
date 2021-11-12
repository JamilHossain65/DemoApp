//
//  APIUrl.swift
//  Demo
//
//  Created by Jamil on 08/11/21.
//

import UIKit


// BASE URL
#if DEBUG
  //set Debug Mode url
  let BASE_URL = "https://jsonplaceholder.typicode.com"
#else
  //set Production Mode url
  //let BASE_URL = "https://jsonplaceholder.typicode.com"
#endif

//API
let API_DATA_LIST  = "/todos/"


//LOGIN
let API_LOGIN = "/login/"
let API_TEST  = "/test/"
let API_TEST2 = "/test2/"

let API_TRANSLATE      = "/convert/voice/lang/"
//"/convert/voice/lang/"
let BASE_URL_TRANSLATE = "http://jamilhossain.pythonanywhere.com"


