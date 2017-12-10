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
        
        cell.titleLabel.text = cellViewModel.titleText
        cell.authorLabel.text = cellViewModel.authorText
        cell.dateLabel.text = cellViewModel.dateText
        cell.commentsLabel.text = cellViewModel.commentsText
        if let url = URL(string: cellViewModel.thumbnailURL) {
            cell.thumbnailImageView.load(fromURL: url)
        } else {
            cell.thumbnailImageView.isHidden = true
        }
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfCells
    }
    
//    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 100.0
//    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 100.0
//    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
}

extension UIImageView {
    func load(fromURL url: URL) {
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
}
