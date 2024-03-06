//
//  TopHeadlinesViewModel.swift
//  NewsApp
//
//  Created by Ziyomukhammad Usmonov on 04/03/2024.
//

import Foundation
import CoreData
import UIKit

class TopHeadlinesViewModel {
    
    static let shared = TopHeadlinesViewModel()
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func getHeadlines(query: String, completion: @escaping (NewsModel) -> ()) {
        
        let params = ["q": query == "" ? "tesla" : query,
                      "sort": "publishedAt",
                      "apiKey": "1ff672c82b974a0bb99b9ef963a1e115"]
        
        let apiManager = ApiManager()
        let url = ApiUrls.baseUrl
        
        apiManager.WebServiceURLEncoded(url: url, parameter: params, of: NewsModel.self, method: .get, encoding: .queryString, { responseData in
            completion(responseData ?? NewsModel())
        }) { error in
            completion(NewsModel())
            print("error")
        }
    }
    
    func addToSavedList(news: DetailsModel?, completion: @escaping (Bool) -> Void) {
        
        let db = SavedNews(context: self.context)
        
        db.username = UserDefaults.standard.value(forKey: "username") as? String ?? ""
        db.id = news?.id
        db.name = news?.name
        db.author = news?.author
        db.content = news?.content
        db.desc = news?.description
        db.publishedAt = news?.publishedAt
        db.title = news?.title
        db.url = news?.url
        db.urlToImage = news?.urlToImage
        
        do {
            try context.save()
            completion(true)
        } catch {
            print(error.localizedDescription)
            completion(false)
        }
    }
    
    func getAllSaved() -> [SavedNews] {
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        guard let username = UserDefaults.standard.value(forKey: "username") as? String else { return [] }
        
        let fetchRequest: NSFetchRequest<SavedNews> = SavedNews.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "username == %@", username)
        
        do {
            let results = try context.fetch(fetchRequest)
            return results
        } catch {
            print("Error checking if item is saved: \(error)")
            return []
        }
    }
    
    func convertArticalModelToDetailsModel(news: ArticlesModel) -> DetailsModel {
        
        var details = DetailsModel()
        details.id = news.source?.id
        details.name = news.source?.name
        details.author = news.author
        details.title = news.title
        details.description = news.description
        details.url = news.url
        details.urlToImage = news.urlToImage
        details.publishedAt = news.publishedAt
        details.content = news.content
        
        return details
    }
    
    func convertSavedModelToDetailsModel(news: SavedNews) -> DetailsModel {
        
        var details = DetailsModel()
        details.id = news.id
        details.name = news.name
        details.author = news.author
        details.title = news.title
        details.description = news.description
        details.url = news.url
        details.urlToImage = news.urlToImage
        details.publishedAt = news.publishedAt
        details.content = news.content
        
        return details
    }
}
