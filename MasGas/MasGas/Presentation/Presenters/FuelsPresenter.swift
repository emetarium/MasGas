//
//  FuelsPresenter.swift
//  MasGas
//
//  Created by María García Torres on 19/2/22.
//

import Foundation
import CoreLocation

class FuelsPresenter<FuelSelectionProtocol>: BasePresenter {
    let fetchFuelsUseCase: FetchFuelsUseCase?
    let fetchTownsUseCase: FetchTownsUseCase?
    let fetchSelectedTownUseCase: FetchSelectedTownUseCase?
    let deleteAccountUseCase: DeleteAccountUseCase?
    let logoutUseCase: LogOutUseCase?
    let isLocationEnabledUseCase: IsLocationEnabledUseCase?
    let getLocationUseCase: GetLocationUseCase?
    let view: FuelsViewController
    
    init(_ view: FuelsViewController) {
        self.view = view
        self.fetchFuelsUseCase = FetchFuelsUseCase()
        self.fetchTownsUseCase = FetchTownsUseCase()
        self.fetchSelectedTownUseCase = FetchSelectedTownUseCase()
        self.deleteAccountUseCase = DeleteAccountUseCase()
        self.isLocationEnabledUseCase = IsLocationEnabledUseCase()
        self.getLocationUseCase = GetLocationUseCase()
        self.logoutUseCase = LogOutUseCase()
    }
    
    func fetchSelectedTown() {
        self.view.showLoadingIndicator()
        if let town = self.fetchSelectedTownUseCase?.execute() {
            
            if let isLocationEnabled = isLocationEnabledUseCase?.execute(), isLocationEnabled {
                self.getLocationUseCase?.execute(completion: { location in
                    let geoCoder = CLGeocoder()
                    if let location {
                        geoCoder.reverseGeocodeLocation(location) { placemarks, error in
                            guard let placeMark = placemarks?.first else { return }
                            if let dictionary = placeMark.addressDictionary, let city = dictionary["City"] as? String,  town.nombreMunicipio.formatName() != city {
                                self.fetchTownsUseCase?.execute(completion: { towns in
                                    let newTown = towns.filter { $0.nombreMunicipio.formatName() == city }
                                    self.view.showChangeTownAlert(town: newTown[0])
                                })
                            }
                        }
                    }
                })
            }
            
            self.view.updateTown(town: town)
        }
        self.view.hideLoadingIndicator()
    }
    
    func saveTown(town: Municipio) {
        do {
            let encoder = JSONEncoder()

            let data = try encoder.encode(town)

            UserDefaults.standard.set(data, forKey: "Town")
        } catch { }
        self.view.updateTown(town: town)
    }
    
    func fetchFuels() {
        self.view.showLoadingIndicator()
        fetchFuelsUseCase?.execute(completion: { fuels in
            self.view.updateFuels(fuels: fuels)
            self.view.hideLoadingIndicator()
        })
    }
    
    func logout() {
        logoutUseCase?.execute()
        self.view.navigateToLogin()
    }
    
    func deleteAccount() {
        deleteAccountUseCase?.execute(completion: { error in
            print(error?.localizedDescription)
        })
        logout()
    }
    
    func checkInternetConnection() {
        if !isInternetAvailable() {
            self.view.showNoConnectionAlert()
        }
    }
}
