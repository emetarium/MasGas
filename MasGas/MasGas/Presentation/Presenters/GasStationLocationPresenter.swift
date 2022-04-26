//
//  GasStationLocationPresenter.swift
//  MasGas
//
//  Created by María García Torres on 15/3/22.
//

import Foundation
import UIKit

class GasStationLocationPresenter: BasePresenter {
    let view: GasStationLocationViewController
    let saveFavoriteUseCase: SaveFavoriteGasStationUseCase?
    let isLocationEnabledUseCase: IsLocationEnabledUseCase?
    let getLocationUseCase: GetLocationUseCase?
    let removeFavoriteUseCase: RemoveFavoriteUseCase?
    
    init(_ view: GasStationLocationViewController) {
        self.view = view
        self.saveFavoriteUseCase = SaveFavoriteGasStationUseCase()
        self.isLocationEnabledUseCase = IsLocationEnabledUseCase()
        self.getLocationUseCase = GetLocationUseCase()
        self.removeFavoriteUseCase = RemoveFavoriteUseCase()
    }
    
    func getLocation() {
        self.view.showLoadingIndicator()
        guard let isLocationEnabled = isLocationEnabledUseCase?.execute() else { return }
        if isLocationEnabled {
            getLocationUseCase?.execute(completion: { location in
                self.view.hideLoadingIndicator()
                guard let location = location else {
                    let accept = UIAlertAction(title: NSLocalizedString("ACCEPT_ACTION", comment: ""), style: .default) { accept in
                        self.view.navigationController?.popViewController(animated: true)
                    }
                    self.view.showAlert(title: "", message: NSLocalizedString("NO_LOCATION_ERROR_MESSAGE", comment: ""), alternativeAction: nil, acceptAction: accept)
                    return
                }
                self.view.updateLocation(location: location)
            })
        } else {
            let acceptAction = UIAlertAction(title: NSLocalizedString("ACCEPT_ACTION", comment: ""), style: .default)
            self.view.showAlert(title: NSLocalizedString("NO_ROUTE_ERROR_TITLE", comment: ""), message: NSLocalizedString("NO_LOCATION_PERMISSION_MESSAGE", comment: ""), alternativeAction: nil, acceptAction: acceptAction)
            self.view.hideLoadingIndicator()
        }
    }
    
    func saveFavorite(gasStation: Gasolinera) {
        saveFavoriteUseCase?.execute(gasStation: gasStation)
    }
    
    func removeFavorite(gasStation: Gasolinera) {
        removeFavoriteUseCase?.execute(gasStation: gasStation)
    }
    
    func checkInternetConnection() {
        if !isInternetAvailable() {
            self.view.showNoConnectionAlert()
        }
    }
}
