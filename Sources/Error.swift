//
// Created by Mengyu Li on 2020/9/28.
//

public extension Task {
    enum Error: Swift.Error {
        case CouldNotOpenPipe
        case CouldNotSpawn
        case IsRunning
    }
}
