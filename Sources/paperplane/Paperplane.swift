import ArgumentParser

@main
struct Paperplane: ParsableCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            abstract: "Утилита для работы с книгами",
            subcommands: [SendBook.self],
            defaultSubcommand: SendBook.self
        )
    }
}
