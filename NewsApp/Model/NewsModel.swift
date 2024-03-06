//
//  NewsModel.swift
//  NewsApp
//
//  Created by Ziyomukhammad Usmonov on 04/03/2024.
//

import Foundation

struct NewsModel : Codable {
    
    var status : String?
    var totalResults : Int?
    var articles : [ArticlesModel]?
    
    init() {}
    
    enum CodingKeys: String, CodingKey {
        
        case status = "status"
        case totalResults = "totalResults"
        case articles = "articles"
    }
    
    init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        status = try values.decodeIfPresent(String.self, forKey: .status)
        totalResults = try values.decodeIfPresent(Int.self, forKey: .totalResults)
        articles = try values.decodeIfPresent([ArticlesModel].self, forKey: .articles)
    }
}
