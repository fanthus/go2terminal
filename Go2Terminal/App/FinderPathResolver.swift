import Foundation

enum FinderPathResolver {
    static let appleScriptSource = """
        tell application "Finder"
            if (count of Finder windows) > 0 then
                return POSIX path of (target of front Finder window as alias)
            else
                return POSIX path of (path to home folder)
            end if
        end tell
        """

    private static let timeoutSeconds: TimeInterval = 0.5

    static func resolve() -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        process.arguments = ["-e", appleScriptSource]

        let outputPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = Pipe()

        do {
            try process.run()
        } catch {
            NSLog("FinderPathResolver error: %@", error.localizedDescription)
            return NSHomeDirectory()
        }

        let group = DispatchGroup()
        group.enter()
        DispatchQueue.global(qos: .userInitiated).async {
            process.waitUntilExit()
            group.leave()
        }

        if group.wait(timeout: .now() + timeoutSeconds) == .timedOut {
            process.terminate()
            NSLog("FinderPathResolver timed out; falling back to home directory")
            return NSHomeDirectory()
        }

        guard process.terminationStatus == 0 else {
            NSLog("FinderPathResolver exited with status %d", process.terminationStatus)
            return NSHomeDirectory()
        }

        let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let path = String(data: data, encoding: .utf8)?
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let path, !path.isEmpty else {
            return NSHomeDirectory()
        }

        return path
    }
}
