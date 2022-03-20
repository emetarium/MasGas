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

enum Fuels: String, CaseIterable {
    case G95E5 = "G95E5"
    case G95E10 = "G95E10"
    case G95E5P = "G95E5+"
    case G98E5 = "G98E5"
    case G98E10 = "G98E10"
    case GOA = "GOA"
    case GOAP = "GOA+"
    case GOB = "GOB"
    case BIO = "BIO"
    case GLP = "GLP"
    case GNC = "GNC"
    case GNL = "GNL"
}

enum queryByFuelOptions: String, CaseIterable {
    case queryByNearby = "QUERY_BY_NEARBY"
    case queryByCheapest = "QUERY_BY_CHEAPEST"
    case queryByCheapestNearby = "QUERY_BY_CHEAPEST_NEARBY"
}
