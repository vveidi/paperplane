import ArgumentParser

@main
struct Paperplane: ParsableCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "send-book",
            abstract: "Sends a book file or folder as an email attachment.",
            discussion: """
                Usage example:
                  paperplane send-book --sender you@email.com --receiver kindle@kindle.com --path /path/to/book.mobi

                Parameters:
                  --sender       Email address of the sender.
                  --receiver     Email address of the recipient.
                  --path         Path to the book file or folder.
                  --remove-after-send  Remove file or folder after sending.

                Supported formats: mobi, azw, azw3, epub, pdf, and more.
                """
        )
    }
}
