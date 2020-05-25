//
//  ChatViewController.swift
//  Flash Chat iOS13
//
//  Created by Olena Rostovtseva on 20.05.2020.
//

import Firebase
import FirebaseAuth
import UIKit

class ChatViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var messageTextfield: UITextField!

    let db = Firestore.firestore()
    var messages: [Message] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true

        tableView.dataSource = self
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
        loadMessages()
    }

    @IBAction func sendPressed(_ sender: UIButton) {
        let messageBody = messageTextfield.text
        let messageSender = Auth.auth().currentUser?.email
        if let body = messageBody, let sender = messageSender {
            db.collection(K.FStore.collectionName).addDocument(data: [K.FStore.senderField: sender, K.FStore.bodyField: body, K.FStore.dateField: Date().timeIntervalSince1970]) { error in
                if let e = error {
                    print(e.localizedDescription)
                } else {
                    print("Success saving data")
                    self.messageTextfield.text = ""
                }
            }
        }
    }

    @IBAction func logOutPressed(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }

    func loadMessages() {
        db.collection(K.FStore.collectionName).order(by: K.FStore.dateField).addSnapshotListener { querySnapshot, error in
            self.messages = []

            if let e = error {
                print(e.localizedDescription)
            } else {
                if let documents = querySnapshot?.documents {
                    for doc in documents {
                        let data = doc.data()
                        let senderField = data[K.FStore.senderField] as? String
                        let bodyField = data[K.FStore.bodyField] as? String
                        if let messageSender = senderField, let messageBody = bodyField {
                            let newMessage = Message(sender: messageSender, body: messageBody)
                            self.messages.append(newMessage)
                        }
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        if !self.messages.isEmpty {
                            let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                            self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - UITableViewDataSource section

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! MessageCell
        let message = messages[indexPath.row]
        cell.messageLabel?.text = message.body
        if message.sender == Auth.auth().currentUser?.email {
            cell.leftImage.isHidden = true
            cell.rightImage.isHidden = false
            cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.lightPurple)
            cell.messageLabel.textColor = UIColor(named: K.BrandColors.purple)
        } else {
            cell.leftImage.isHidden = false
            cell.rightImage.isHidden = true
            cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.purple)
            cell.messageLabel.textColor = UIColor(named: K.BrandColors.lightPurple)
        }
        return cell
    }
}
