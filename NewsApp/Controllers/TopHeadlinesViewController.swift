//
//  TopHeadlinesViewController.swift
//  NewsApp
//
//  Created by Ziyomukhammad Usmonov on 04/03/2024.
//

import UIKit
import CoreData

class TopHeadlinesViewController: UIViewController {
    
    private let profileButton: UIButton = {
        let username = UserDefaults.standard.value(forKey: "username") as? String ?? ""
        let first = String(username.first!)
        
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
        button.setTitle(first.capitalized, for: .normal)
        button.setTitleColor(.darkGray, for: .normal)
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 16
        button.layer.borderColor = UIColor.darkGray.cgColor
        
        return button
    }()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search News..."
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(NewsTableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private var newsList: [ArticlesModel] = []
    private  var filteredNewsList: [ArticlesModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        layout()
        getTopHeadlines()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = false
    }
    
    private func configureView() {
        self.navigationItem.title = "Search"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: profileButton)
        let logoutButton = UIBarButtonItem(image: UIImage(named: "Logout"), style: .plain, target: self, action: #selector(self.logoutClicked(_ :)))
        self.navigationItem.rightBarButtonItem = logoutButton
    }
    
    private func layout() {
        view.addSubview(searchBar)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func getTopHeadlines() {
        TopHeadlinesViewModel.shared.getHeadlines(query: "") { result in
            self.newsList = result.articles ?? []
            self.filteredNewsList = self.newsList
            self.tableView.reloadData()
        }
    }
    
    @objc private func saveButtonTapped(sender: UIButton) -> Void {
        let news = newsList[sender.tag]
        if self.checkIsSaved(id: news.description) {
            self.deleteItem(id: news.description)
            self.showAlert(str: "Removed successfully")
            self.tableView.reloadData()
        } else {
            let news1 = TopHeadlinesViewModel.shared.convertArticalModelToDetailsModel(news: news)
            TopHeadlinesViewModel.shared.addToSavedList(news: news1) { success in
                if success {
                    self.showAlert(str: "Saved successfully")
                    self.tableView.reloadData()
                }else {
                    self.showAlert(str: "Saved Faield")
                }
            }
        }
    }
    
    
    private func showAlert(str: String) -> Void {
        let alert = UIAlertController(title: "", message: str, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc private func logoutClicked(_ sender: UIBarButtonItem) -> Void {
        let alert = UIAlertController(title: "Alert", message: "Are you sure you want to logout?", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.destructive, handler: { action in
            UserDefaults.standard.removeObject(forKey: "username")
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            self.navigationController?.pushViewController(vc, animated: true)
        }))
        alert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}


extension TopHeadlinesViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        TopHeadlinesViewModel.shared.getHeadlines(query: searchText) { result in
            self.newsList = result.articles ?? []
            self.filteredNewsList = self.newsList
            self.tableView.reloadData()
        }
    }
}


extension TopHeadlinesViewController: UITableViewDataSource, UITableViewDelegate {    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredNewsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! NewsTableViewCell
        let news = filteredNewsList[indexPath.row]
        cell.news = news
        
        if self.checkIsSaved(id: news.description) {
            cell.saveButton.tintColor = .black
        }else {
            cell.saveButton.tintColor = .lightGray
        }
        
        cell.saveButton.tag = indexPath.row
        cell.saveButton.addTarget(self, action: #selector(saveButtonTapped(sender: )), for: .touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "NewsDetailsViewController") as! NewsDetailsViewController
        let news = filteredNewsList[indexPath.row]
        let news1 = TopHeadlinesViewModel.shared.convertArticalModelToDetailsModel(news: news)
        vc.news = news1
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
