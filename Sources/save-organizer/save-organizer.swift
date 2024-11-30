import Foundation

import SaveOrganizer

import ArgumentParser

/*
So essentially I want a command line interface to create:
 - SOGame
  - Profile
   - Save

Depending on the input given and the current environment.

Another thing to do is create a configuration for the current environment.

Example yml:

user-backup-dir: default # Would be ~/.local/share/GameSaves/(?)
default-profile: default # Could be UUID, but default would just be the first found

Though even that I am not fully sure about.
The default config file would be:
~/.config/SaveOrganizer/config.yml

*/

@main
struct SaveOrganizer: ParsableCommand {
    @Argument(help: "Save/Profile to create inside Profile/Game")
    var profile: String

    mutating func run() throws {
        let pURL = URL(fileURLWithPath: profile)
        if let u = UUID(uuidString: pURL.lastPathComponent) {
            let game = SOGame(name: pURL.parent.lastPathComponent)
            let prof = SOGameProfile(game: game, id: u)
            let save = try prof.newSave(persist: true)
            print(save.path.pathComponents[save.path.pathComponents.count-4..<save.path.pathComponents.count].joined(separator: "/"))
        } else {
            let game = SOGame(name: pURL.lastPathComponent)
            let prof = SOGameProfile(game: game)
            try prof.mkdir()
            print("Created new profile \(prof.id)")
        }
    }
}
