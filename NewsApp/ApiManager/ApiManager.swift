//
//  ApiManager.swift
//  NewsApp
//
//  Created by Ziyomukhammad Usmonov on 04/03/2024.
//

import UIKit
import Alamofire

protocol ApiManagerProtocol {
    func onError(msg : String, name: String)
    func onSuccess(data : Data, name: String)
}

class ApiManager: NSObject {
    
    var delegate: Any? = nil
    var protocolmain_Catagory : ApiManagerProtocol! = nil
    static let sharedInstance = ApiManager()
    
    
    //MARK: Form URL encoded Data
    func WebServiceURLEncoded<T: Decodable>(url: String, parameter: Parameters?, of: T.Type, method: HTTPMethod, encoding: URLEncoding, _ onSuccess: @escaping(T?) -> Void, onFailure: @escaping(Error) -> Void) {
        
        var headers: HTTPHeaders = [:]
        let params = parameter
        
    
        headers = ["Content-Type": "application/x-www-form-urlencoded"]
        
        AF.request(url, method: method, parameters: params, encoding: URLEncoding.default, headers: headers).responseData { response in
            
            switch response.result {
            case .success(let data):
                do {
                    let response = try JSONDecoder().decode(T.self, from: response.data ?? Data())
                    onSuccess(response)
                } catch {
                    print("Error while decoding response: \(error) from: \(String(data: data, encoding: .utf8) ?? "")")
                    onFailure(error)
                }
            case .failure(let error):
                print("\n\n===========Error===========")
                print("Error Code: \(error._code)")
                print("Error Messsage: \(error.localizedDescription)")
                if let data = response.data, let str = String(data: data, encoding: String.Encoding.utf8){
                    print("Server Error: " + str)
                }
                debugPrint(error as Any)
                print("===========================\n\n")
                
                print("Failure\(error.localizedDescription)")
                onFailure(error)
            }
        }
    }
}
