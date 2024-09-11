//
//  BusquedaPreciosGasolinera.swift
//  MasGas
//
//  Created by María García Torres on 8/9/24.
//

import Foundation

struct PreciosGasolinera {
    var gasolinera: Gasolinera
    var precios: [PrecioCarburante]
//    var G95E5Price: PrecioCarburante?
//    var G95E5PPrice: PrecioCarburante?
//    var G98E5Price: PrecioCarburante?
//    var GOAPrice: PrecioCarburante?
//    var GOAPPrice: PrecioCarburante?
//    var GLPPrice: PrecioCarburante?
}

struct PrecioCarburante {
    var carburante: Carburante
    var precio: String
}

//struct BusquedaPreciosGasolinera {
//    var gasolinera: Gasolinera
//    var G95E5Price: String?
//    var G95E5PPrice: String?
//    var G98E5Price: String?
//    var GOAPrice: String?
//    var GOAPPrice: String?
//    var GLPPrice: String?
//}
