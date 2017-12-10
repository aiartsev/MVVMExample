//
//  EntryListViewController.swift
//  iosTest
//
//  Created by Alex Iartsev on 09/12/2017.
//  Copyright © 2017 Alex Iartsev. All rights reserved.
//

import UIKit

class EntryListViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    
    lazy var viewModel: EntryListViewModel = {
        let uuid = UIDevice.current.identifierForVendor!.uuidString
        return EntryListViewModel(withDeviceId: uuid)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initView()
        initViewModel()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func initView() {
        tableView.estimatedRowHeight = 85.0
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func initViewModel() {
        viewModel.showAlert = { [weak self] () in
            DispatchQueue.main.async {
                if let message = self?.viewModel.alertMessage {
                    self?.display(alertMessage: message)
                }
            }
        }
        
        viewModel.updateLoadingStatus = { [weak self] () in
            DispatchQueue.main.async {
                let loading = self?.viewModel.loading ?? false
                if loading {
                    self?.activityIndicator.startAnimating()
                    UIView.animate(withDuration: 0.2, animations: {
                        self?.tableView.alpha = 0.0
                    })
                } else {
                    self?.activityIndicator.stopAnimating()
                    UIView.animate(withDuration: 0.2, animations: {
                        self?.tableView.alpha = 1.0
                    })
                }
            }
        }
        
        viewModel.reloadTableView = { [weak self] () in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        
        viewModel.loadData()
    }
    
    func display(alertMessage message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension EntryListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "EntryListViewCell", for: indexPath) as? EntryListViewCell else {
            fatalError("EntryListViewCell not implemented!")
        }
        
        let cellViewModel = self.viewModel.getCellViewModel(at: indexPath)
        cell.viewModel = cellViewModel
 
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfCells
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let cellViewModel = viewModel.getCellViewModel(at: indexPath)
        let url = URL(string: cellViewModel.thumbnailURL)!
        if !UIApplication.shared.canOpenURL(url) {
            return nil
        }
        
        if let image = cellViewModel.imageURL {
            let imageURL = URL(string: image)!
            UIApplication.shared.open(imageURL, options: [:])
        }
       
        return nil
    }
}

extension UIImageView {
    func load(fromURL url: URL) {
        print(url)
        self.image = nil
        let configuration = URLSessionConfiguration.ephemeral
        let session = URLSession(configuration: configuration, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: url, completionHandler: {[weak self] (data: Data?, response: URLResponse?, error: Error?) -> Void in
            guard let data = data, let image = UIImage(data: data) else {
                return
            }
            
            self?.image = image
        })
        task.resume()
    }
}

class EntryListViewCell: UITableViewCell {
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var commentsLabel: UILabel!
    
    @IBOutlet weak var thumbnailLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var thumbnailWidthConstraint: NSLayoutConstraint!
    
    var viewModel: EntryListCellViewModel? = nil {
        didSet {
            if let viewModel = self.viewModel {
                self.titleLabel.text = viewModel.titleText
                self.authorLabel.text = viewModel.authorText
                self.commentsLabel.text = viewModel.commentsText
                self.dateLabel.text = viewModel.dateText
                
                if let url = URL(string: viewModel.thumbnailURL) {
                    if UIApplication.shared.canOpenURL(url) {
                        self.thumbnailImageView.isHidden = false
                        self.thumbnailLeftConstraint.constant = 0.0
                        self.thumbnailWidthConstraint.constant = 75.0
                        self.thumbnailImageView.load(fromURL: url)
                    } else {
                        self.thumbnailLeftConstraint.constant = -10.0
                        self.thumbnailWidthConstraint.constant = 0.0
                        self.thumbnailImageView.isHidden = true
                    }
                }
            }
        }
    }
}
