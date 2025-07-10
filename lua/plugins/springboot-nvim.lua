return {
    "elmcgill/springboot-nvim",
    dependencies = {
        "neovim/nvim-lspconfig",
        "mfussenegger/nvim-jdtls"
    },
    ft = "java", -- Carregar apenas para arquivos Java
    config = function()
        -- Verificar se estamos em um projeto Spring Boot
        local function is_spring_boot_project()
            local cwd = vim.fn.getcwd()
            local pom_xml = vim.fn.filereadable(cwd .. "/pom.xml") == 1
            local build_gradle = vim.fn.filereadable(cwd .. "/build.gradle") == 1
            local build_gradle_kts = vim.fn.filereadable(cwd .. "/build.gradle.kts") == 1
            
            if pom_xml then
                -- Verificar se o pom.xml contém dependências do Spring Boot
                local pom_content = vim.fn.readfile(cwd .. "/pom.xml")
                for _, line in ipairs(pom_content) do
                    if string.match(line, "spring%-boot") then
                        return true
                    end
                end
            elseif build_gradle or build_gradle_kts then
                -- Verificar se o build.gradle contém dependências do Spring Boot
                local gradle_file = build_gradle and "/build.gradle" or "/build.gradle.kts"
                local gradle_content = vim.fn.readfile(cwd .. gradle_file)
                for _, line in ipairs(gradle_content) do
                    if string.match(line, "spring%-boot") then
                        return true
                    end
                end
            end
            
            return false
        end

        -- Só configurar se estivermos em um projeto Spring Boot
        if is_spring_boot_project() then
            -- gain acces to the springboot nvim plugin and its functions
            local springboot_nvim = require("springboot-nvim")

            -- Spring Boot keymaps com prefixo diferente (<leader>S para Spring)
            vim.keymap.set('n', '<leader>Sr', function()
                local ok, err = pcall(springboot_nvim.boot_run)
                if not ok then
                    vim.notify("Erro ao executar Spring Boot: " .. err, vim.log.levels.ERROR)
                end
            end, {desc = "[S]pring Boot [R]un"})
            
            vim.keymap.set('n', '<leader>Sc', function()
                local ok, err = pcall(springboot_nvim.generate_class)
                if not ok then
                    vim.notify("Erro ao gerar classe: " .. err, vim.log.levels.ERROR)
                end
            end, {desc = "[S]pring Boot Create [C]lass"})
            
            vim.keymap.set('n', '<leader>Si', function()
                local ok, err = pcall(springboot_nvim.generate_interface)
                if not ok then
                    vim.notify("Erro ao gerar interface: " .. err, vim.log.levels.ERROR)
                end
            end, {desc = "[S]pring Boot Create [I]nterface"})
            
            vim.keymap.set('n', '<leader>Se', function()
                local ok, err = pcall(springboot_nvim.generate_enum)
                if not ok then
                    vim.notify("Erro ao gerar enum: " .. err, vim.log.levels.ERROR)
                end
            end, {desc = "[S]pring Boot Create [E]num"})

            -- run the setup function with default configuration
            local ok, err = pcall(springboot_nvim.setup, {})
            if not ok then
                vim.notify("Erro ao configurar springboot-nvim: " .. err, vim.log.levels.WARN)
            end
        end
    end
}