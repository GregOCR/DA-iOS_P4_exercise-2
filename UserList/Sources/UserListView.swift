import SwiftUI

struct UserListView: View {
    
    @StateObject var viewModel = UserViewModel()
    
    var body: some View {
        NavigationView {
            if !viewModel.isGridView {
                ListUserView(viewModel: viewModel)
            } else {
                ScrollUserView(viewModel: viewModel)
            }
        }
        .onAppear {
            Task {
                await viewModel.fetchUsers()
            }
        }
    }
}

struct ScrollUserView: View {
    
    @ObservedObject var viewModel: UserViewModel
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))]) {
                ForEach(viewModel.users) { user in
                    NavigationLinkView(user: user,content: {
                        VStack {
                            ImageSyncView(user: user)
                            UserNameView(user: user)
                                .multilineTextAlignment(.center)
                        }
                    }, viewModel: viewModel)
                }
            }
        }
        .navigationTitle("Users")
        .usersToolbar(isGridView: $viewModel.isGridView,
                      reloadAction: {
            Task {
                await viewModel.reloadUsers()
            }
        })
    }
}

struct ListUserView: View {
    
    @ObservedObject var viewModel: UserViewModel
    
    var body: some View {
        List(viewModel.users) { user in
            NavigationLinkView(user: user, content: {
                HStack {
                    ImageSyncView(user: user)
                    VStack(alignment: .leading) {
                        UserNameView(user: user)
                        UserDobView(user: user)
                    }
                }
            }, viewModel: viewModel)
        }
        .navigationTitle("Users")
        .usersToolbar(isGridView: $viewModel.isGridView,
                      reloadAction: {
            Task {
                await viewModel.reloadUsers()
            }
        })
    }
}

struct UserNameView: View {
    
    var user: User
    
    var body: some View {
        Text("\(user.name.first) \(user.name.last)")
            .font(.headline)
    }
}

struct UserDobView: View {
    
    var user: User
    
    var body: some View {
        Text("\(user.dob.date)")
            .font(.subheadline)
    }
}

struct ImageSyncView: View {
    
    var user: User
    
    var body: some View {
        AsyncImage(url: URL(string: user.picture.thumbnail)) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 50, height: 50)
                .clipShape(Circle())
        } placeholder: {
            ProgressView()
                .frame(width: 50, height: 50)
                .clipShape(Circle())
        }
    }
}

struct ToolBarPickerView: View {
    
    @Binding var pickerSelection: Bool
    
    var body: some View {
        Picker(selection: $pickerSelection, label: Text("Display")) {
            Image(systemName: "rectangle.grid.1x2.fill")
                .tag(true)
                .accessibilityLabel(Text("Grid view"))
            Image(systemName: "list.bullet")
                .tag(false)
                .accessibilityLabel(Text("List view"))
        }
        .pickerStyle(SegmentedPickerStyle())
    }
}

struct NavigationLinkView<Content: View>: View {
    
    let user: User
    let content: () -> Content
    
    @ObservedObject var viewModel: UserViewModel

    var body: some View {
        NavigationLink(destination: UserDetailView(user: user)) {
            content()
        }
        .onAppear {
            if viewModel.shouldLoadMoreData(currentItem: user) {
                Task {
                    await viewModel.fetchUsers()
                }
            }
        }
    }
}

extension View {
    func usersToolbar(isGridView: Binding<Bool>,
                      reloadAction: @escaping () -> Void) -> some View {
        self.toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                ToolBarPickerView(pickerSelection: isGridView)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: reloadAction) {
                    Image(systemName: "arrow.clockwise")
                        .imageScale(.large)
                }
            }
        }
    }
}

struct UserListView_Previews: PreviewProvider {
    static var previews: some View {
        UserListView(viewModel: UserViewModel())
    }
}
