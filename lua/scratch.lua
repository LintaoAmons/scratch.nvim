local api = require("api")
local config = require("config")
local commands = require("commands")

commands.init()

config.setup()
api.setup = config.setup

return api
