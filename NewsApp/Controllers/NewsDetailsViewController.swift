//
//  DetailsViewController.swift
//  NewsApp
//
//  Created by Ziyomukhammad Usmonov on 04/03/2024.
//

import UIKit
import SDWebImage
import CoreData

class NewsDetailsViewController: UIViewController {
    
    var news: DetailsModel?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private lazy var saveButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(savedBtnClicked(sender: )), for: .touchUpInside)
        return button
    }()
    
    private let scrollView : UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentInsetAdjustmentBehavior = .never
        return view
    }()
    
    private let contentView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let headerView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var imageView : UIImageView = {
        let imageView = UIImageView()
        let imgURL = news?.urlToImage ?? ""
        let url = URL(string: imgURL)
        imageView.sd_setImage(with: url, placeholderImage: UIImage(named: ""),options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
        })
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var closeButton : UIButton = {
        let closeButton = UIButton()
        closeButton.setTitle("X", for: .normal)
        closeButton.setTitleColor(.red, for: .normal)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(closeBtnClicked(sender: )), for: .touchUpInside)
        return closeButton
    }()
    
    private lazy var titleLbl : UILabel = {
        let titleLbl = UILabel()
        titleLbl.text = news?.title
        titleLbl.textColor = .white
        titleLbl.font = UIFont.boldSystemFont(ofSize: 24)
        titleLbl.numberOfLines = 0
        titleLbl.translatesAutoresizingMaskIntoConstraints = false
        return titleLbl
    }()
    
    private lazy var dateLabel : UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        if let dateString = news?.publishedAt {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            if let date = dateFormatter.date(from: dateString) {
                dateFormatter.dateFormat = "dd-MMM-yyyy"
                let formattedDate = dateFormatter.string(from: date)
                label.text = formattedDate
            } else {
                print("Invalid date format")
            }
        }
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        layout()
    }
    
    private func configureView() {
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }
    
    private let headerHorizontalStackView : UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var authorLabel : UILabel = {
        let label = UILabel()
        label.text = news?.author
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let horizontalStackView : UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var otherLabel : UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.text = news?.name
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let otherImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "folder.fill")
        imageView.tintColor = .black
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var descriptionLabel : UILabel = {
        let label = UILabel()
        label.text = news?.description ?? ""
        label.numberOfLines = 0
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private func layout() {
        let guide = view.safeAreaLayoutGuide
        
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: guide.topAnchor, constant: -60),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        scrollView.addSubview(contentView)
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        contentView.addSubview(headerView)
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 350),
            headerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        headerView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 0),
            imageView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 0),
            imageView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: 0),
            imageView.heightAnchor.constraint(equalToConstant: 350)
        ])
        
        if self.checkIsSaved(id: news?.description) {
            saveButton.tintColor = .black
        } else {
            saveButton.tintColor = .lightGray
        }
        
        headerView.addSubview(saveButton)
        NSLayoutConstraint.activate([
            saveButton.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 60),
            saveButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20)
        ])
        
        headerView.addSubview(closeButton)
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 60),
            closeButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20)
        ])
        
        headerView.addSubview(titleLbl)
        headerView.addSubview(headerHorizontalStackView)
        headerHorizontalStackView.addArrangedSubview(authorLabel)
        headerHorizontalStackView.addArrangedSubview(dateLabel)
        NSLayoutConstraint.activate([
            headerHorizontalStackView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -20),
            headerHorizontalStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            headerHorizontalStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
        
        NSLayoutConstraint.activate([
            titleLbl.bottomAnchor.constraint(equalTo: headerHorizontalStackView.topAnchor, constant: -30),
            titleLbl.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            titleLbl.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -50)
        ])
        
        contentView.addSubview(horizontalStackView)
        NSLayoutConstraint.activate([
            horizontalStackView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 20),
            horizontalStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            horizontalStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
        horizontalStackView.addArrangedSubview(otherLabel)
        horizontalStackView.addArrangedSubview(otherImageView)
        
        contentView.addSubview(descriptionLabel)
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: horizontalStackView.bottomAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    @objc func closeBtnClicked(sender: UIButton) -> Void {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func savedBtnClicked(sender: UIButton) -> Void {
        
        if self.checkIsSaved(id: news?.description) {
            self.deleteItem(id: news?.description)
            self.showAlert(str: "Removed successfully")
            self.saveButton.tintColor = .lightGray
        } else {
            TopHeadlinesViewModel.shared.addToSavedList(news: news) { success in
                if success {
                    self.showAlert(str: "Saved successfully")
                    self.saveButton.tintColor = .black
                } else {
                    self.showAlert(str: "Saved Faield")
                }
            }
        }
    }
    
    func showAlert(str: String) -> Void {
        let alert = UIAlertController(title: "", message: str, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}


extension UIViewController {
    func checkIsSaved(id: String?) -> Bool {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        guard let itemId = id else { return false }
        
        guard let username = UserDefaults.standard.value(forKey: "username") as? String else { return false }
        
        let fetchRequest: NSFetchRequest<SavedNews> = SavedNews.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "desc == %@ && username == %@", itemId, username)
        
        do {
            let count = try context.count(for: fetchRequest)
            return count > 0
        } catch {
            print("Error checking if item is saved: \(error)")
            return false
        }
    }
    
    
    func deleteItem(id: String?) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        guard let itemId = id else {
            return
        }
        
        guard let username = UserDefaults.standard.value(forKey: "username") as? String else { return }
        
        let fetchRequest: NSFetchRequest<SavedNews> = SavedNews.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "desc == %@ && username == %@", itemId, username)
        
        do {
            if let result = try context.fetch(fetchRequest).first {
                context.delete(result)
                try context.save()
                print("Item deleted successfully")
            }
        } catch {
            print("Failed to delete item: \(error)")
        }
    }
}
