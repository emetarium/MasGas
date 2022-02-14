//
//  ListaEESSPrecio.swift
//  MasGas
//
//  Created by María García Torres on 14/2/22.
//

import Foundation

class ListaEESSPrecio: Codable {
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
        case longitud = "Longitud_x0020__x0028_WGS84_x0029_"
        case margen = "Margen"
        case municipio = "Municipio"
        case precioProducto = "PrecioProducto"
        case provincia = "Provincia"
        case remision = "Remisión"
        case rotulo = "Rótulo"
        case tipoVenta = "Tipo_x0020_Venta"
        case idEESS = "IDEESS"
        case idMunicipio = "IDMunicipio"
        case idProvincia = "IDProvincia"
        case idCCAA = "IDCCAA"
    }
}
