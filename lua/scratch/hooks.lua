local M = {}
---@enum Scratch.Trigger
M.trigger_points = {
  AFTER = 1,
  ON_CHOICE = 2,
}
---@alias Scratch.Hooks table<Scratch.Trigger, Scratch.Hook>
---@class Scratch.Hook
---@field callback fun(param: table?)
---@field name? string
---@field trigger_point? string

---@param hooks Scratch.Hook[]
---@param target_trigger_point? string
---@return Scratch.Hook[]
M.get_hooks = function(hooks, target_trigger_point)
  local matching_hooks = {}
  for _, hook in ipairs(hooks) do
    local matches = false
    local trigger_point = hook.trigger_point or M.trigger_points.AFTER

    if trigger_point == target_trigger_point then
      matches = true
    end

    if matches then
      table.insert(matching_hooks, hook)
    end
  end
  return matching_hooks
end

return M
