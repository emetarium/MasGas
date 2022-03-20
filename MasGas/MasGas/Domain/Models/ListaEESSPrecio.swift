//
//  ListaEESSPrecio.swift
//  MasGas
//
//  Created by María García Torres on 14/2/22.
//

import Foundation

struct ListaEESSPrecio: Codable {
    let codigoPostal: String
    let direccion: String
    let horario: String
    let latitud: String
    let localidad: String
    let longitud: String
    let margen: String
    let municipio: String
    let precioProducto: String
    let provincia: String
    let remision: String
    let rotulo: String
    let tipoVenta: String
    let idEESS: String
    let idMunicipio: String
    let idProvincia: String
    let idCCAA: String
    
    enum CodingKeys: String, CodingKey {
        case codigoPostal = "C.P."
        case direccion = "Dirección"
        case horario = "Horario"
        case latitud = "Latitud"
        case localidad = "Localidad"
        case longitud = "Longitud (WGS84)"
        case margen = "Margen"
        case municipio = "Municipio"
        case precioProducto = "PrecioProducto"
        case provincia = "Provincia"
        case remision = "Remisión"
        case rotulo = "Rótulo"
        case tipoVenta = "Tipo Venta"
        case idEESS = "IDEESS"
        case idMunicipio = "IDMunicipio"
        case idProvincia = "IDProvincia"
        case idCCAA = "IDCCAA"
    }
}
