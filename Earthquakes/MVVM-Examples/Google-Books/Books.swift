//
//  Books.swift
//  Earthquakes
//
//  Created by CONG LE on 10/15/23.
//

import Foundation
import SwiftUI

// MARK: - Error Cases
enum BooksServiceError: Error {
    case invalidURL
    case responseError(message: String)
    case noData
    case decodingError(message: String)
}

// MARK: - Query Endpoints

enum Endpoint {
    case volumes(queries: [BooksQuery])
    case volumeDetail(id: String)
    // add here other endpoints if needed
    
    var url: URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "www.googleapis.com"
        components.path = self.path
        components.queryItems = self.queryItems
        
        return components.url
    }
    
    private var path: String {
        switch self {
        case .volumes:
            /// https://www.googleapis.com/books/v1/volumes
            return "/books/v1/volumes"
        case .volumeDetail(let id):
            /// https://www.googleapis.com/books/v1/volumes/{volumeId}
            return "/books/v1/volumes/\(id)"
        }
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case .volumes(let queries):
            /// https://www.googleapis.com/books/v1/volumes?q={ queries }
            return queries.map { $0.queryItem }
        default:
            return nil
        }
    }
}
enum BooksQuery {
    case query(String)
    case maxResults(Int)
    case startIndex(Int)
    case printType(String)
    case langRestrict(String)
    
    var queryItem: URLQueryItem {
        switch self {
        case .query(let string): return URLQueryItem(name: "q", value: string)
        case .maxResults(let number): return URLQueryItem(name: "maxResults", value: "\(number)")
        case .startIndex(let number): return URLQueryItem(name: "startIndex", value: "\(number)")
        case .printType(let string): return URLQueryItem(name: "printType", value: string)
        case .langRestrict(let string): return URLQueryItem(name: "langRestrict", value: string)
        }
    }
}

// MARK: - SERVICES
class BooksService {
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .returnCacheDataElseLoad
        return URLSession(configuration: config)
    }()
    
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        // Configure decoder if needed
        return decoder
    }()
    
    func fetchBooks(queries: [BooksQuery], completion: @escaping (Result<BookResponse, Error>) -> Void) {
        /// URL link: https://www.googleapis.com/books/v1/volumes?q=harry%20potter&maxResults=10&startIndex=2
        guard let url = Endpoint.volumes(queries: queries).url else {
            DispatchQueue.main.async { completion(.failure(BooksServiceError.invalidURL)) }
            return
        }
        performRequest(url: url, completion: completion)
    }
    
    //    func fetchBookDetail(id: String, completion: @escaping (Result<BookDetailResponse, Error>) -> Void) {
    //        guard let url = Endpoint.volumeDetail(id: id).url else {
    //            DispatchQueue.main.async { completion(.failure(BooksServiceError.invalidURL)) }
    //            return
    //        }
    //        performRequest(url: url, completion: completion)
    //    }
    
    private func performRequest<T: Decodable>(url: URL, completion: @escaping (Result<T, Error>) -> Void) {
        session.dataTask(with: url) { (data, _, error) in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(BooksServiceError.responseError(message: error.localizedDescription)))
                    return
                }
                guard let data = data else {
                    completion(.failure(BooksServiceError.noData))
                    return
                }
                do {
                    let response = try self.decoder.decode(T.self, from: data)
                    completion(.success(response))
                } catch {
                    completion(.failure(BooksServiceError.decodingError(message: error.localizedDescription)))
                }
            }
        }.resume()
    }
}

//MARK: - VIEWMODEL
class BooksViewModel: ObservableObject {
    private let booksService: BooksService
    @Published var books = [Item]()
    @Published var error: BooksServiceError?
    
    init(booksService: BooksService = BooksService()) {
        self.booksService = booksService
    }
    func fetchBooks(query: String) {
        
    }
    func fetchBooks() {
        booksService.fetchBooks(queries: [.query("harry potter"), .maxResults(10), .startIndex(2)]) { result in
            switch result {
            case .success(let bookResponse):
                self.books = bookResponse.items
            case .failure(let error):
                self.error = error as? BooksServiceError
            }
        }
    }
}

// MARK: - VIEW
struct BooksView: View {
    @ObservedObject private var booksViewModel = BooksViewModel()
    @State private var searchQuery = ""
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Search...", text: $searchQuery)
                    .padding(7)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal, 10)
                
                List(booksViewModel.books) { book in
                    VStack(alignment: .leading) {
                        Text(book.volumeInfo.title)
                            .font(.headline)
                        
                        Text(book.volumeInfo.authors.first ?? "Anonymous")
                            .font(.subheadline)
                        
                        Text(book.volumeInfo.publishedDate)
                            .font(.subheadline)
                        
                        Text(book.saleInfo.saleability)
                            .font(.callout)
                        
                        Divider()
                        
                        Text(book.searchInfo.textSnippet)
                            .font(.caption2)
                        
                        Divider()
                        
                        Text(book.volumeInfo.description)
                            .font(.caption)
                        
                        Spacer()
                    }
                }//List
                .onAppear {
                    if self.searchQuery.isEmpty {
                        self.booksViewModel.fetchBooks() // default resultss
                    } else {
                        self.booksViewModel.fetchBooks(query: self.searchQuery) // use user inputs as queries
                    }
                }
                
                if let error = booksViewModel.error {
                    handleError(error: error)
                }
            }
            .navigationBarTitle("Google Books")
        }
    }
    
    private func handleError(error: BooksServiceError) -> some View {
        switch error {
        case .invalidURL:
            return Text("Invalid URL")
        case .noData:
            return Text("Received no data from API")
        case .decodingError:
            return Text("Decoding error")
        case .responseError:
            return Text("There was a problem with the network request")
        }
    }
}

// MARK: - Preview
#Preview {
    BooksView()
}


