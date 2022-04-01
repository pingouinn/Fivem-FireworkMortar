fx_version 'bodacious'
game 'gta5'

author 'Pingouin'
description 'Script Firework mortar'
version '1.0.3'

lua54 'yes'

escrow_ignore {
    'config.lua',
}

-- Client

client_scripts { 
    'client.lua',
    'config.lua',
}

-- Server

server_script "server.lua"