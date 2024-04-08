fx_version 'adamant'
shared_script '@es_extended/imports.lua'
game 'gta5'

author 'Bibiflox'
version '1.0'
description 'Script pour voiture de BibiFlox'



server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'server.lua'

}

client_script 'client.lua'
