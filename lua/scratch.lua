local api = require("api")
local config = require("config")
local commands = require("commands")

commands.init()

config.setup()

return api
