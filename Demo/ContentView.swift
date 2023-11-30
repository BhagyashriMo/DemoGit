//
//  ContentView.swift
//  Demo
//
//  Created by Bhagyashree Modak on 11/29/23.
//

import SwiftUI

struct MovieResponse: Codable {
    let page: Int
    let results: [Movie]
    let total_pages: Int
    let total_results: Int
}

struct Movie: Identifiable, Codable {
    let id: Int
    let adult: Bool
    let backdrop_path: String?
    let genre_ids: [Int]
    let original_language: String
    let original_title: String
    let overview: String
    let popularity: Double
    let poster_path: String
    let release_date: String
    let title: String
    let video: Bool
    let vote_average: Double
    let vote_count: Int
}

class MovieViewModel: ObservableObject {
    @Published var movies = [Movie]()
    
    func fetchData() {
        
        var components = URLComponents(string: "https://api.themoviedb.org/3/movie/popular")!
        components.queryItems = [
            URLQueryItem(name: "language", value: "en-US"),
            URLQueryItem(name: "page", value: "1")
        ]
        let url = components.url!
        
        let headers = [
            "accept": "application/json",
            "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJiYzRjMmQ4ZTRhYTBmNTY2YTFhZGMyYTI5MTkxZGEyZiIsInN1YiI6IjY1NjVjNjczM2Q3NDU0MDBjOWM0Y2I4ZSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.52DuH5IDL01eK5D0eLT5ktdl4DWxUGc94pArrdtQsNA"
        ]
        let request = NSMutableURLRequest(url: url,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        URLSession.shared.dataTask(with: request as URLRequest) { data, _, error in
            if let data = data {
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Received JSON string: \(jsonString)")
                }
                do {
                    let decoder = JSONDecoder()
                    let movieResponse = try decoder.decode(MovieResponse.self, from: data)
                    print(movieResponse.page)
                    DispatchQueue.main.async {
                        self.movies = movieResponse.results
                    }
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            } else if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
            }
        }.resume()
    }
}

struct ContentView: View {
    @ObservedObject var viewModel = MovieViewModel()
    
    var body: some View {
        NavigationView {
            List(viewModel.movies) { movie in
                NavigationLink(destination: MovieDetailView(movie: movie)) {
                    MovieRow(movie: movie)
                }
            }
            .onAppear {
                viewModel.fetchData()
            }
            .navigationTitle("Popular Movies")
        }
        .environmentObject(viewModel)
    }
}

struct MovieRow: View {
    let movie: Movie
    
    var body: some View {
        VStack(alignment: .leading) {
            
            Text(movie.original_title)
                .bold()
                .lineLimit(1)
                .padding(5)

            AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w500" + (movie.poster_path ?? "")))
                    .frame(width: 200, height: 200)
                    .aspectRatio(contentMode: .fill)
                    .clipped()
                    .overlay(
                        Text(movie.original_title)
                            .bold()
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .lineLimit(1),
                        alignment: .bottomLeading
                    )
            
            Text(movie.overview)
                .font(.caption)
                .foregroundColor(.black)
                .lineLimit(2)

            Text(movie.original_language)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)

            Text(movie.release_date)
                .font(.caption)
                .foregroundColor(.red)
                .lineLimit(3)
        }
    }
}

struct MovieDetailView: View {
    @EnvironmentObject var viewModel: MovieViewModel
    let movie: Movie?
    
    var body: some View {
        if let movie = movie {
            VStack(alignment: .leading){
                
                AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w500" + (movie.backdrop_path ?? "")))
                    .frame(width: 250, height: 250)
                    .aspectRatio(contentMode: .fill)

                Text(movie.overview)
                    .padding()
                
                Text(movie.release_date)
                    .padding()
            }
            .navigationTitle(movie.original_title)
        } else {
            Text("Movie details not available")
        }
    }
}


