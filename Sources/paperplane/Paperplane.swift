import ArgumentParser

@main
struct Paperplane: ParsableCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "paperplane",
            abstract: "Sends a book file or folder as an email attachment.",
            discussion: """
                Usage example:
                  paperplane send-book --sender you@email.com --receiver kindle@kindle.com --path /path/to/book.mobi

                Parameters:
                  --sender              Email address of the sender.
                  --receiver            Email address of the recipient.
                  --path                Path to the book file or folder.
                  --remove-after-send   Remove file or folder after sending.
                  --verbose             Verbose mode.
                  --debug               Debug mode. Emails will not be send to real adresses.

                Supported formats: pdf, doc, docx, txt, rtf, epub and more.
                """,
            subcommands: [SendBookCommand.self, InitSecretsCommand.self],
            defaultSubcommand: SendBookCommand.self
        )
    }
}
