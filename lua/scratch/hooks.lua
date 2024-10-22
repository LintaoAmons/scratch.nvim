local M = {}
---@enum Scratch.Trigger
M.trigger_points = {
  AFTER = 1,
  PRE_CHOICE = 2,
  POST_CHOICE = 3,
  PRE_OPEN = 4,
  POST_OPEN = 5,
}
---@alias Scratch.Hooks table<Scratch.Trigger, Scratch.Hook[]>
---TODO: specify `fun` type per hook
---@alias Scratch.Hook fun(param:table?)

-- ---@param hooks Scratch.Hook[]
-- ---@param target_trigger_point? string
-- ---@return Scratch.Hook[]
-- M.get_hooks = function(hooks, target_trigger_point)
--   local matching_hooks = {} ---@type Scratch.Hook[]
--   for i = 1, #hooks do
--     local trigger_point = hooks[i].trigger_point or M.trigger_points.AFTER
--
--     if trigger_point == target_trigger_point then
--       table.insert(matching_hooks, hooks[i])
--     end
--   end
--   return matching_hooks
-- end

return M
