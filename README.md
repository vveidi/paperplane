# 📦 Paperplane

**Paperplane** is a Swift command-line utility to send book files or folders as email attachments using your configured SMTP server. It is especially handy for sending eBooks to devices such as e-readers via email.

---

## Features
- 📎 Send files or entire folders as email attachments
- 📧 Specify sender and recipient emails
- 🗑️ Optionally remove files/folders after sending
- 📝 Verbose and debug modes
- 💾 Remembers your configuration for future runs
- 📚 Supports many file formats: **pdf, doc, docx, txt, rtf, epub, and more**

## Installation

Clone the repository and build with Swift:

```sh
git clone https://github.com/vveidi/paperplane.git
cd paperplane
swift build -c release
```

---

## Quick Start

```sh
paperplane config --init
paperplane send-book --sender you@email.com --receiver kindle@kindle.com --path /path/to/book.epub
```

---

## SMTP Configuration

Before using Paperplane, configure your SMTP server settings—this is required for sending emails.
To do this:

```sh
paperplane config --init
```

## Requirements

- Swift 6.2 or newer
- macOS 14.0 (Sonoma) or later
- Xcode 16+ (if building with Xcode)

## License

This project includes code licensed under the Apache License 2.0 (see SMTP.swift).
