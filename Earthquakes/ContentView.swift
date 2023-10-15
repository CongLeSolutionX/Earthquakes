//
//  ContentView.swift
//  Earthquakes
//
//  Created by CONG LE on 10/15/23.
//

import SwiftUI

// MVC pattern to do fetch
// Swift Model
//struct Post: Codable, Identifiable {
//    let id: Int
//    let title: String
//    let body: String
//}
//
//// Fetching Data from URL
//func fetchPosts(completion: @escaping ([Post]) -> Void) {
//    guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else {
//        return
//    }
//
//    URLSession.shared.dataTask(with: url) { (data, response, error) in
//        if let data = data {
//            if let decodedPosts = try? JSONDecoder().decode([Post].self, from: data) {
//                DispatchQueue.main.async {
//                    completion(decodedPosts)
//                }
//                return
//            }
//        }
//    }.resume()
//}
//
//// SwiftUI View
//struct ContentView: View {
//    @State var posts = [Post]()
//
//    var body: some View {
//        List(posts) { post in
//            Text(post.title)
//        }
//        .onAppear(perform: {
//            fetchPosts { (posts) in
//                self.posts = posts
//            }
//        })
//    }
//}

//struct Post: Codable, Identifiable {
//    let id = UUID()
//    var userId: Int
//    var title: String
//    var body: String
//}
//
//class Api {
//    func getPosts(completion : @escaping ([Post]) -> ()) {
//        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else { return }
//
//        URLSession.shared.dataTask(with: url) { (data, _, _) in
//            let posts = try! JSONDecoder().decode([Post].self, from: data!)
//            DispatchQueue.main.async {
//                completion(posts)
//            }
//        }
//        .resume()
//    }
//}
//
//struct ContentView: View {
//    @State var posts = [Post]()
//
//    var body: some View {
//        List(posts) { post in
//            Text(post.title)
//        }
//        .onAppear {
//            Api().getPosts { (posts) in
//                self.posts = posts
//            }
//        }
//    }
//}
//

struct ContentView: View {
    var body: some View {
        Text("Hi there")
    }
}
// MARK: - Preview
#Preview {
    ContentView()
}
