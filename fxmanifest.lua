fx_version 'adamant'

game 'gta5'

description 'AIMedic'

author 'Nightrider'

version '1.0.5'


client_scripts {
    '@PolyZone/client.lua',
	'@PolyZone/BoxZone.lua',
	'@PolyZone/EntityZone.lua',
	'@PolyZone/CircleZone.lua',
	'@PolyZone/ComboZone.lua',
    'client/client.lua',
    'client/mdzones.lua'
}

server_scripts {
    'server/server.lua'
}

shared_scripts {
    -- '@qb-core/import.lua',
    'config.lua'
} 

-- You do not have authorization to resell or redistribut this script 
