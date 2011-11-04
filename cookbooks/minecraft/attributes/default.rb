default[:minecraft][:jar_location] = "https://s3.amazonaws.com/MinecraftDownload/launcher/minecraft_server.jar?"
default[:minecraft][:user] = "minecraft"
default[:minecraft][:dir]  = "/var/lib/minecraft"
default[:minecraft][:ram]  = "1024M"

# Minecraft configuration
default[:minecraft][:verify_names] = true
default[:minecraft][:port] = 25565
default[:minecraft][:max_players] = 16
default[:minecraft][:server_name] = "Minecraft Server"
default[:minecraft][:public] = true
default[:minecraft][:motd] = "Welcome to this Minecraft Server"
default[:minecraft][:max_connections] = 3
default[:minecraft][:allow_nether] = true
default[:minecraft][:level_name] = ""
default[:minecraft][:view_distance] = 10
default[:minecraft][:spawn_monsters] = true
default[:minecraft][:online_mode] = true
default[:minecraft][:spawn_animals] = true
default[:minecraft][:server_ip] = ""
default[:minecraft][:pvp] = true
default[:minecraft][:level_seed] = ""
default[:minecraft][:allow_flight] = false
default[:minecraft][:gamemode] = 0
default[:minecraft][:difficulty] = 2
