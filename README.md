# Pode.Queues

Compainion module for use with Pode & Pode.Web projects.

<p align="center">
    <img src="https://github.com/Badgerati/Pode/raw/develop/images/icon-new.svg?raw=true" width="250" />
</p>

[![MIT licensed](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/Badgerati/Pode/master/LICENSE.txt)
[![Documentation](https://img.shields.io/github/v/release/badgerati/pode?label=docs&logo=readthedocs&logoColor=white)](https://badgerati.github.io/Pode)
[![GitHub Actions](https://img.shields.io/endpoint.svg?url=https%3A%2F%2Factions-badge.atrox.dev%2Fbadgerati%2Fpode%2Fbadge&style=flat&label=GitHub)](https://actions-badge.atrox.dev/badgerati/pode/goto)

[![PowerShell](https://img.shields.io/powershellgallery/dt/pode.svg?label=PowerShell&colorB=085298&logo=powershell&logoColor=white)](https://www.powershellgallery.com/packages/Pode)


> 💝 A lot of my free time, evenings, and weekends goes into making Pode happen; please do consider sponsoring as it will really help! 😊

- [📘 Documentation](#-documentation)
- [🚀 Features](#-features)
- [📦 Install](#-install)
- [🙌 Contributing](#-contributing)
- [🌎 Roadmap](#-roadmap)

Pode is a Cross-Platform framework for creating web servers to host [REST APIs](https://badgerati.github.io/Pode/Tutorials/Routes/Overview/), [Web Pages](https://badgerati.github.io/Pode/Tutorials/Routes/Examples/WebPages/), and [SMTP/TCP](https://badgerati.github.io/Pode/Servers/) Servers. Pode also allows you to render dynamic files using [`.pode`](https://badgerati.github.io/Pode/Tutorials/Views/Pode/) files, which are just embedded PowerShell, or other [Third-Party](https://badgerati.github.io/Pode/Tutorials/Views/ThirdParty/) template engines. Plus many more features, including [Azure Functions](https://badgerati.github.io/Pode/Hosting/AzureFunctions/) and [AWS Lambda](https://badgerati.github.io/Pode/Hosting/AwsLambda/) support!

<p align="center">
    <img src="https://github.com/Badgerati/Pode/blob/develop/images/example_code_readme.svg?raw=true" width="70%" />
</p>

See [here](https://badgerati.github.io/Pode/Getting-Started/FirstApp) for building your first app! Don't know HTML, CSS, or JavaScript? No problem! [Pode.Web](https://github.com/Badgerati/Pode.Web) is currently a work in progress, and lets you build web pages using purely PowerShell!

## 📘 Documentation

All documentation and tutorials for Pode can be [found here](https://badgerati.github.io/Pode) - this documentation will be for the latest release.

To see the docs for other releases, branches or tags, you can host the documentation locally. To do so you'll need to have the [`InvokeBuild`](https://github.com/nightroman/Invoke-Build) module installed; then:


## 🚀 Features

Queues (First In - First Out - FIFO):
Pode Registered Services (Runspaces):
Control
Initialize; Terminate; Reboot; Run; Wait; Flush
Messaging
Pode <--> Runspace
Runspace <--> Runspace
Runspace <--> User
Pode Registered Users:
Messaging
Pode <--> User
Pode Broadcast --> All Users
Runspace <--> User
User <--> User
Stacks (Last In - First Out - LIFO):
Global - Accessable by all Runspaces/Pages
"Personal" - Accessable only by the Runspace/Page that Created Them

## 📦 Install

You can install Pode.Queues from the PowerShell Gallery:

```powershell
# powershell gallery
Install-Module -Name Pode.Queues

## 🙌 Contributing

> The full contributing guide can be [found here](https://github.com/Badgerati/Pode/blob/develop/.github/CONTRIBUTING.md)

Pull Requests, Bug Reports and Feature Requests are welcome! Feel free to help out with Issues and Projects!


To work on issues you can fork Pode, and then open a Pull Request for approval. Pull Requests should be made against the `develop` branch. Each Pull Request should also have an appropriate issue created.

## 🌎 Roadmap

You can find a list of the features, enhancements and ideas that will hopefully one day make it into Pode [here in the documentation](https://badgerati.github.io/Pode/roadmap/).

There is also a [Project Board](https://github.com/users/Badgerati/projects/2) in the beginnings of being setup for Pode, with milestone progression and current roadmap issues and ideas. If you see any draft issues you wish to discuss, or have an idea for one, please dicuss it over on [Discord](https://discord.gg/fRqeGcbF6h) in the `#ideas` or `#pode` channel.
