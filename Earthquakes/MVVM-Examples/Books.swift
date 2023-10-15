//
//  Books.swift
//  Earthquakes
//
//  Created by CONG LE on 10/15/23.
//

import Foundation
import SwiftUI

// MARK: - MODELS

struct BookResponse: Codable {
    let kind: String
    let totalItems: Int
    let items: [Item]
}

struct Item: Codable, Identifiable {
    let kind: String
    let id: String
    let etag: String
    let selfLink: String
    let volumeInfo: VolumeInfo
}

struct VolumeInfo: Codable {
    let title: String
    let subtitle: String?
    let authors: [String]
    let publisher: String?
    let publishedDate: String
    let description: String
    let industryIdentifiers: [IndustryIdentifier]
    let readingModes: ReadingModes
    let pageCount: Int?
    let printType: String
    let categories: [String]?
    let averageRating: Double?
    let ratingsCount: Int?
    let maturityRating: String?
    let allowAnonLogging: Bool?
    let contentVersion: String?
    let panelizationSummary: PanelizationSummary?
    let imageLinks: ImageLinks
    let language: String
    let previewLink: String
    let infoLink: String
    let canonicalVolumeLink: String
}

struct IndustryIdentifier: Codable {
    let type: String
    let identifier: String
}

struct ReadingModes: Codable {
    let text: Bool
    let image: Bool
}

struct PanelizationSummary: Codable {
    let containsEpubBubbles, containsImageBubbles: Bool?
}

struct ImageLinks: Codable {
    let smallThumbnail, thumbnail: String
}

// MARK: - Error Cases
enum BooksServiceError: Error {
    case invalidURL
    case noData
    case decodingError
    case responseError
}

// MARK: - SERVICES
class BooksService {
    func fetchBooks(completion: @escaping (Result<[Item], BooksServiceError>) -> Void) {
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
                let response = try JSONDecoder().decode(BookResponse.self, from: data)
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
                    Text(book.volumeInfo.authors.first ?? "Anonymous").font(.subheadline)
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
   

