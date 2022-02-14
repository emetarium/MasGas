//
//  Constants.swift
//  MasGas
//
//  Created by María García Torres on 14/2/22.
//

import Foundation

enum APIUrls: String {
    case urlMunicipios = "https://sedeaplicaciones.minetur.gob.es/ServiciosRESTCarburantes/PreciosCarburantes/Listados/Municipios/"
    case urlCarburantes = "https://sedeaplicaciones.minetur.gob.es/ServiciosRESTCarburantes/PreciosCarburantes/Listados/ProductosPetroliferos/"
    //Aqui hay que hacer un replace
    case urlBusquedaMunicipiosCarburantes = "https://sedeaplicaciones.minetur.gob.es/ServiciosRESTCarburantes/PreciosCarburantes/EstacionesTerrestres/FiltroMunicipioProducto/{IDMUNICIPIO}/{IDPRODUCTO}"
}
