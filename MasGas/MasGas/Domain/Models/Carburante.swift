//
//  Carburante.swift
//  MasGas
//
//  Created by María García Torres on 14/2/22.
//

import Foundation

struct Carburante: Codable {
    let idProducto: String
    let nombreProducto: String
    let nombreProductoAbreviatura: String
    
    enum CodingKeys: String, CodingKey {
        case idProducto = "IDProducto"
        case nombreProducto = "NombreProducto"
        case nombreProductoAbreviatura = "NombreProductoAbreviatura"
    }
}
