//
// Created by Mengyu Li on 2020/9/28.
//

#if os(Linux)
import Glibc
#else
import Darwin.C
#endif

public typealias OutputClosure = (String) -> Void

public final class Task {
    public let arguments: [String]

    public private(set) var pid: pid_t = 0

    /// The TID of the thread which will read streams.
    #if os(Linux)
    private(set) var tid = pthread_t()
    private var childFDActions = posix_spawn_file_actions_t()
    #else
    private(set) var tid: pthread_t?
    private var childFDActions: posix_spawn_file_actions_t?
    #endif

    private let process = ["/bin/sh", "-c"]
    private var outputPipe: [Int32] = [-1, -1]

    private var threadInfo: ThreadInfo?

    public init(command: String) {
        arguments = process + [command]
    }
}

public extension Task {
    func run(sync: Bool = true, output: OutputClosure? = nil) throws {
        if pipe(&outputPipe) < 0 { throw Error.CouldNotOpenPipe }

        if let currentThreadInfo = threadInfo { if currentThreadInfo.isRunning { throw Error.IsRunning } }

        threadInfo = ThreadInfo(outputPipe: &outputPipe, output: output, isRunning: true)

        posix_spawn_file_actions_init(&childFDActions)
        posix_spawn_file_actions_adddup2(&childFDActions, outputPipe[1], 1)
        posix_spawn_file_actions_adddup2(&childFDActions, outputPipe[1], 2)
        posix_spawn_file_actions_addclose(&childFDActions, outputPipe[0])
        posix_spawn_file_actions_addclose(&childFDActions, outputPipe[1])

        let argv: [UnsafeMutablePointer<CChar>?] = arguments.map { $0.withCString(strdup) }
        defer { for case let arg? in argv { free(arg) } }

        if posix_spawn(&pid, argv[0], &childFDActions, nil, argv + [nil], nil) < 0 { throw Error.CouldNotSpawn }

        func callback(x: UnsafeMutableRawPointer) -> UnsafeMutableRawPointer? {
            let threadInfo = x.assumingMemoryBound(to: ThreadInfo.self).pointee
            let outputPipe = threadInfo.outputPipe
            close(outputPipe[1])
            let bufferSize: size_t = 1024 * 8
            let dynamicBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
            while true {
                let amtRead = read(outputPipe[0], dynamicBuffer, bufferSize)
                if amtRead <= 0 { break }
                let array = Array(UnsafeBufferPointer(start: dynamicBuffer, count: amtRead))
                let tmp = array + [UInt8(0)]
                tmp.withUnsafeBufferPointer { ptr in
                    let str = String(cString: unsafeBitCast(ptr.baseAddress, to: UnsafePointer<CChar>.self))
                    threadInfo.output?(str)
                }
            }
            dynamicBuffer.deallocate()
            threadInfo.isRunning = false
            close(outputPipe[0])
            return nil
        }

        pthread_create(&tid, nil, callback, &threadInfo)

        if sync {
            var status: Int32 = 0

            if let tid = tid { pthread_join(tid, nil) }

            waitpid(pid, &status, 0)
        }
    }
}

public extension Task {
    static func run(command: String, output: OutputClosure? = nil) throws {
        try Task(command: command).run(output: output)
    }
}
