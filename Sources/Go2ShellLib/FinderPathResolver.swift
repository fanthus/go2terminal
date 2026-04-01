import Foundation

public enum FinderPathResolver {
    static let appleScriptSource = """
        tell application "Finder"
            if (count of Finder windows) > 0 then
                return POSIX path of (target of front Finder window as alias)
            else
                return POSIX path of (path to home folder)
            end if
        end tell
        """

    public static func resolve() -> String {
        let script = NSAppleScript(source: appleScriptSource)
        var error: NSDictionary?
        let result = script?.executeAndReturnError(&error)

        if let error = error {
            NSLog("FinderPathResolver error: %@", error)
            return NSHomeDirectory()
        }

        return result?.stringValue ?? NSHomeDirectory()
    }
}
