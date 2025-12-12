//
//  CirclesViewModel.swift
//  ConnectoSphere
//
//

import Foundation
import Combine

class CirclesViewModel: ObservableObject {
    @Published var allCircles: [Circle] = []
    @Published var myCircles: [Circle] = []
    @Published var searchText = ""
    
    private let dataService = DataService.shared
    private let authService = AuthService.shared
    private var cancellables = Set<AnyCancellable>()
    
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
        setupRealtimeUpdates()
        loadCircles()
    }
    
    private func setupRealtimeUpdates() {
        // Подписываемся на изменения circles
        dataService.$circles
            .assign(to: \.allCircles, on: self)
            .store(in: &cancellables)
        
        // Подписываемся на изменения myCircles
        Publishers.CombineLatest(
            dataService.$circles,
            authService.$currentUser
        )
        .map { circles, currentUser in
            guard let userID = currentUser?.id else { return [] }
            return circles.filter { $0.memberIDs.contains(userID) }
        }
        .assign(to: \.myCircles, on: self)
        .store(in: &cancellables)
    }
    
    func loadCircles() {
        allCircles = dataService.circles
        guard let userID = authService.currentUser?.id else { return }
        myCircles = dataService.getUserCircles(userID: userID)
    }
    
    func joinCircle(_ circle: Circle) {
        guard let userID = authService.currentUser?.id else { return }
        dataService.joinCircle(circleID: circle.id, userID: userID)
        // Автоматически обновится через Combine
    }
    
    func leaveCircle(_ circle: Circle) {
        guard let userID = authService.currentUser?.id else { return }
        dataService.leaveCircle(circleID: circle.id, userID: userID)
        // Автоматически обновится через Combine
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
        // Автоматически обновится через Combine
    }
}

