//
//  String.swift
//  MasGas
//
//  Created by María García Torres on 14/2/22.
//

import Foundation

extension String {
    func replace(occurrences: [String : String]) -> String {
        var replaced = self
        occurrences.forEach { occurrence in
            replaced = replaced.replacingOccurrences(of: occurrence.key, with: occurrence.value)
        }
        return replaced
    }
    
    func formatName() -> String {
        var separatedName = self.components(separatedBy: CharacterSet(charactersIn: "()"))
        if separatedName.count > 1 {
            var removeLast = separatedName[0].removeLast()
            let finalName = separatedName[1] + " " + separatedName[0]
            return finalName
        } else {
            return self
        }
    }
}
