local M = {}

M.scratchByType = require("scratch.scratch_file").createScratchFileByType
M.scratchByName = require("scratch.scratch_file").createScratchFileByName
M.scratchPad = require("scratch.scratch_file").scratchPad
M.scratchOpen = require("scratch.scratch_file").openScratch
M.scratchFzf = require("scratch.scratch_file").fzfScratch
M.checkConfig = require("scratch.config").checkConfig
M.editConfig = require("scratch.config").editConfig

return M
