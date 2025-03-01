enum RecorderState {
    case idle
    case recording
    case processing
    case returning
    case error(any Error)  // Update to accept 'any Error'
}
