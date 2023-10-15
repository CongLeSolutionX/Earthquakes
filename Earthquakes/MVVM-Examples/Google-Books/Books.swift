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

// MARK: - SERVICES
///  https://www.googleapis.com/books/v1/volumes?q=time&printType=magazines&key=AIzaSyDn3G9HAKGl07eN3-N0f_51NImwxszHbS0
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
    
    func fetchBooks(completion: @escaping (Result<[Item], Error>) -> Void) {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "www.googleapis.com"
        urlComponents.path = "/books/v1/volumes"
        urlComponents.queryItems = [URLQueryItem(name: "q", value: "harry potter")]
        
        guard let url = urlComponents.url else {
            DispatchQueue.main.async { completion(.failure(BooksServiceError.invalidURL)) }
            return
        }
        
        session.dataTask(with: url) { (data, response, error) in
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
                    let response = try self.decoder.decode(BookResponse.self, from: data)
                    completion(.success(response.items))
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
    
    func fetchBooks() {
        booksService.fetchBooks { result in
            switch result {
            case .success(let books):
                self.books = books
            case .failure(let error):
                self.error = error as? BooksServiceError
            }
        }
    }
}

// MARK: - VIEW
struct BooksView: View {
    @ObservedObject private var booksViewModel = BooksViewModel()
    
    var body: some View {
        VStack {
            if let error = booksViewModel.error {
                handleError(error: error)
            }
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
                    
                    Text(book.volumeInfo.description)
                        .font(.caption)
                    
                    Spacer()
                }
            }.onAppear {
                self.booksViewModel.fetchBooks()
            }
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


