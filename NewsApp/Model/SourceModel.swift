//
//  SourceModel.swift
//  NewsApp
//
//  Created by Ziyomukhammad Usmonov on 04/03/2024.
//

import Foundation


struct SourceModel : Codable {
    
    let id : String?
    let name : String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try values.decodeIfPresent(String.self, forKey: .id)
        name = try values.decodeIfPresent(String.self, forKey: .name)
    }
}
