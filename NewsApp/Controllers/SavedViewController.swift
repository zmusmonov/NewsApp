//
//  SavedViewController.swift
//  NewsApp
//
//  Created by Ziyomukhammad Usmonov on 05/03/2024.
//

import UIKit
import CoreData

class SavedViewController: UIViewController {
    
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
    
    private let logoutButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(named: "Logout"), style: .plain, target: nil, action: nil)
        return button
    }()
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search News..."
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(SavedTableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    private var savedList: [SavedNews] = []
    private var filteredSavedList: [SavedNews] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        layout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        savedList = TopHeadlinesViewModel.shared.getAllSaved()
        filteredSavedList = savedList
        searchBar.text = ""
        self.tableView.reloadData()
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
    
    @objc private func saveButtonTapped(sender: UIButton) -> Void {
        let news = savedList[sender.tag]
        if self.checkIsSaved(id: news.desc) {
            self.deleteItem(id: news.desc)
            savedList = TopHeadlinesViewModel.shared.getAllSaved()
            filteredSavedList = savedList
            self.tableView.reloadData()
        }
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


extension SavedViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredSavedList = savedList
        if searchText != "" {
            let filtered = savedList.filter{ $0.name!.lowercased().contains(searchText.lowercased()) }
            filteredSavedList = filtered
        }
        tableView.reloadData()
    }
}

extension SavedViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredSavedList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SavedTableViewCell
        let news = filteredSavedList[indexPath.row]
        
        cell.news = news
        if self.checkIsSaved(id: news.desc) {
            cell.saveButton.tintColor = .black
        } else {
            cell.saveButton.tintColor = .lightGray
        }
        cell.saveButton.tag = indexPath.row
        cell.saveButton.addTarget(self, action: #selector(saveButtonTapped(sender: )), for: .touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "NewsDetailsViewController") as! NewsDetailsViewController
        let news = filteredSavedList[indexPath.row]
        let news1 = TopHeadlinesViewModel.shared.convertSavedModelToDetailsModel(news: news)
        vc.news = news1
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
