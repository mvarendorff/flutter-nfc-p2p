class HceHostApiImpl: HceHostApi {
    private var message: String?
    private var isConnected: Bool = false
    private var hasSent: Bool = false


    func exposeMessage(message: String, completion: @escaping (Result<Void, Error>) -> Void) {
        .message = message

        completion(.success())
    }
}
