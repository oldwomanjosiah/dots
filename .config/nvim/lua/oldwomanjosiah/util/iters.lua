local M = {}

--- Iterable interface
local Iterable = {}

--- Get the next item from the iterator, if there is one
--- @return any|nil
function Iterable:next() end

--- @param fn function: Maps each individual item in the list into a single
--- output
--- @return Iterable
function Iterable:map(fn) end

--- @param fn function: Filter each item, must return a truthy value
--- @return Iterable
function Iterable:filter(fn) end

--- @return Iterable
function Iterable:filter_nils() end

function Iterable:collect()
	local out = {}

	while true do
		local new = self:next()

		if new == nil then
			return out
		else
			table.insert(out, new)
		end
	end
end

--- Root iterable over table fields
---
--- @class Iterable
local TableIterable = {}
local MappedIterable = {}

setmetatable(TableIterable, { __index = Iterable })
setmetatable(MappedIterable, { __index = Iterable })

local function make_mapped(iter, first_fn)
	local new = {
		inner = iter,
		maps = { first_fn },
	}

	setmetatable(new, { __index = MappedIterable })

	return new
end

local function make_iterable(tbl)
	local new = {
		src_tbl = tbl,
		next_idx = 1,
		size = table.getn(tbl),
		done = false,
	}

	setmetatable(new, { __index = TableIterable })

	return new
end

function TableIterable:next()
	if self.done == true then return nil end

	local it = self.src_tbl[self.next_idx]

	if it == nil then
		self.done = true
		self.src_table = nil
	end

	self.next_idx = self.next_idx + 1

	return it
end

function TableIterable:map(fn)
	return make_mapped(self, fn)
end

function MappedIterable:map(fn)
	table.insert(self.maps, fn)
	return self
end

function MappedIterable:next()
	local new = self.inner:next()

	if new == nil then return nil end

	for _, fn in ipairs(self.maps) do
		new = fn(new)
	end

	return new
end


--- Create a new iterable from a table's positional fields
---
--- @param tbl table: input table
--- @return Iterable
function M.iter_from(tbl)
	return make_iterable(tbl)
end

return M
