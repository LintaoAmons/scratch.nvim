local api = require("api")
local config = require("config")
local commands = require("commands")

config.setup()
commands.init()
api.setup = config.setup

return api
