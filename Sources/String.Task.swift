//
// Created by Mengyu Li on 2020/9/28.
//

public extension String {
    func runBash(output: OutputClosure? = nil) throws {
        try Task.run(command: self, output: output)
    }
}
