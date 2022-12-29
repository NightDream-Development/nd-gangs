fx_version 'cerulean'
game 'gta5'

version '2.9.6'

author 'Mojito-Fivem & NDD'

client_scripts {
	'@PolyZone/client.lua',
	'@PolyZone/CircleZone.lua',
	'client/main.lua',
	'client/gui.lua',
	'client/creation.lua',
	'client/territories.lua'
}

server_scripts {
	'server/leaders.lua',
	'server/main.lua',
	'server/territories.lua',
	'version.lua'
}

shared_scripts { "shared/*.lua" }

files {
	'*.json',

	'html/img/*.png',
	'html/sounds/*.wav',
	
	'html/index.html',
	'html/js/*.js',
	'html/css/*.css'
} 

ui_page 'html/index.html'
server_scripts { '@mysql-async/lib/MySQL.lua' }
