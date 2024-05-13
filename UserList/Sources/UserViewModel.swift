//
//  UserViewModel.swift
//  UserList
//
//  Created by Greg on 02/02/2024.
//

import SwiftUI

final class UserViewModel: ObservableObject {
    
    // MARK: - PROPERTIES
    @Published var users: [User] = []
    @Published var isLoading = false
    @Published var isGridView = false

    private let repository: UserListRepository
    
    init(repository: UserListRepository = UserListRepository()) {
        self.repository = repository
    }

    // MARK: - Inputs
    @MainActor
    func fetchUsers() async {
        isLoading = true
        do {
            let fetchedUsers = try await repository.fetchUsers(quantity: 20)
                self.users.append(contentsOf: fetchedUsers)
            
        } catch {
            print("Error fetching users: \(error.localizedDescription)")
        }
        self.isLoading = false
    }
    
    @MainActor
    func reloadUsers() async {
        users.removeAll()
        await fetchUsers()
    }

    // MARK: - Outputs
    func shouldLoadMoreData(currentItem item: User) -> Bool {
        guard let lastItem = users.last else { return false }
        return !isLoading && item.id == lastItem.id
    }
}
