return {
	"folke/which-key.nvim",
	event = "VimEnter",
	config = function()
		-- gain access to the which key plugin
		local which_key = require("which-key")

		-- call the setup function with default properties
		which_key.setup()

		-- Register prefixes for the different key mappings we have setup previously
		-- -- Mapear teclas diretamente com vim.keymap.set
		vim.keymap.set("n", "<leader>/", function()
			print("Comments")
		end, { desc = "[C]omments" })
		vim.keymap.set("n", "<leader>J", function()
			print("[J]ava")
		end, { desc = "[J]ava" })
		vim.keymap.set("n", "<leader>c", function()
			print("[C]ode")
		end, { desc = "[C]ode" })
		vim.keymap.set("n", "<leader>d", function()
			print("[D]ebug")
		end, { desc = "[D]ebug" })
		vim.keymap.set("n", "<leader>e", function()
			print("[E]xplorer")
		end, { desc = "[E]xplorer" })
		vim.keymap.set("n", "<leader>f", function()
			print("[F]ind")
		end, { desc = "[F]ind" })
		vim.keymap.set("n", "<leader>g", function()
			print("[G]it")
		end, { desc = "[G]it" })
		vim.keymap.set("n", "<leader>w", function()
			print("[W]indow")
		end, { desc = "[W]indow" })
	end,
}
