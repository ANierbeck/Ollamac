//
//  MessageViewModel.swift
//
//
//  Created by Kevin Hermawan on 13/07/24.
//

import Foundation
import SwiftData
import SwiftUI

@MainActor
@Observable
final class MessageViewModel {
    private var modelContext: ModelContext
    private var generationTask: Task<Void, Never>?
    private nonisolated let chatBackend: any ChatBackend
    
    var messages: [Message] = []
    var tempResponse: String = ""
    var loading: MessageViewModelLoading? = nil
    var error: MessageViewModelError? = nil
    
    init(modelContext: ModelContext, chatBackend: any ChatBackend) {
        self.modelContext = modelContext
        self.chatBackend = chatBackend
    }
    
    func load(of chat: Chat?) {
        guard let chat = chat else { return }
        
        let chatId = chat.id
        let predicate = #Predicate<Message> { $0.chat?.id == chatId }
        let sortDescriptor = SortDescriptor(\Message.createdAt)
        let fetchDescriptor = FetchDescriptor<Message>(predicate: predicate, sortBy: [sortDescriptor])
        
        self.loading = .load
        
        do {
            defer { self.loading = nil }
            self.messages = try self.modelContext.fetch(fetchDescriptor)
        } catch {
            self.error = .load(error.localizedDescription)
        }
    }
    
    func generate(activeChat: Chat, prompt: String) {
        let message = Message(prompt: prompt)
        message.chat = activeChat
        messages.append(message)
        modelContext.insert(message)
        
        self.loading = .generate
        self.error = nil
        
        generationTask = Task {
            defer { self.loading = nil }
            
            do {
                let request = message.toChatRequest(messages: self.messages)
                
                let stream = try await chatBackend.chat(request: request)
                for try await chunk in stream {
                    if Task.isCancelled { break }
                    
                    tempResponse = tempResponse + (chunk.message?.content ?? "")
                    
                    if chunk.done {
                        message.response = tempResponse
                        activeChat.modifiedAt = .now
                        tempResponse = ""
                        
                        if messages.count == 1 {
                            self.generateTitle(activeChat: activeChat)
                        }
                    }
                }

                // If chunk was not done: handle temporary response
                if !tempResponse.isEmpty {
                    // properly close <think> block
                    if tempResponse.matches(of: /<\/?think>/).count == 1 {
                        tempResponse += "\n</think>\n"
                    }

                    // properly close any code blocks
                    if tempResponse.matches(of: /```/).count % 2 == 1 {
                        tempResponse += "\n```\n"
                    } else {
                        // ... or add a visual separator
                        tempResponse += "\n\n---\n"
                    }

                    // mark response as cancelled
                    tempResponse += "\n_CANCELLED_"

                    message.response = tempResponse
                    activeChat.modifiedAt = .now
                    tempResponse = ""
                }
            } catch {
                self.error = .generate(error.localizedDescription)
            }
        }
    }
    
    func regenerate(activeChat: Chat) {
        guard let lastMessage = messages.last else { return }
        lastMessage.response = nil
        
        self.loading = .generate
        self.error = nil
        
        generationTask = Task {
            defer { self.loading = nil }
            
            do {
                let request = lastMessage.toChatRequest(messages: self.messages)
                
                let stream = try await chatBackend.chat(request: request)
                for try await chunk in stream {
                    if Task.isCancelled { break }
                    
                    tempResponse = tempResponse + (chunk.message?.content ?? "")
                    
                    if chunk.done {
                        lastMessage.response = tempResponse
                        activeChat.modifiedAt = .now
                        tempResponse = ""
                    }
                }

                // If chunk was not done: handle temporary response
                if !tempResponse.isEmpty {
                    // properly close <think> block
                    if tempResponse.matches(of: /<\/?think>/).count == 1 {
                        tempResponse += "\n</think>\n"
                    }

                    // properly close any code blocks
                    if tempResponse.matches(of: /```/).count % 2 == 1 {
                        tempResponse += "\n```\n"
                    } else {
                        // ... or add a visual separator
                        tempResponse += "\n\n---\n"
                    }

                    // mark response as cancelled
                    tempResponse += "\n_CANCELLED_"

                    lastMessage.response = tempResponse
                    activeChat.modifiedAt = .now
                    tempResponse = ""
                }
            } catch {
                self.error = .generate(error.localizedDescription)
            }
        }
    }
    
    private func generateTitle(activeChat: Chat) {
        let request = Message.toTitleChatRequest(messages: self.messages, model: activeChat.model)
        
        generationTask = Task {
            defer { self.loading = nil }
            
            activeChat.name = "New Chat"
            var title: String = ""
            do {
                var isReasoningContent = false
                
                let stream = try await chatBackend.chat(request: request)
                for try await chunk in stream {
                    if Task.isCancelled { break }
                    
                    guard let content = chunk.message?.content else { continue }
                    
                    if content.contains("<think>") {
                        isReasoningContent = true
                        continue
                    }
                    
                    if content.contains("</think>") {
                        isReasoningContent = false
                        continue
                    }
                    
                    if !isReasoningContent {
                        title += content
                        if title.isEmpty == false {
                            activeChat.name = title.trimmingCharacters(in: .whitespacesAndNewlines.union(.punctuationCharacters))
                        }
                    }
                    
                    if chunk.done {
                        activeChat.modifiedAt = .now
                    }
                }
            } catch {
                self.error = .generateTitle(error.localizedDescription)
            }
        }
    }
    
    func cancelGeneration() {
        self.generationTask?.cancel()
        self.loading = .generate
    }
}

enum MessageViewModelLoading {
    case load
    case generate
}

enum MessageViewModelError: Error {
    case load(String)
    case generate(String)
    case generateTitle(String)
}
