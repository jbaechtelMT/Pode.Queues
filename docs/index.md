# Welcome!

[![MIT licensed](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/jbaechtelMT/Pode.Queues/blob/main/LICENSE)
[![GitHub Actions](https://img.shields.io/endpoint.svg?url=https%3A%2F%2Factions-badge.atrox.dev%2FjbaechtelMT%2Fpode.queues%2Fbadge&style=flat&label=GitHub)](https://actions-badge.atrox.dev/jbaechtelMT/pode.queues/goto)

[![PowerShell](https://img.shields.io/powershellgallery/dt/pode.queues.svg?label=PowerShell&colorB=085298&logo=powershell&logoColor=white)](https://www.powershellgallery.com/packages/Pode.Queues)


> 
- [📘 Documentation](#-documentation)
- [🚀 Features](#-features)
- [📦 Install](#-install)
- [🙌 Contributing](#-contributing)
- [🌎 Roadmap](#-roadmap)

<B>Pode.Queues</B> is a Cross-Platform module for creating Queues to handle inter-service (Run-spaces) Control/messaging and User messaging capibilities for use with <STRONG><A HREF="https://github.com/Badgerati/Pode">Pode</A></STRONG> & <STRONG><A HREF="https://github.com/Badgerati/Pode.Web">Pode.Web</A></STRONG> modules.  This module lends itself to "distributive" web sites and APIs where there is a "Control" site and one-or-many "Worker" nodes that are interconnected!

## 📘 Documentation

All documentation and tutorials for Pode.Queues can be [found here]([https://jbaechtelMT.github.io/Pode.Queus](https://github.com/jbaechtelMT/Pode.Queues/blob/main/)) - this documentation will be for the latest release.

To see the docs for other releases, branches or tags, you can host the documentation locally.


## 🚀 Features

<P STYLE="margin-bottom: 0in"><FONT FACE="Calibri, sans-serif">
<UL>
	<LI><B>Queues</B> (First In - First Out - FIFO): 
	<UL>
		<LI><B>Pode Registered Services</B> (Run-spaces):
		<UL>
			<LI><B>Control</B>
			<UL>
				<LI>Initialize; Terminate; Reboot; Run; Wait; Flush
			</UL>
			<LI><B>Messaging</B>
			<UL>
				<LI>Pode &lt;--&gt; Run-space
				<LI>Run-space &lt;--&gt; Run-space
				<LI>Run-space 	&lt;--&gt; User
			</UL>
			<LI><B>Pode Registered Users</B>: 
			<UL>
				<LI><B>Messaging</B>
				<UL>
					<LI>Pode &lt;--&gt; User
					<LI>Pode Broadcast --&gt; All Users 
					<LI>Run-space &lt;--&gt; User
					<LI>Run-space Broadcast --&gt; All Users
					<LI>User &lt;--&gt; User
					<LI>User Broadcast --&gt; All Users
				</UL>
			</UL>
		</UL>
	</UL>
	<LI><B>Stacks</B>(Last In - First Out - LIFO):
	<UL>
		<LI><B>Global</B> - Accessible by all Run-spaces/Pages
		<LI>&quot;<B>Personal</B>&quot; - Accessible only by the Run-space/Page that Created Them
	</UL>
</UL>
</FONT></P>

## 📦 Install

You can install Pode.Queues from the PowerShell Gallery:

# powershell gallery
Install-Module -Name Pode.Queues

## 🙌 Contributing

Pull Requests, Bug Reports and Feature Requests are welcome!

## 🌎 Roadmap

You can find a list of the features, enhancements and ideas that will hopefully one day make it into Pode [here in the documentation]([https://badgerati.github.io/Pode](https://github.com/jbaechtelMT/Pode.Queues/blob/main/)/roadmap/).

