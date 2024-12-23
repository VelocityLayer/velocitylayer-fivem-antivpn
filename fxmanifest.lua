fx_version 'cerulean'
game 'gta5'

author 'VelocityLayer.com'
description 'VelocityLayer - Proxy/VPN connection checker'
version '2.0r'

lua54 'yes'

ui_page 'ui/dist/index.html'

files {
    'ui/dist/**'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}