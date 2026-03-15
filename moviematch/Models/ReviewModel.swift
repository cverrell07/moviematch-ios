//
//  ReviewModel.swift
//  moviematch
//
//  Created by Christopher Verrell on 15/03/26.
//

struct ReviewResponse: Decodable {
    let id: Int
    let page: Int
    let results: [Review]
    let totalPages: Int
    
    enum CodingKeys: String, CodingKey {
        case id, page, results
        case totalPages = "total_pages"
    }
}

struct Review: Decodable {
    let authorDetails: AuthorDetails?
    let content: String
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case authorDetails = "author_details"
        case content
        case createdAt = "created_at"
    }
}

struct AuthorDetails: Decodable {
    let name: String?
    let username: String?
    let avatarPath: String?
    let rating: Int?
    
    enum CodingKeys: String, CodingKey {
        case name, username, rating
        case avatarPath = "avatar_path"
    }
}
