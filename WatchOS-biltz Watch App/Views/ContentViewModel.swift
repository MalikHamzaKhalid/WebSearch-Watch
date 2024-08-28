//
//  ContentViewModel.swift
//  WatchOS-biltz Watch App

import SwiftUI

class ContentViewModel: ObservableObject {
    
    static let shared = ContentViewModel()
    
    @Published var items: [Item] = []
    @Published var errorMessage: String = ""
    private var currentPage = 0
    var isLoading = false
    
    func requestNextPage(searchText: String) {
        guard !isLoading else { return }  // Prevent multiple simultaneous requests
        currentPage += 1
        fetchData(searchText: searchText, page: currentPage)
    }
    
    func fetchData(searchText: String, page: Int = 0) {
        guard !searchText.isEmpty else { return }
        
        currentPage = page
        isLoading = true
        
        let headers = [
            "X-RapidAPI-Key": "5d5f123215mshe2de294047c807ep14997ejsnae4da76a4c07",
            "X-RapidAPI-Host": "google-search72.p.rapidapi.com"
        ]
        
        let urlString = "https://google-search72.p.rapidapi.com/search?q=\(searchText)&gl=us&lr=en&num=20&start=\(currentPage)&sort=relevance"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        guard let url = URL(string: urlString ?? "") else {
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
            guard let self = self else { return }
            
            defer {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
            
            if let error = error {
                print("Error: \(error.localizedDescription)")
                isLoading = false
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response")
                isLoading = false
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
                        errorMessage = ""
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
    var id: String? = UUID().uuidString
    let title, htmlTitle: String?
    let link: String?
    let displayLink, snippet, htmlSnippet: String?
}
