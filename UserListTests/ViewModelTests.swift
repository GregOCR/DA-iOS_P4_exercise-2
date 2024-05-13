//
//  ViewModelTests.swift
//  UserListTests
//
//  Created by Greg on 30/04/2024.
//

import XCTest
@testable import UserList

final class ViewModelTests: XCTestCase {
    
    func testFetchUsers() async throws {
        
        let repository = UserListRepository(executeDataRequest: mockExecuteDataRequest)
        let viewModel = UserViewModel(repository: repository)
        let defaultCount = viewModel.users.count
        
        await viewModel.fetchUsers()
        let newCount = viewModel.users.count
        
        XCTAssertEqual(newCount,
                       defaultCount + 2)
    }
    
    func testReloadUsers() async throws {
        
        let repository = UserListRepository(executeDataRequest: mockExecuteDataRequest)
        let viewModel = UserViewModel(repository: repository)
        
        await viewModel.fetchUsers()
        let fetchCount = viewModel.users.count
        
        await viewModel.reloadUsers()
        let reloadCount = viewModel.users.count
        
        XCTAssertEqual(fetchCount,
                       reloadCount)
    }
    
    func testShouldLoadMoreData() {
        
        let repository = UserListRepository(executeDataRequest: mockExecuteDataRequest)
        let viewModel = UserViewModel(repository: repository)
        
        let lastUser = User(user: .init(name: .init(title: "Mr", first: "John", last: "Doe"),
                                        dob: .init(date: "1990-01-01", age: 30),
                                        picture: .init(large: "", medium: "", thumbnail: "")))
        
        viewModel.users.append(lastUser)
        
        let shouldLoadMore = viewModel.shouldLoadMoreData(currentItem: lastUser)
        
        XCTAssertTrue(shouldLoadMore)
    }
}

private extension ViewModelTests {
    func mockExecuteDataRequest(_ request: URLRequest) async throws -> (Data, URLResponse) {
        // Create mock data with a sample JSON response
        let sampleJSON = """
            {
                "results": [
                    {
                        "name": {
                            "title": "Mr",
                            "first": "John",
                            "last": "Doe"
                        },
                        "dob": {
                            "date": "1990-01-01",
                            "age": 31
                        },
                        "picture": {
                            "large": "https://example.com/large.jpg",
                            "medium": "https://example.com/medium.jpg",
                            "thumbnail": "https://example.com/thumbnail.jpg"
                        }
                    },
                    {
                        "name": {
                            "title": "Ms",
                            "first": "Jane",
                            "last": "Smith"
                        },
                        "dob": {
                            "date": "1995-02-15",
                            "age": 26
                        },
                        "picture": {
                            "large": "https://example.com/large.jpg",
                            "medium": "https://example.com/medium.jpg",
                            "thumbnail": "https://example.com/thumbnail.jpg"
                        }
                    }
                ]
            }
        """
        
        let data = sampleJSON.data(using: .utf8)!
        let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (data, response)
    }
}
