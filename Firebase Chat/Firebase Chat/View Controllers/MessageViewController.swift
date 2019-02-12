//
//  MessageViewController.swift
//  Firebase Chat
//
//  Created by Sergey Osipyan on 2/12/19.
//  Copyright © 2019 Sergey Osipyan. All rights reserved.
//

    import UIKit
    import MessageKit
    import MessageInputBar
    
    class MessageViewController: MessagesViewController, MessagesDataSource, MessagesDisplayDelegate, MessagesLayoutDelegate, MessageInputBarDelegate {
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            messageInputBar.delegate = self
            messagesCollectionView.messagesDataSource = self
            messagesCollectionView.messagesLayoutDelegate = self
            messagesCollectionView.messagesDisplayDelegate = self
        }
        
        // MARK - MessagesDataSource
        
        func currentSender() -> Sender {
            guard let sender = messageThreadController?.currentUser else {
                return Sender(id: "", displayName: "User")
            }
            return sender
        }
        
        func isFromCurrentSender(message: MessageType) -> Bool {
            return message.sender == currentSender()
        }
        
        func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
            guard let message = messageThread?.messages[indexPath.row] else {
                fatalError("Messages not available")
            }
            return message
        }
        
        func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
            return 1
        }
        
        func numberOfItems(inSection section: Int, in messagesCollectionView: MessagesCollectionView) -> Int {
            return messageThread?.messages.count ?? 0
        }
        
        func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
            let name = message.sender.displayName
            let attrs = [NSAttributedString.Key.font : UIFont.preferredFont(forTextStyle: .caption1)]
            return NSAttributedString(string: name, attributes: attrs)
        }
        
        func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
            let dateString = formatter.string(from: message.sentDate)
            let attrs = [NSAttributedString.Key.font : UIFont.preferredFont(forTextStyle: .caption2)]
            return NSAttributedString(string: dateString, attributes: attrs)
        }
        
        // MARK: - MessagesLayoutDelegate
        
        func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
            return 16
        }
        
        func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
            return 16
        }
        
        // MARK: - MessagesDisplayDelegate
        
        func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
            return isFromCurrentSender(message: message) ? .white : .black
        }
        
        func backgroundColor(for message: MessageType, at indexPath: IndexPath,
                             in messagesCollectionView: MessagesCollectionView) -> UIColor {
            
            return isFromCurrentSender(message: message) ? .blue : .green
        }
        
        // Adds tails onto the messages
        func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
            let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
            
            return .bubbleTail(corner, .curved)
        }
        
        // Sets the senders first initial in the avatar circle view
        func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
            let initials = String(message.sender.displayName.first ?? Character(""))
            let avatar = Avatar(image: nil, initials: initials)
            avatarView.set(avatar: avatar)
        }
        
        // MARK: - MessagesInputBarDelegate
        
        func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
            guard let messageThread = messageThread else { return }
            
            messageThreadController?.createMessage(in: messageThread,
                                                   withText: text,
                                                   sender: currentSender().displayName) {
                                                    DispatchQueue.main.async {
                                                        self.messagesCollectionView.reloadData()
                                                    }
            }
        }
        
        // MARK: - Properties
        
        var messageThread: MessageThread?
        var messageThreadController: MessageThreadController?
        
        private lazy var formatter: DateFormatter = {
            let result = DateFormatter()
            result.dateStyle = .medium
            result.timeStyle = .medium
            return result
        }()
}
