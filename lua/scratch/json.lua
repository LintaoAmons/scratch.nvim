---@param filePath string
---@return boolean
local function file_exists(filePath)
  local file = io.open(filePath, "r")
  if file then
    file:close()
    return true
  else
    return false
  end
end

---@param tbl table
---@param path string
local write_json_file = function(tbl, path)
  local content = vim.fn.json_encode(tbl) -- Encoding table to JSON string

  vim.fn.mkdir(vim.fn.fnamemodify(path, ":p:h"), "p")
  local file, err = io.open(path, "w")
  if not file then
    error("Could not open file: " .. err)
    return nil
  end

  file:write(content)
  file:close()
end

---Parse a JSON file at the given path into a table, returning the table or nil if unsuccessful.
---@param path string
---@return table?
local read_json_file = function(path)
  local file, _ = io.open(path, "r")
  if not file then
    return nil
  end

  local content = file:read("*a") -- Read the entire content
  file:close()

  return vim.fn.json_decode(content) or nil
end

return {
  file_exists = file_exists,
  write_json_file = write_json_file,
  read_json_file = read_json_file,
}
