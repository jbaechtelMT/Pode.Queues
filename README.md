# Pode.Queues

<P><FONT FACE="Calibri, sans-serif"><FONT SIZE=4>I wrote </FONT></FONT><STRONG><FONT COLOR="#0066cc"><FONT FACE="Calibri, sans-serif"><FONT SIZE=4><B>Pode.Queues</B></FONT></FONT></FONT></STRONG><FONT FACE="Calibri, sans-serif"><FONT SIZE=4>
to be a </FONT></FONT><FONT FACE="Calibri, sans-serif"><FONT SIZE=4><SPAN STYLE="font-style: normal">companion</SPAN></FONT></FONT><FONT FACE="Calibri, sans-serif"><FONT SIZE=4>
module for use with </FONT></FONT><STRONG><A HREF="https://github.com/Badgerati/Pode"><FONT FACE="Calibri, sans-serif"><FONT SIZE=4>Pode</FONT></FONT></A></STRONG><FONT FACE="Calibri, sans-serif"><FONT SIZE=4>
&amp; </FONT></FONT><STRONG><A HREF="https://github.com/Badgerati/Pode.Web"><FONT FACE="Calibri, sans-serif"><FONT SIZE=4>Pode.Web</FONT></FONT></A></STRONG><FONT FACE="Calibri, sans-serif"><FONT SIZE=4>
projects.  For those of you that don't know about these projects, I
have found them to be the best </FONT></FONT><FONT COLOR="#0066cc"><FONT FACE="Calibri, sans-serif"><FONT SIZE=4><B>PowerShell
</B></FONT></FONT></FONT><FONT FACE="Calibri, sans-serif"><FONT SIZE=4>based
</FONT></FONT><FONT COLOR="#0066cc"><FONT FACE="Calibri, sans-serif"><FONT SIZE=4><B>web
server</B></FONT></FONT></FONT><FONT FACE="Calibri, sans-serif"><FONT SIZE=4>
and </FONT></FONT><FONT COLOR="#0066cc"><FONT FACE="Calibri, sans-serif"><FONT SIZE=4><B>API
delivery platform</B></FONT></FONT></FONT><FONT FACE="Calibri, sans-serif"><FONT SIZE=4>
to date.  You should really take a look!</FONT></FONT></P>
<P><FONT FACE="Calibri, sans-serif"><FONT COLOR="#0066cc"><FONT SIZE=4><B>Pode.Queues</B></FONT></FONT><FONT SIZE=4><B>
</B></FONT><FONT SIZE=4>doesn't require that you use it with </FONT><FONT COLOR="#0066cc"><FONT SIZE=4><B>Pode</B></FONT></FONT><FONT SIZE=4>.
 It contains code to detect if it is running under </FONT><FONT COLOR="#0066cc"><FONT SIZE=4><B>Pode</B></FONT></FONT><FONT SIZE=4>
or not which it allows it to be used stand-alone with PowerShell
run-spaces and you can still enjoy all of it's features.  But where
it really shines is operating under the </FONT><FONT COLOR="#0066cc"><FONT SIZE=4><B>Pode</B></FONT></FONT><FONT SIZE=4>
framework.</FONT></FONT></P>
<P><FONT FACE="Calibri, sans-serif"><FONT SIZE=4>This module was born
out of two needs: the <FONT COLOR="#0066cc"><B>need to have a
communication and control structure between multiple PowerShell
run-spaces</B></FONT>; and the <FONT COLOR="#0066cc"><B>need for User
to User communications</B></FONT> mechanisms.</FONT></FONT></P>
<P><FONT FACE="Calibri, sans-serif"><FONT SIZE=4>I try to write my
scripts/APIs to be utilitarian where one script/page can call on
another script/API to perform needed functions.  You may ask, &quot;<I>If
it is an API, couldn't you just issue a REST API call to the API?</I>&quot;
 The short answer is: Yes.  But why not do those API calls in memory
instead of passing it through the NIC?  Not to mention, how would you
handle <FONT COLOR="#0066cc"><B>run-space Control commands</B></FONT>
to the APIs as &quot;<FONT COLOR="#0066cc"><B>Interrupts</B></FONT>&quot;
or &quot;<FONT COLOR="#0066cc"><B>Events</B></FONT>&quot;?  This
module provides those abilities.  Also, what about wanting your
site's users to have the ability to communicate between themselves,
or having the ability for the site itself to be able to <FONT COLOR="#0066cc"><B>message
a single user</B></FONT> or <FONT COLOR="#0066cc"><B>broadcast a
message to all users</B></FONT>.  Say something like the site
notifying all users that it is about to restart itself so that the
users have warning enough to save their work?  <FONT COLOR="#0066cc"><B>Now
you can</B></FONT>!</FONT></FONT></P>
<P STYLE="margin-bottom: 0in"><BR>
</P>

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

<ul>
    <li>Queues (First In - First Out - FIFO):</li>
    <ul>
        <li>Pode Registered Services (Runspaces):</li>
        <ul>
            <li>Control</li>
            <ul>
                <li>Initialize; Terminate; Reboot; Run; Wait; Flush</li>
            </ul>
            <li>Messaging</li>
            <ul>
                <li>Pode <--> Runspace</li>
                <li>Runspace <--> Runspace</li>
                <li>Runspace <--> User</li>
            </ul>
            <li>Pode Registered Users:</li>
            <ul>
                <li>Messaging</li>
                <ul>
                    <li>Pode <--> User</li>
                    <li>Pode Broadcast --> All Users</li>
                    <li>Runspace <--> User</li>
                    <li>User <--> User</li>
                </ul>
             </ul>
        </ul>
    </ul>
    <li>Stacks (Last In - First Out - LIFO):</li>
    <ul>
        <li>Global - Accessable by all Runspaces/Pages</li>
        <li>"Personal" - Accessable only by the Runspace/Page that Created Them</li>
    </ul>
</ul>

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
