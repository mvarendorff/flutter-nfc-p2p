import CoreNFC

class HceHostApiImpl: HceHostApi {
    private func getMessageApdu(message: String) -> Data {
        let messageBytes = message.data(using: .utf8)
        let successBytes = Data(0x90, 0x00)
                
        return messageBytes + successBytes
    }
    
    func exposeMessage(message: String, completion: @escaping (Result<Void, Error>) -> Void) {
        var hasSent: Bool
        
        let ProcessApdu: (_: Data) -> Data = {
            capdu in return getMessageApdu(message: message)
        }
        
        Task() {
            guard NFCReaderSession.readingAvailable,
                  CardSession.isSupported,
                  await CardSession.isEligible else {
                completion(.failure(PigeonError(code: "NOT_AVAILABLE", message: "CardSession is not available, supported or the device is not eligible.")))
                return
            }
            
            // TODO monitor this
            var presentmentIntent: NFCPresentmentIntentAssertion?
            let cardSession: CardSession;
            
            do {
                presentmentIntent = try await NFCPresentmentIntentAssertion.acquire()
                cardSession = try await CardSession()
            } catch {
                completion(.failure(PigeonError(code: "STARTUP_FAIL", message: "Failed to acquire presentmentIntent or CardSession")))
                return
            }
            
            for try await event in cardSession.eventStream {
                switch event {
                case .sessionStarted:
                    cardSession.alertMessage = "Card emulation in progress"
                    break;
                case .readerDetected:
                    try await cardSession.startEmulation()
                    break
                case .readerDeselected:
                    try await cardSession.stopEmulation(status: .success)
                    break
                case .received(let cardApdu):
                    do {
                        let responseApdu = ProcessApdu(cardApdu.payload)
                        try await cardApdu.respond(response: responseApdu)
                        hasSent = true
                    } catch {
                        // TODO handle Transmission error to try again
                        completion(.failure(error))
                    }
                    break
                case .sessionInvalidated(reason: _):
                    cardSession.alertMessage = "Card emulation ending"
                    break
                }
            }
            
            if (!hasSent) {
                completion(.failure(PigeonError(code: "DID_NOT_SEND", message: "For some reason, no event caused sending a response :(")))
            }
            
            presentmentIntent = nil
        }
    }
}
