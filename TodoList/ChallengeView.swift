//
//  ChallengeView.swift
//  TodoList
//
//  Created by Andrew Mankin on 12/3/25.
//

import SwiftUI

struct ChallengeView: View {
    var body: some View {
        List {
            Section(header: Text("Daily")) {
                HStack {
                    Image(systemName: false ? "checkmark.square.fill" : "square")
                        .foregroundColor(false ? Color.green : Color.black)
                    Text("Complete 5 Items")
                }
                HStack {
                    Image(systemName: false ? "checkmark.square.fill" : "square")
                        .foregroundColor(false ? Color.green : Color.black)
                    Text("Add 2 new Items")
                }
            }
            Section(header: Text("Weekly")) {
                HStack {Text("Chal 1")}
                HStack {Text("Chal 2")}
            }
        }
    }
}

#Preview {
    ChallengeView()
}
