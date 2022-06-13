local util = require 'oldwomanjosiah.util'

local M = {}

M.named = {}

function M.set(to)
	local name = to.name or to[0]
	local before = to.before or to[1]

	if name == nil then
		util.notify 'The name field is required for colorcheme.set'
		return
	end

	if before ~= nil then before() end

	vim.cmd('colorscheme ' .. name)
end

function M.all()
	return util.map(M.named, function(it) return it.name end)
end

function M:setup(opts)
	local defined_schemes = util.fn.map(
		util.rtp.find 'colors/*.vim',
		function(path)
			local colorscheme = (path:match [[%P+%.vim]]):match '[^%.]+'
			return { [colorscheme] = { name = colorscheme } }
		end
	)

	for key, value in pairs(opts or {}) do

		if not value or not value.name then
			util.notify(
				key .. ' was defined in colorscheme.setup, but did not have the name field',
				'error'
			)
		else
			defined_schemes[key] = value
		end
	end

	self.named = defined_schemes

	return self
end

return M
