//
//  Data.swift
//  Social
//
//  Created by Jordan Singer on 12/27/21.
//

import Foundation

let defaultUser = Users(name: "Ezra Ware", username: "eware", bio: "Food aficionado. Friend of animals everywhere. Communicator. Social media fanatic.", avatarURL: "https://media.istockphoto.com/photos/positivity-puts-you-in-a-position-of-power-picture-id1299077582?b=1&k=20&m=1299077582&s=170667a&w=0&h=Esjqlg_WCWmTc83Dv6PLhwPFwYN9uXoclBn0cUhtS5I=", website: "https://website.com", email: "ezra@ware.com")
let user1 = Users(name: "Aliya Coles", username: "acoles", bio: "Entrepreneur. Student. Proud travel lover. Food fanatic. Communicator. Creator. Thinker. Analyst", avatarURL: "https://media.istockphoto.com/photos/smiling-young-woman-beauty-close-up-portrait-picture-id1280113805?b=1&k=20&m=1280113805&s=170667a&w=0&h=wjd1qvAxZkavd83z0OIKK_rUnXPJy-L2z8V2HdBDkp0=", website: nil, email: nil)
let user2 = Users(name: "Edward Winter", username: "edwinter", bio: "Amateur music advocate. Food buff. Bacon specialist. Problem solver.", avatarURL: "https://media.istockphoto.com/photos/m-happy-with-where-my-career-is-heading-picture-id1138617116?b=1&k=20&m=1138617116&s=170667a&w=0&h=qyoCgp5gG34Kj--3WeZVRiCe2ofD6Da9JeMS12gUh8w=", website: nil, email: nil)
let user3 = Users(name: "Jayce Beattie", username: "jbeattie", bio: nil, avatarURL: nil, website: nil, email: nil)
let user4 = Users(name: "Alexis McGill", username: "emcgill", bio: "Travel fanatic. Web guru. Zombie advocate. Tv evangelist. Friendly food expert.", avatarURL: "https://media.istockphoto.com/photos/businesswomans-portrait-picture-id1279504799?b=1&k=20&m=1279504799&s=170667a&w=0&h=Q-qDfKI3nIvLYaFRHL5cBb2m2kwU_q76mqILgEoT_m8=", website: nil, email: nil)
let user5 = Users(name: "Allen Doyle", username: "adoyle", bio: "Amateur coffee guru. Travel fanatic. Zombie ninja. Evil thinker. Music junkie. Gamer. Webaholic. Problem solver.", avatarURL: "https://media.istockphoto.com/photos/africanamerican-businessman-picture-id1300952714?b=1&k=20&m=1300952714&s=170667a&w=0&h=uR9oQqIV5h_yot4i8iL4avnkYvagLtHexdc0YuZ3tO4=", website: nil, email: nil)

let defaultPosts = [
    Post(content: "tonight's dinner 😋", imageURL: "https://images.unsplash.com/photo-1539136788836-5699e78bfc75?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=960&q=80", user: defaultUser, replies: [
        Post(content: "Yum", imageURL: nil, user: user1, replies: [])
    ]),
    Post(content: "Central Park", imageURL: "https://images.unsplash.com/photo-1603471759569-2bfc3a180309?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=960&q=80", user: user1, replies: []),
    Post(content: "who's coming to the party tonight?", imageURL: nil, user: user2, replies: [
        Post(content: "me!", imageURL: nil, user: defaultUser, replies: []),
        Post(content: "See you there.", imageURL: nil, user: user5, replies: [])
    ]),
    Post(content: "just setting up my feedr", imageURL: nil, user: user3, replies: []),
    Post(content: "We're hiring customer support specialists. Let me know if anyone comes to mind!", imageURL: nil, user: user4, replies: [
        Post(content: "I'll DM you.", imageURL: nil, user: defaultUser, replies: [])
    ]),
    Post(content: "And we're off ✈️", imageURL: "https://images.unsplash.com/photo-1575427862440-9afbff3e64ac?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=960&q=80", user: user5, replies: [
        Post(content: "have fun!", imageURL: nil, user: user4, replies: [])
    ]),
    Post(content: "who has recommendations for a dentist near the park?", imageURL: nil, user: defaultUser, replies: []),
]

let defaultActivity = [
    Activity(type: .liked, user: user1),
    Activity(type: .followed, user: user2),
    Activity(type: .liked, user: user2),
    Activity(type: .followed, user: user3),
    Activity(type: .followed, user: user4),
    Activity(type: .followed, user: user5),
    Activity(type: .liked, user: user3),
    Activity(type: .followed, user: user1),
    Activity(type: .liked, user: user4),
    Activity(type: .liked, user: user5),
]

let defaultNodes = ["apple", "create", "macos", "ios"]

class AppData: ObservableObject {
    @Published var currentUser = defaultUser
    @Published var posts: [Post] = defaultPosts.shuffled()
    @Published var nodes = defaultNodes
    @Published var currentNode = "apple"
    
    var activity: [Activity] = defaultActivity.shuffled()
    
    func addNewPost(_ content: String) {
        let newPost = Post(content: content, imageURL: nil, user: currentUser, replies: [])
        self.posts.insert(newPost, at: 0)
    }
    
    func replyToPost(_ content: String, post: Post) {
        let newReply = Post(content: content, imageURL: nil, user: currentUser, replies: [])
        post.replies.insert(newReply, at: 0)
    }
    
    func getPostsByUserID(_ userID: UUID) -> [Post] {
        return posts.filter { $0.user.id == userID }
    }
    
    func recentlyActiveUsers() -> [Users] {
        return posts.map { $0.user }.filter { $0.id != currentUser.id }
    }
    
    func switchNode(name: String) {
        currentNode = name
    }
    
    func addNode(name: String) {
        nodes.append(name)
        currentNode = name
    }
}

class Post: ObservableObject {
    var id = UUID()
    var content: String
    var imageURL: String?
    var user: Users
    var createdAt = Date().addingTimeInterval(-5000)
    var likes = Int.random(in: 1..<10)
    @Published var replies: [Post]
    
    init(content: String, imageURL: String?, user: Users, replies: [Post]) {
        self.content = content
        self.imageURL = imageURL
        self.user = user
        self.replies = replies
    }
    
    func formattedDate() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: self.createdAt, relativeTo: Date()).replacingOccurrences(of: ".", with: "").replacingOccurrences(of: "ago", with: "")
    }
}

enum ActivityType {
    case followed
    case liked
}

struct Activity {
    var id = UUID()
    var type: ActivityType
    var user: Users
    var post: Post?
    var createdAt = Date()
}

class Users: ObservableObject {
    var id = UUID()
    var name: String
    var username: String
    var bio: String?
    var avatarURL: String?
    var website: String?
    var email: String?
    
    init(name: String, username: String, bio: String?, avatarURL: String?, website: String?, email: String?) {
        self.name = name
        self.username = username
        self.bio = bio
        self.avatarURL = avatarURL
        self.website = website
        self.email = email
    }
}
