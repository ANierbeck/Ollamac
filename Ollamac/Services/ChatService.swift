//
//  ChatService.swift
//  Ollamac
//
//  Created for Phase 2 refactoring
//

import SwiftUI

@MainActor
final class ChatService: ObservableObject {
    private var messageViewModel: MessageViewModel?
    private var chatViewModel: ChatViewModel?
    private(set) var chatBackend: any ChatBackend

    init(chatBackend: any ChatBackend) {
        self.chatBackend = chatBackend
    }

    func setViewModels(chatViewModel: ChatViewModel, messageViewModel: MessageViewModel) {
        self.chatViewModel = chatViewModel
        self.messageViewModel = messageViewModel
    }

    func updateChatBackend(_ chatBackend: any ChatBackend) {
        self.chatBackend = chatBackend
    }

    func generate(activeChat: Chat, prompt: String) {
        messageViewModel?.generate(activeChat: activeChat, prompt: prompt)
    }

    func regenerate(activeChat: Chat) {
        messageViewModel?.regenerate(activeChat: activeChat)
    }

    func cancelGeneration() {
        messageViewModel?.cancelGeneration()
    }
}
