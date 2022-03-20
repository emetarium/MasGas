//
//  Consulta.swift
//  MasGas
//
//  Created by María García Torres on 14/2/22.
//

import Foundation

struct Consulta: Codable {
    let fecha: String
    let listaPrecio: [ListaEESSPrecio]
    let nota: String
    let resultadoConsulta: String
    
    enum CodingKeys: String, CodingKey {
        case fecha = "Fecha"
        case listaPrecio = "ListaEESSPrecio"
        case nota = "Nota"
        case resultadoConsulta = "ResultadoConsulta"
    }
}
