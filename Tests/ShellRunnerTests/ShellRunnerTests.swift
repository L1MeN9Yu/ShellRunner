@testable import ShellRunner
import XCTest

final class ShellRunnerTests: XCTestCase {
    func testTask() throws {
        try "ls -la".runBash { s in
            print(s)
        }
    }

    func testNotFound() throws {
        try "CommandNotFoundTest".runBash { s in
            print(s)
        }
        print("done")
    }

    static var allTests = [
        ("testTask", testTask),
    ]
}
