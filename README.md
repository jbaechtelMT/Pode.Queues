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
or not which allows it to be used stand-alone with PowerShell
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
 The short answer is: Yes.</P>
<P>But why not do those API calls in memory
instead of passing it through the NIC?  Not to mention, how would you
handle <FONT COLOR="#0066cc"><B>run-space Control commands</B></FONT>
to the APIs as &quot;<FONT COLOR="#0066cc"><B>Interrupts</B></FONT>&quot;
or &quot;<FONT COLOR="#0066cc"><B>Events</B></FONT>&quot;?  This
module provides those abilities.</P>
<P>Also, what about wanting your
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
    <img src="https://github.com/jbaechtelMT/Pode.Queues/blob/main/queues.png?raw=true" width="250" />
</p>

[![MIT licensed](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/Badgerati/Pode/master/LICENSE.txt)
[![Documentation](https://img.shields.io/github/v/release/badgerati/pode?label=docs&logo=readthedocs&logoColor=white)](https://badgerati.github.io/Pode)
[![GitHub Actions](https://img.shields.io/endpoint.svg?url=https%3A%2F%2Factions-badge.atrox.dev%2Fbadgerati%2Fpode%2Fbadge&style=flat&label=GitHub)](https://actions-badge.atrox.dev/badgerati/pode/goto)

[![PowerShell](https://img.shields.io/powershellgallery/dt/pode.svg?label=PowerShell&colorB=085298&logo=powershell&logoColor=white)](https://www.powershellgallery.com/packages/Pode.Queues)


> 
- [📘 Documentation](#-documentation)
- [🚀 Features](#-features)
- [📦 Install](#-install)
- [🙌 Contributing](#-contributing)
- [🌎 Roadmap](#-roadmap)

<B>Pode.Queues</B> is a Cross-Platform module for creating Queues to handle inter-service (Run-spaces) Control/messaging and User messaging capibilities for use with <STRONG><A HREF="https://github.com/Badgerati/Pode.Web"><FONT FACE="Calibri, sans-serif"><FONT SIZE=4>Pode.Web</FONT></FONT></A></STRONG><FONT FACE="Calibri, sans-serif"><FONT SIZE=4> modules.  This module lends itself to "distributive" web sites and APIs where there is a "Control" site and one-or-many "Worker" nodes that are interconnected!

## 📘 Documentation

All documentation and tutorials for Pode can be [found here]([https://badgerati.github.io/Pode](https://github.com/jbaechtelMT/Pode.Queues/blob/main/)) - this documentation will be for the latest release.

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

```powershell
# powershell gallery
Install-Module -Name Pode.Queues

## 🙌 Contributing

```powershell
Pull Requests, Bug Reports and Feature Requests are welcome!

## 🌎 Roadmap

You can find a list of the features, enhancements and ideas that will hopefully one day make it into Pode [here in the documentation]([https://badgerati.github.io/Pode](https://github.com/jbaechtelMT/Pode.Queues/blob/main/)/roadmap/).

