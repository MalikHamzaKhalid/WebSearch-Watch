//
//  ContentViewModel.swift
//  WatchOS-biltz Watch App

import SwiftUI

class ContentViewModel: ObservableObject {
    
    static let shared = ContentViewModel()
    
    @Published var items: [Item] = []
    @Published var errorMessage: String = ""
    private var currentPage = 0
    private var resultsPerPage = 10 // Change this based on your API settings
    var isLoading = false
    
    private let apiKey = "AIzaSyB9eX9rPia-rd4Ca9whwrI5ZqiEl_-PWx0"
    private let cx = "66718f87f2dfc45ac"
    
    func requestNextPage(searchText: String) {
        guard !isLoading else { return }  // Prevent multiple simultaneous requests
        currentPage += 1
        fetchData(searchText: searchText, page: currentPage)
    }
    
    func fetchData(searchText: String, page: Int = 0) {
        guard !searchText.isEmpty else { return }
        
        guard !isLoading else { return } // Prevent multiple simultaneous requests
        
        currentPage = page
        isLoading = true
        
        let query = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        // Calculate the correct start index based on currentPage and resultsPerPage
       
        let startIndex = resultsPerPage * currentPage
        
//        if currentPage == 0 {
//            startIndex = 0
//        }
        
        let urlString = "https://customsearch.googleapis.com/customsearch/v1?q=\(query)&key=\(apiKey)&cx=\(cx)&start=\(startIndex)"
        
        guard let url = URL(string: urlString) else {
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
            guard let self = self else { return }
            
            defer {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
            
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response")
                return
            }
            
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(TasksListDAO.self, from: data)
                    print("Status: \(String(describing: response.status))")
                    if httpResponse.statusCode != 200 {
                        DispatchQueue.main.async {
                            self.isLoading = false
                            self.errorMessage = response.message ?? ""
                            print("Status code = \(httpResponse.statusCode)")
                            print("Error message = \(self.errorMessage)")
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.errorMessage = ""
                        }
                    }
                    if let newItems = response.items {
                        DispatchQueue.main.async {
                            if self.currentPage == 0 {
                                self.items = newItems
                            } else {
                                self.items.append(contentsOf: newItems)
                            }
                        }
                    }
                } catch {
                    print("Error decoding response: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
}


struct TasksListDAO: Codable {
    let message: String?
    let status: String?
    let items: [Item]?
}

struct Item: Codable, Identifiable {
    var id: String = UUID().uuidString // Automatically generate an ID
    let title, htmlTitle: String?
    let link: String?
    let displayLink, snippet, htmlSnippet: String?
    
    // Custom initializer to set the ID after decoding
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.title = try container.decodeIfPresent(String.self, forKey: .title)
            self.htmlTitle = try container.decodeIfPresent(String.self, forKey: .htmlTitle)
            self.link = try container.decodeIfPresent(String.self, forKey: .link)
            self.displayLink = try container.decodeIfPresent(String.self, forKey: .displayLink)
            self.snippet = try container.decodeIfPresent(String.self, forKey: .snippet)
            self.htmlSnippet = try container.decodeIfPresent(String.self, forKey: .htmlSnippet)
            // Assign a unique ID after decoding
            self.id = UUID().uuidString
        }

        // Default initializer for manual creation of Item objects
        init(id: String = UUID().uuidString, title: String?, htmlTitle: String?, link: String?, displayLink: String?, snippet: String?, htmlSnippet: String?) {
            self.id = id
            self.title = title
            self.htmlTitle = htmlTitle
            self.link = link
            self.displayLink = displayLink
            self.snippet = snippet
            self.htmlSnippet = htmlSnippet
        }

        // Define the keys used in the decoding process
        enum CodingKeys: String, CodingKey {
            case title, htmlTitle, link, displayLink, snippet, htmlSnippet
        }
}