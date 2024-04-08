fx_version 'adamant'
shared_script '@es_extended/imports.lua'
game 'gta5'

author 'Bibiflox'
version '1.0'
description 'véhiculeControl de BibiFlox'



server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'serveur/server.lua'

}

client_script 'client/client.lua'

files {
    'Update.lua',
    'versions.json'
}