-- FIXME: Delete this file when merge to main branch

-- Helper function to check if a table is array-like
local function is_array_like(tbl)
	local i = 1
	for _ in pairs(tbl) do
		if not tbl[i] then
			return false
		end
		i = i + 1
	end
	return true
end

-- Function to merge two array-like tables
local function merge_array_like_tables(tbl1, tbl2)
	local merged = {}
	local seen = {}

	-- Add elements from tbl1
	for _, v in ipairs(tbl1) do
		merged[#merged + 1] = v
		seen[v] = true
	end

	-- Add elements from tbl2 that are not already in merged
	for _, v in ipairs(tbl2) do
		if not seen[v] then
			merged[#merged + 1] = v
			seen[v] = true
		end
	end

	return merged
end

---Merge two table
---if the field type is string or number or other primary type, use value in tbl1
---if the field type is array like table, merge and unique the elements,
---if the field type is table, recursively call mergeTables function
---@param tbl1 table
---@param tbl2 table
---@return table
local function merge_tables(tbl1, tbl2)
	local result = {}
	for key, value in pairs(tbl1) do
		vim.print("==============")
		vim.print(key)
		vim.print(value)
		if type(value) == "string" or type(value) == "number" or type(value) == "boolean" then
			vim.print("branch1")
			result[key] = value
		elseif type(value) == "table" and is_array_like(value) then -- Added check for array-like
			vim.print("branch3")
			vim.print(value)
			if tbl2[key] and type(tbl2[key]) == "table" and is_array_like(tbl2[key]) then -- Check if tbl2[key] is also array-like
				result[key] = merge_array_like_tables(value, tbl2[key])
			else
				result[key] = value
			end
		elseif type(value) == "table" then
			vim.print("branch2")
			if tbl2[key] and type(tbl2[key]) == "table" then
				result[key] = merge_tables(value, tbl2[key])
			else
				result[key] = value
			end
		end
	end
	for key, value in pairs(tbl2) do
		if not result[key] then
			result[key] = value
		end
	end
	return result
end

-- Define a simple function to compare two tables
local function tablesEqual(tbl1, tbl2)
	if not (#tbl1 == #tbl2) then
		return false
	end
	for k, v in pairs(tbl1) do
		if type(v) == "table" then
			if (not type(tbl2[k]) == "table") or not (#v == #tbl2[k]) or (not tablesEqual(v, tbl2[k])) then
				return false
			end
		elseif v ~= tbl2[k] then
			return false
		end
	end
	return true
end

-- Unit test for mergeTables function
local function testMergeTables()
	local tbl1 = {
		name = "John",
		age = 30,
		hobbies = { "reading", "swimming" },
		details = {
			city = "New York",
			country = "USA",
		},
	}

	local tbl2 = {
		age = 31,
		hobbies = { "running", "swimming" },
		details = {
			city = "San Francisco",
			state = "California",
		},
	}

	local expected = {
		name = "John",
		age = 30,
		hobbies = { "reading", "swimming", "running" },
		details = {
			city = "New York",
			country = "USA",
			state = "California",
		},
	}

	local result = merge_tables(tbl1, tbl2)

	vim.print(result)
	if tablesEqual(result, expected) then
		print("Unit test passed!")
	else
		print("Unit test failed!")
	end
end

testMergeTables()
