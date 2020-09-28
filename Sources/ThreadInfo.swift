//
// Created by Mengyu Li on 2020/9/28.
//

import Foundation

class ThreadInfo {
    let outputPipe: UnsafeMutablePointer<Int32>
    let output: OutputClosure?
    var isRunning: Bool

    init(outputPipe: UnsafeMutablePointer<Int32>, output: OutputClosure?, isRunning: Bool = false) {
        self.outputPipe = outputPipe
        self.output = output
        self.isRunning = isRunning
    }
}
