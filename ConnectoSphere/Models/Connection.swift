//
//  Connection.swift
//  ConnectoSphere
//
//
import Foundation

struct Connection: Identifiable, Codable {
    let id: String
    let userID: String
    let matchScore: Double
    let commonCircles: [String]
    let commonTags: [String]
}

