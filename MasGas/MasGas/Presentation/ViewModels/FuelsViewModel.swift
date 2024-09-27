//
//  FuelsViewModel.swift
//  MasGas
//
//  Created by María García Torres on 25/9/24.
//

import Foundation
import CoreLocation

protocol FuelsViewModelDelegate {
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func setFuels(fuels: [Carburante])
    func setSelectedTown(town: Municipio)
    func showChangeTownAlert(town: Municipio)
    func navigateToLogin()
}

class FuelsViewModel {
    
    var delegate: FuelsViewModelDelegate?
    
    func fetchSelectedTown() {
        self.delegate?.showLoadingIndicator()
        if let town = FetchSelectedTownUseCase().execute() {
            
            if IsLocationEnabledUseCase().execute() {
                GetLocationUseCase().execute(completion: { location in
                    let geoCoder = CLGeocoder()
                    if let location {
                        geoCoder.reverseGeocodeLocation(location) { placemarks, error in
                            guard let placeMark = placemarks?.first else { return }
                            if let dictionary = placeMark.addressDictionary, let city = dictionary["City"] as? String,  town.nombreMunicipio.formatName() != city {
                                FetchTownsUseCase().execute(completion: { towns in
                                    let newTown = towns.filter { $0.nombreMunicipio.formatName() == city }
                                    self.delegate?.showChangeTownAlert(town: newTown[0])
                                })
                            }
                        }
                    }
                })
            }
            
            self.delegate?.setSelectedTown(town: town)
        }
        self.delegate?.hideLoadingIndicator()
    }
    
    func saveTown(town: Municipio) {
        SaveTownUseCase(town: town).execute()
    }
    
    func getFuels() {
        let getFuelsUseCase = FetchFuelsUseCase()
        getFuelsUseCase.execute { fuels in
            self.delegate?.setFuels(fuels: fuels)
        }
    }
    
    func logout() {
        LogOutUseCase().execute()
        self.delegate?.navigateToLogin()
    }
    
    func deleteAccount() {
        let deleteAccountUseCase = DeleteAccountUseCase(delegate: self)
        deleteAccountUseCase.execute()
    }
    
    func isUserLogged() -> Bool {
        if UserDefaults.standard.object(forKey: "User") != nil {
            return true
        }
        else {
            return false
        }
    }
}

extension FuelsViewModel: DeleteAccountUseCaseDelegate {
    func deletedAccount(error: AuthenticationError?) {
        self.logout()
    }
}
