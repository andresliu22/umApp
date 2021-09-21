//
//  BillingDetail.swift
//  un
//
//  Created by Andres Liu on 1/24/21.
//

import Foundation

struct FacturacionDetalleStruct {
    var name: String
    var consumido: Float
    var pagado: Float
}

struct FacturacionDetalleTabla {
    var mes: String
    var consumido: Float
    var facturado: Float
    var porFacturar: Float
    var pagado: Float
    var porPagar: Float
    var vencido: Float
}
