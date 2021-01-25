--[[
_________ _______________  ___ ________                       
\_   ___ \\_   _____/\   \/  / \______ \   _______  __________
/    \  \/ |    __)   \     /   |    |  \_/ __ \  \/ /\___   /
\     \____|     \    /     \   |    `   \  ___/\   /  /    / 
 \______  /\___  /   /___/\  \ /_______  /\___  >\_/  /_____ \
        \/     \/          \_/         \/     \/            \/
    Discord: Aizen#9186
    CFX Devz: https://discord.gg/dMMmr82S23
    KK: https://discord.gg/MT2996y
    Antichix: https://discord.gg/NmFcvCs
]]

fx_version 'adamant'
game 'gta5'

server_scripts {
	'@es_extended/locale.lua',
	'@mysql-async/lib/MySQL.lua',
	'locales/*.lua',
	'config/*.lua',
	'server/*.lua'
}

client_scripts {
	'@es_extended/locale.lua',
	'locales/*.lua',
	'config/*.lua',
	'client/*.lua'
}

dependencies {
	'es_extended',
	'mythic_notify'
}

exports {
	"GetStashType"
}