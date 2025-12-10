//
//  CirclesViewModel.swift
//  ConnectoSphere
//
//

import Foundation

class CirclesViewModel: ObservableObject {
    @Published var allCircles: [Circle] = []
    @Published var myCircles: [Circle] = []
    @Published var searchText = ""
    
    private let dataService = DataService.shared
    private let authService = AuthService.shared
    
    var filteredCircles: [Circle] {
        if searchText.isEmpty {
            return allCircles
        }
        return allCircles.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.description.localizedCaseInsensitiveContains(searchText) ||
            $0.tags.contains(where: { $0.localizedCaseInsensitiveContains(searchText) })
        }
    }
    
    init() {
        loadCircles()
    }
    
    func loadCircles() {
        allCircles = dataService.circles
        guard let userID = authService.currentUser?.id else { return }
        myCircles = dataService.getUserCircles(userID: userID)
    }
    
    func joinCircle(_ circle: Circle) {
        guard let userID = authService.currentUser?.id else { return }
        dataService.joinCircle(circleID: circle.id, userID: userID)
        loadCircles()
    }
    
    func leaveCircle(_ circle: Circle) {
        guard let userID = authService.currentUser?.id else { return }
        dataService.leaveCircle(circleID: circle.id, userID: userID)
        loadCircles()
    }
    
    func isUserMember(of circle: Circle) -> Bool {
        guard let userID = authService.currentUser?.id else { return false }
        return circle.memberIDs.contains(userID)
    }
    
    func createCircle(name: String, description: String, category: String, tags: [String]) {
        guard let userID = authService.currentUser?.id else { return }
        _ = dataService.createCircle(
            name: name,
            description: description,
            category: category,
            tags: tags,
            creatorID: userID
        )
        loadCircles()
    }
}

