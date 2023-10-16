//
//  Post.swift
//  Earthquakes
//
//  Created by CONG LE on 10/15/23.
//

import SwiftUI

// MARK: - MODEL
struct Post: Codable, Identifiable {
    let id: Int
    let userId: Int
    let title: String
    let body: String
}

// MARK: - SERVICE
class ApiService {
    func getPosts(completion: @escaping ([Post]) -> Void) {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else { return }

        URLSession.shared.dataTask(with: url) { (data, _, _) in
            let posts = try? JSONDecoder().decode([Post].self, from: data!)
            DispatchQueue.main.async {
                completion(posts ?? [])
            }
        }
        .resume()
    }
}

// MARK: - VIEWMODEL
class PostViewModel: ObservableObject {
    @Published var posts = [Post]()
    
    let apiService: ApiService
    
    init(apiService: ApiService = ApiService()) {
        self.apiService = apiService
    }
    
    func fetchPosts() {
        apiService.getPosts { posts in
            self.posts = posts
        }
    }
}

// MARK: - VIEW
struct PostView: View {
    @ObservedObject var viewModel = PostViewModel()

    var body: some View {
        List(viewModel.posts) { post in
            VStack(alignment: .leading) {
                Text(post.title)
                    .font(.headline)
                Text(post.body)
                    .font(.subheadline)
            }
        }
        .onAppear {
            self.viewModel.fetchPosts()
        }
    }
}

// MARK: - Preview
#Preview {
    PostView()
}
