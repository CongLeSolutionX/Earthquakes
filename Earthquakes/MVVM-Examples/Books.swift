//
//  Books.swift
//  Earthquakes
//
//  Created by CONG LE on 10/15/23.
//

import Foundation
import SwiftUI

// MARK: - MODELS
struct Book: Codable, Identifiable {
    let id: String
    let volumeInfo: VolumeInfo
}

struct VolumeInfo: Codable {
    let title: String
    let authors: [String]
    let publisher: String?
    let description: String?
}

struct BooksResponse: Codable {
    let items: [Book]
}

// MARK: Error Cases
enum BooksServiceError: Error {
    case invalidURL
    case noData
    case decodingError
    case responseError
}

// MARK: - SERVICES
class BooksService {
    func fetchBooks(completion: @escaping (Result<[Book], BooksServiceError>) -> Void) {
        guard let url = URL(string: "https://www.googleapis.com/books/v1/volumes?q=harry+potter") else {
            completion(.failure(.invalidURL))
            return
        }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let _ = error {
                DispatchQueue.main.async {
                    completion(.failure(.responseError))
                }
                return
            }
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(.noData))
                }
                return
            }
            do {
                let response = try JSONDecoder().decode(BooksResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(response.items))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.decodingError))
                }
            }
        }.resume()
    }
}

//MARK: - VIEWMODEL
class BooksViewModel: ObservableObject {
    private let booksService: BooksService
    @Published var books = [Book]()
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
                self.error = error
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
                    Text(book.volumeInfo.title).font(.headline)
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
   

