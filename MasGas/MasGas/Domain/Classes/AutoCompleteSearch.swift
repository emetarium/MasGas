//
//  AutoCompleteSearch.swift
//  MasGas
//
//  Created by María García Torres on 24/9/24.
//

import Foundation
import MapKit

class AutoCompleteSearch: NSObject, MKLocalSearchCompleterDelegate {
    private var searchCompleter: MKLocalSearchCompleter
    var results: [MKLocalSearchCompletion] = []
    var updateHandler: (() -> Void)?

    override init() {
        searchCompleter = MKLocalSearchCompleter()
        super.init()
        searchCompleter.delegate = self
    }

    func updateQuery(_ query: String) {
        searchCompleter.queryFragment = query
    }

    // Delegate method called when the results are updated
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        results = completer.results
        updateHandler?()
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Error during search completion: \(error.localizedDescription)")
    }
}
