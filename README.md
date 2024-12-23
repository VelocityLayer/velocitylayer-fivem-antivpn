<h1 align="center">
  <br>
  <img src="https://cdn.networklayer.net/velocitylayer/blogo-light.png" width="400">
  <br>
  VelocityLayer - Proxy/VPN detection plugin for FiveM
  <br>
</h1>

<h4 align="center">Plugin for FiveM to prevent usage of anonymizing services </h4>

[![proxycheck](https://i.imgur.com/6EqYmkL.png)](https://proxycheck.io)
![kick](https://i.imgur.com/3Aknhk7.png)
![gameui](https://i.imgur.com/KPmSn9D.png)

## Key Features

* Simple & Lightweight
* Silent Anti-VPN disabling (Allow proxy connections to join, but log them)
* Proxy/VPN detection via Proxycheck.io API
* Internal caching to prevent unnecessary queries
* Highly customizable
* In-game UI for management
* Free and open-source

## To do

* Country blacklisting
* Discord notifications
* Silent Anti-VPN fail (When user attempts to bypass anti-vpn multiple times from 3 different VPN IPs, he will be silently failed and presented with kick message)
* Whitelist module
* Logs (when player attempts to join with a VPN/Proxy connection, it displays the attempt in the game UI)

## How To Use

Download the latest release of the plugin, extract the archive in resources folder, in "CFG editor" or server.cfg file
Add `ensure velocitylayer-antivpn` and restart the server or execute `ensure velocitylayer-antivpn` in console. That's it.

## Download

You can [download](https://github.com/MeowKatinas/velocitylayer-fivem-antivpn/releases/tag/latest) the latest version of VelocityLayer AntiVPN for FiveM.
