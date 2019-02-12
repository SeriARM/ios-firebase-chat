//
//  MessageThreadController.swift
//  Message Board
//
//  Created by Spencer Curtis on 8/7/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import MessageKit

class MessageThreadController {
    
    func fetchMessageThreads(completion: @escaping () -> Void) {
        
        let requestURL = MessageThreadController.baseURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            
            if let error = error {
                NSLog("Error fetching message threads: \(error)")
                completion()
                return
            }
            
            guard let data = data else { NSLog("No data returned from data task"); completion(); return }
            
            do {
                self.messageThreads = try JSONDecoder().decode([String: MessageThread].self, from: data).map({ $0.value })
            } catch let jsonError as DecodingError {
                let ctx: DecodingError.Context
                switch jsonError {
                    
                case .typeMismatch(let type, let context):
                    print("Mismatched type: \(type)")
                    ctx = context
                case .valueNotFound(let type, let context):
                    print("Missing value of type \(type)")
                    ctx = context
                case .keyNotFound(let key, let context):
                    print("Unknown key: \(key.stringValue)")
                    ctx = context
                case .dataCorrupted(let context):
                    print("Corrupted data")
                    ctx = context
                }
                
                let path = ctx.codingPath.map { p -> String in
                    return p.intValue != nil ? "[\(p.intValue!)]" : "."+p.stringValue
                }.joined()
                
                print("path: [root]\(path)")
                
                
                self.messageThreads = []
                NSLog("Error decoding message threads from JSON data: \(error)")
            } catch {
                self.messageThreads = []
                NSLog("Unknown error decoding message threads from JSON data: \(error)")
            }
            
            completion()
        }.resume()
    }
    
    func createMessageThread(with title: String, completion: @escaping () -> Void) {
        
        let thread = MessageThread(title: title)
        
        let requestURL = MessageThreadController.baseURL.appendingPathComponent(thread.identifier).appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        
        request.httpMethod = HTTPMethod.put.rawValue
        
        do {
            request.httpBody = try JSONEncoder().encode(thread)
        } catch {
            NSLog("Error encoding thread to JSON: \(error)")
        }
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            
            if let error = error {
                NSLog("Error with message thread creation data task: \(error)")
                completion()
                return
            }
            
            self.messageThreads.append(thread)
            completion()
            
        }.resume()
    }
    
    func createMessage(in messageThread: MessageThread, withText text: String, sender: String, completion: @escaping () -> Void) {
        
        guard let index = messageThreads.index(of: messageThread) else { completion(); return }
        
        let message = MessageThread.Message(text: text, sender: sender)
        
        messageThreads[index].messages.append(message)
        
        let requestURL = MessageThreadController.baseURL.appendingPathComponent(messageThread.identifier).appendingPathComponent("messages").appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        
        request.httpMethod = HTTPMethod.post.rawValue
        
        do {
            request.httpBody = try JSONEncoder().encode(message)
        } catch {
            NSLog("Error encoding message to JSON: \(error)")
        }
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            
            if let error = error {
                NSLog("Error with message thread creation data task: \(error)")
                completion()
                return
            }
            
            completion()
            
        }.resume()
    }
    
    static let baseURL = URL(string: "https://ios-firebase-project-53e55.firebaseio.com/")!
    var messageThreads: [MessageThread] = []
    var currentUser: Sender?
}
