local M = {}

M.scratchByType = require("scratch.api").createScratchFileByType
M.scratchByName = require("scratch.api").createScratchFileByName
M.scratchOpen = require("scratch.api").openScratch
M.scratchFzf = require("scratch.api").fzfScratch
M.setup = require("scratch.config").setup

return M
