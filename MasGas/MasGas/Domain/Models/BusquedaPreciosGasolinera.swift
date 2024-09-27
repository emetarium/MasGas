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
}

struct PrecioCarburante {
    var carburante: Carburante
    var precio: String
}
