import ArgumentParser

@main
struct Paperplane: ParsableCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            abstract: "Утилита для работы с книгами",
            subcommands: [SendBookCommand.self],
            defaultSubcommand: SendBookCommand.self
        )
    }
}
