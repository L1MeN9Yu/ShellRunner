import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    [
        testCase(ShellRunnerTests.allTests),
    ]
}
#endif
