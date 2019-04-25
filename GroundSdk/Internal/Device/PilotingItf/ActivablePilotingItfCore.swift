// Copyright (C) 2016-2017 Parrot Drones SAS
//
//    Redistribution and use in source and binary forms, with or without
//    modification, are permitted provided that the following conditions
//    are met:
//    * Redistributions of source code must retain the above copyright
//      notice, this list of conditions and the following disclaimer.
//    * Redistributions in binary form must reproduce the above copyright
//      notice, this list of conditions and the following disclaimer in
//      the documentation and/or other materials provided with the
//      distribution.
//    * Neither the name of the Parrot Company nor the names
//      of its contributors may be used to endorse or promote products
//      derived from this software without specific prior written
//      permission.
//
//    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
//    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
//    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
//    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
//    PARROT COMPANY BE LIABLE FOR ANY DIRECT, INDIRECT,
//    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
//    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
//    OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED
//    AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
//    OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
//    OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
//    SUCH DAMAGE.

import Foundation

/// Piloting interface backend common part.
/// All activable piloting interfaces must be subprotocol of this protocol
public protocol ActivablePilotingItfBackend: class {
    /// Deactivate this piloting interface
    /// - returns: false if it can't be deactivated
    func deactivate() -> Bool
}

/// Core implementation of a PilotingItf
public class ActivablePilotingItfCore: ComponentCore, PilotingItf, ActivablePilotingItf {
    /// Piloting interface state. There is only one piloting interface active at a time on a drone.
    public private(set) var state = ActivablePilotingItfState.unavailable

    /// implementation backend
    unowned let backend: ActivablePilotingItfBackend

    /// Constructor
    /// - parameter desc: piloting interface component descriptor
    /// - parameter store: store where this interface will be stored
    /// - parameter backend: activation backend
    init(desc: ComponentDescriptor, store: ComponentStoreCore, backend: ActivablePilotingItfBackend) {
        self.backend = backend
        super.init(desc: desc, store: store)
    }

    /// Reset state
    /// Subclass can override this function to reset other values
    override func reset() {
        super.reset()
        state = .unavailable
    }

    /// Deactivate this piloting interface
    /// - returns: false if it can't be deactivated
    public func deactivate() -> Bool {
        if state == .active {
            return backend.deactivate()
        }
        return false
    }
}

/// Backend callback methods
extension ActivablePilotingItfCore {

    /// Changes the activation state
    ///
    /// - parameter activeState: new piloting interface state
    /// - returns: self to allow call chaining
    /// - note: changes are not notified until notifyUpdated() is called
    @discardableResult public func update(activeState newState: ActivablePilotingItfState) -> ActivablePilotingItfCore {
        if state != newState {
            state = newState
            markChanged()
        }
        return self
    }
}
