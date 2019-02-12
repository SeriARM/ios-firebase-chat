//
//  ChatRoomTableViewController.swift
//  Firebase Chat
//
//  Created by Sergey Osipyan on 2/12/19.
//  Copyright © 2019 Sergey Osipyan. All rights reserved.
//

import UIKit
import MessageKit

class ChatRoomTableViewController: UITableViewController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        messageThreadController.fetchMessageThreads {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func beginRefresh(_ sender: UIRefreshControl) {
        
         messageThreadController.fetchMessageThreads {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.tableView.reloadData()
            sender.endRefreshing()
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let alert = UIAlertController(title: "Set a username", message: nil, preferredStyle: .alert)
        var nameTextField: UITextField?
        alert.addTextField { (textField) in
            textField.placeholder = "Username"
            nameTextField = textField
        }
        let submitAction = UIAlertAction(title: "Submit", style: .default) { (_) in
            let name = nameTextField?.text ?? "User"
            let user = Sender(id: name, displayName: name)
            self.messageThreadController.currentUser = user
        }
        alert.addAction(submitAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Actions
    
    @IBAction func createThread(_ sender: Any) {
        threadTitleTextField.resignFirstResponder()
        
        guard let threadTitle = threadTitleTextField.text else { return }
        
        threadTitleTextField.text = ""
        
        messageThreadController.createMessageThread(with: threadTitle) {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageThreadController.messageThreads.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageThreadCell", for: indexPath)
        
        cell.textLabel?.text = messageThreadController.messageThreads[indexPath.row].title
        
        return cell
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ViewMessageThread" {
            guard let indexPath = tableView.indexPathForSelectedRow,
                let destinationVC = segue.destination as? MessageViewController else { return }
            
            destinationVC.messageThreadController = messageThreadController
            destinationVC.messageThread = messageThreadController.messageThreads[indexPath.row]
        }
    }
    
    // MARK: - Properties
    
    let messageThreadController = MessageThreadController()
    
    @IBOutlet weak var threadTitleTextField: UITextField!
}
