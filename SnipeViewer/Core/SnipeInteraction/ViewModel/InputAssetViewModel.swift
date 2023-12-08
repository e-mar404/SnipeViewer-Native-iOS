//
//  InputAssetViewModel.swift
//  SnipeViewer
//
//  Created by Emilio Marin on 11/27/23.
//

import Foundation

// protocol that extentions for the form validations need to conform to (they have to return a Bool to see if they are valid)
protocol AssetFormProtocol {
    var formIsValid: Bool { get }
}
