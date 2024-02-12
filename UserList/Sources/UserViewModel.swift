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

    private let repository = UserListRepository()

    // MARK: - Inputs
    
    func fetchUsers() {
        isLoading = true
        Task {
            do {
                let fetchedUsers = try await repository.fetchUsers(quantity: 20)
                DispatchQueue.main.async {
                    self.users.append(contentsOf: fetchedUsers)
                    self.isLoading = false
                }
            } catch {
                print("Error fetching users: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }
    }

    func reloadUsers() {
        users.removeAll()
        fetchUsers()
    }

    // MARK: - Outputs
    
    func shouldLoadMoreData(currentItem item: User) -> Bool {
        guard let lastItem = users.last else { return false }
        return !isLoading && item.id == lastItem.id
    }
}
