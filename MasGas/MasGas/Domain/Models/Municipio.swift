//
//  Municipio.swift
//  MasGas
//
//  Created by María García Torres on 14/2/22.
//

import Foundation

struct Municipio: Codable {
    let idMunicipio: String
    let idProvincia: String
    let idCCAA: String
    let nombreMunicipio: String
    let nombreProvincia: String
    let nombreCCAA: String
    
    enum CodingKeys: String, CodingKey {
        case idMunicipio = "IDMunicipio"
        case idProvincia = "IDProvincia"
        case idCCAA = "IDCCAA"
        case nombreMunicipio = "Municipio"
        case nombreProvincia = "Provincia"
        case nombreCCAA = "CCAA"
    }
}
