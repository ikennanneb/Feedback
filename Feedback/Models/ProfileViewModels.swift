//
//  ProfileViewModels.swift
//  Feedback
//
//  Created by Ikenna on 3/11/24.
//

import Foundation

enum ProfileViewModelType
{
    case info, logout
}

struct ProfileViewModel
{
    let viewModelType: ProfileViewModelType
    let title: String
    let handler: (() -> Void)?
}
