local function setneovide(key, value)
	local key = "neovide_" .. key
	vim.g[key] = value
end

local function init_cursor(opt)
	setneovide("cursor_animation_length", opt.animation_length)
	setneovide("cursor_trail_length", opt.trail_length)
	setneovide("cursor_antialiasing", opt.anti_alias)
end

local function init_particle(opt)
	local particle = function(key, value)
		setneovide("cursor_vfx_particle" .. key, value)
	end

	setneovide("cursor_vfx_mode", opt.mode)
	setneovide("cursor_vfx_opacity", opt.opacity)

	particle("lifetime", opt.lifetime)
	particle("density", opt.density)
	particle("speed", opt.speed)
	particle("phase", opt.phase)
	particle("curl", opt.curl)
end

local _M = {}

_M.particle = {
	railgun = "railgun",
	torpedo = "torpedo",
	pixie_dust = "pixiedust",
	sonic_boom = "sonicboom",
	ripple = "ripple",
	wireframe = "wireframe",
	none = "",
}

_M.defaults = {
	-- Cursor settings
	cursor = {
		animation_length = 0.13,
		trail_length = 0.8,
		anti_alias = true,
	},
	-- Settings for the particles emitted by the cursor
	particle = {
		mode = _M.particle.railgun,
		opacity = 200.0,
		lifetime = 1.2,
		density = 7.0,
		speed = 10.0,
		phase = 1.5,
		curl = 1.0,
	}
}

function _M.init(opt)
	local realized_opt = vim.tbl_deep_extend('keep', opt, _M.defaults)

	-- print(vim.inspect(realized_opt))

	init_cursor(realized_opt.cursor)
	init_particle(realized_opt.particle)
end

return _M
