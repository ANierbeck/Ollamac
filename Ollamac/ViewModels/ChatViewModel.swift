//
//  ChatViewModel.swift
//
//
//  Created by Kevin Hermawan on 13/07/24.
//

import Defaults
import SwiftData
import SwiftUI

@MainActor
@Observable
final class ChatViewModel {
    private var modelContext: ModelContext
    private var _chatNameTemp: String = ""
    
    @Environment(ChatBackend.self) private var chatBackend
    
    var models: [String] = []
    
    var chats: [Chat] = []
    var activeChat: Chat? = nil
    var selectedChats = Set<Chat>()

    var shouldFocusPrompt = false

    var isHostReachable: Bool = true
    var loading: ChatViewModelLoading? = nil
    var error: ChatViewModelError? = nil
    
    var isRenameChatPresented = false
    var isDeleteConfirmationPresented = false
    
    var chatNameTemp: String {
        get {
            if isRenameChatPresented, let activeChat {
                return activeChat.name
            }
            
            return _chatNameTemp
        }
        
        set {
            _chatNameTemp = newValue
        }
    }
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func fetchModels() {
        self.loading = .fetchModels
        self.error = nil
        
        Task {
            do {
                defer { self.loading = nil }
                
                let isReachable = await chatBackend.reachable()
                
                guard isReachable else {
                    self.isHostReachable = false
                    self.error = .fetchModels("Unable to connect to server. Please verify that the server is running and accessible.")
                    return
                }
                
                self.isHostReachable = true
                let models = try await chatBackend.listModels()
                self.models = models
                
                guard !self.models.isEmpty else {
                    self.error = .fetchModels("No models available. Please pull at least one model first.")
                    return
                }
                
                if let host = activeChat?.host, host.isEmpty {
                    self.activeChat?.host = self.models.first
                }
            } catch {
                self.error = .fetchModels(error.localizedDescription)
            }
        }
    }
    
    func load() {
        do {
            let sortDescriptor = SortDescriptor(\Chat.modifiedAt, order: .reverse)
            let fetchDescriptor = FetchDescriptor<Chat>(sortBy: [sortDescriptor])
            
            self.chats = try self.modelContext.fetch(fetchDescriptor)
        } catch {
            self.error = .load(error.localizedDescription)
        }
    }
    
    func create(model: String) {
        let chat = Chat(model: model)
        self.modelContext.insert(chat)
        
        self.chats.insert(chat, at: 0)
        self.selectedChats = [chat]
        self.shouldFocusPrompt = true
    }
    
    func rename() {
        guard let activeChat else { return }
        
        if let index = self.chats.firstIndex(where: { $0.id == activeChat.id }) {
            self.chats[index].name = _chatNameTemp
            self.chats[index].modifiedAt = .now
        }
    }
    
    func remove() {
        for chat in selectedChats {
            self.modelContext.delete(chat)
            self.chats.removeAll(where: { $0.id == chat.id })
        }
    }
    
    func removeTemporaryChat(chatToRemove: Chat) {
        if (chatToRemove.name == Defaults[.defaultChatName] && chatToRemove.messages.isEmpty) {
            self.modelContext.delete(chatToRemove)
            self.chats.removeAll(where: { $0.id == chatToRemove.id })
        }
    }
}

enum ChatViewModelLoading {
    case fetchModels
}

enum ChatViewModelError: Error {
    case fetchModels(String)
    case load(String)
}
