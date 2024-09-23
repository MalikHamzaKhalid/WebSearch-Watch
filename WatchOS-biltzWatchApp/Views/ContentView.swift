//
//  ContentView.swift
//  WatchOS-biltz Watch App


import SwiftUI
import AuthenticationServices

struct ContentView: View {
    
    @StateObject private var viewModel = ContentViewModel()
    @State private var searchText = ""
    
    var body: some View {
        let binding = Binding<String>(
            get: { self.searchText },
            set: {
                self.searchText = $0
                viewModel.fetchData(searchText: self.searchText)
            }
        )
        
        NavigationStack {
            VStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search", text: binding)
                        .foregroundColor(.white).padding(.vertical, -20)
                }
                .padding()
                .background(Color.gray.opacity(0.3))
                .cornerRadius(8)
                .padding(.bottom)
                
                // Results list
                List {
                    ForEach(viewModel.items, id: \.id) { item in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(item.title ?? "")
                                    .font(.system(size: 14))
                                    .lineLimit(3)
                                
                                Button(action: {
                                    viewModel.openUrl(url: item.link ?? "")
                                }) {
                                    HStack {
                                        Text(item.displayLink ?? "")
                                            .font(.system(size: 12))
                                            .foregroundColor(.blue)
                                            .lineLimit(1)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 4)
                        .onAppear {
                            // Check if the current item is the last one
                            if item.id == viewModel.items.last?.id {
                                viewModel.requestNextPage(searchText: searchText)
                            }
                        }
                    }
                    
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .listStyle(CarouselListStyle())
            }
            .sheet(isPresented: $viewModel.showPurchaseAlert) {
                InAppPurchaseView()
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape")
                            .imageScale(.small)
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
