//
//  Redux.swift
//  BSDRandom
//
//  Created by 전건우 on 05/05/2019.
//  Copyright © 2019 geonu. All rights reserved.
//

import Foundation
import ReSwift

typealias AppState = Redux.AppState
typealias AppAction = Redux.AppAction

final class Redux {
    struct AppState: StateType {
        var users: [User] = [
            User(name: "조창환 수석연구원", phoneNumber: "010-9011-1616", isSelected: false),
            User(name: "이재희 책임연구원", phoneNumber: "010-9484-7597", isSelected: false),
            User(name: "박상오 선임연구원", phoneNumber: "010-2829-8681", isSelected: false),
            User(name: "박준영 선임연구원", phoneNumber: "010-9100-4883", isSelected: false),
            User(name: "조슬기 주임연구원", phoneNumber: "010-8446-5057", isSelected: false),
            User(name: "임희섭 주임연구원", phoneNumber: "010-4065-2126", isSelected: false),
            User(name: "신동준 주임연구원", phoneNumber: "010-9111-8889", isSelected: false),
            User(name: "배연정 연구원", phoneNumber: "010-6250-7818", isSelected: false),
            User(name: "양원희 연구원", phoneNumber: "010-4425-5295", isSelected: false),
            User(name: "임다미 연구원", phoneNumber: "010-8286-5260", isSelected: false),
            User(name: "전건우 연구원", phoneNumber: "010-7125-5467", isSelected: false),
            User(name: "황형언 연구원", phoneNumber: "010-4018-3053", isSelected: false),
            User(name: "변재혁 연구원", phoneNumber: "010-5097-0073", isSelected: false),
            User(name: "이용준 연구원", phoneNumber: "010-3248-2227", isSelected: false),
            User(name: "한혜수 연구원", phoneNumber: "010-7579-4815", isSelected: false),
            User(name: "박윤아 연구원", phoneNumber: "010-2208-8229", isSelected: false)
        ]
        var selectedAllUsers: Bool {
            return users.count == selectedUsersCount
        }
        var selectedUsers: [User] {
            return users.filter { $0.isSelected == true }
        }
        var selectedUsersCount: Int {
            return selectedUsers.count
        }
        var message: String = ""
        var targetCount: Int = 0
        
        mutating func adjustTagetCount() {
            if targetCount > selectedUsersCount {
                targetCount = selectedUsersCount
            }
        }
    }
    
    enum AppAction: Action {
        case setUser(value: Bool, index: Int)
        case setMessage(value: String)
        case setTargerCount(value: Int)
        case selectOrDeselectAllUsers
    }
    
    static let shared: Redux = .init()
    
    private var _store: Store<AppState>? = nil
    var store: Store<AppState> {
        get {
            if _store == nil {
                _store = Store(reducer: appReducer, state: nil)
            }
            return _store!
        }
    }
    
    private init() {
    }
    
    private func appReducer(action: Action, state: AppState?) -> AppState {
        var state = state ?? AppState()
        guard let action = action as? AppAction else {
            return state
        }
        switch action {
        case .setUser(let value, let index):
            state.users[index].isSelected = value
            state.adjustTagetCount()
        case .setTargerCount(let value):
            state.targetCount = value
        case .setMessage(let value):
            state.message = value
        case .selectOrDeselectAllUsers:
            let isSelected = !state.selectedAllUsers
            for i in 0 ..< state.users.count {
                state.users[i].isSelected = isSelected
            }
            state.adjustTagetCount()
        }
        return state
    }
}
