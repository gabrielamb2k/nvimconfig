return {
  "elmcgill/springboot-nvim",
  dependencies = {
    "neovim/nvim-lspconfig",
    "mfussenegger/nvim-jdtls",
  },
  event = "VimEnter",
  config = function()
    -- Função para verificar se é um projeto Spring
    local function is_spring_project()
      local root = vim.fn.getcwd()
      local pom_exists = vim.fn.filereadable(root .. "/pom.xml") == 1
      local gradle_exists = vim.fn.filereadable(root .. "/build.gradle") == 1
      local gradle_kts_exists = vim.fn.filereadable(root .. "/build.gradle.kts") == 1
      
      if not (pom_exists or gradle_exists or gradle_kts_exists) then
        return false
      end
      
      -- Verifica pom.xml
      if pom_exists then
        local ok, pom_content = pcall(vim.fn.readfile, root .. "/pom.xml")
        if ok then
          local content = table.concat(pom_content, "\n")
          if string.find(content, "spring%-boot") or string.find(content, "org%.springframework") then
            return true
          end
        end
      end
      
      -- Verifica build.gradle
      if gradle_exists then
        local ok, gradle_content = pcall(vim.fn.readfile, root .. "/build.gradle")
        if ok then
          local content = table.concat(gradle_content, "\n")
          if string.find(content, "spring%-boot") or string.find(content, "org%.springframework") then
            return true
          end
        end
      end
      
      -- Verifica build.gradle.kts
      if gradle_kts_exists then
        local ok, gradle_kts_content = pcall(vim.fn.readfile, root .. "/build.gradle.kts")
        if ok then
          local content = table.concat(gradle_kts_content, "\n")
          if string.find(content, "spring%-boot") or string.find(content, "org%.springframework") then
            return true
          end
        end
      end
      
      return false
    end

    -- Só configura se for projeto Spring Boot
    if not is_spring_project() then
      return
    end

    -- Configuração do plugin
    local springboot_nvim = require("springboot-nvim")
    
    -- Setup do plugin
    local ok_setup, err_setup = pcall(springboot_nvim.setup, {})
    if not ok_setup then
      vim.notify("Erro ao configurar springboot-nvim: " .. err_setup, vim.log.levels.ERROR)
      return
    end

    -- Função para verificar se o plugin está disponível
    local function safe_call(func, error_msg)
      return function()
        local ok, err = pcall(func)
        if not ok then
          vim.notify(error_msg .. ": " .. err, vim.log.levels.ERROR)
        end
      end
    end
    -- Keymaps com prefixo J (Java)
    vim.keymap.set('n', '<leader>Jr', safe_call(
      springboot_nvim.boot_run,
      "Erro ao executar Spring Boot"
    ), {desc = "[J]ava Spring Boot [R]un"})

    vim.keymap.set('n', '<leader>Js', safe_call(
      springboot_nvim.boot_stop,
      "Erro ao parar Spring Boot"
    ), {desc = "[J]ava Spring Boot [S]top"})

    vim.keymap.set('n', '<leader>Jl', safe_call(
      springboot_nvim.generate_class,
      "Erro ao gerar classe"
    ), {desc = "[J]ava Spring Boot C[l]ass"})

    vim.keymap.set('n', '<leader>Ji', safe_call(
      springboot_nvim.generate_interface,
      "Erro ao gerar interface"
    ), {desc = "[J]ava Spring Boot [I]nterface"})

    vim.keymap.set('n', '<leader>Je', safe_call(
      springboot_nvim.generate_enum,
      "Erro ao gerar enum"
    ), {desc = "[J]ava Spring Boot [E]num"})

    -- Comando para verificar status do Spring Boot
    vim.keymap.set('n', '<leader>Jt', function()
      local ok, status = pcall(springboot_nvim.boot_status)
      if ok then
        vim.notify("Spring Boot Status: " .. (status and "Running" or "Stopped"), vim.log.levels.INFO)
      else
        vim.notify("Erro ao verificar status: " .. status, vim.log.levels.ERROR)
      end
    end, {desc = "[J]ava Spring Boot S[t]atus"})

    -- Comando personalizado para limpar e rodar
    vim.keymap.set('n', '<leader>Jw', function()
      local ok1, _ = pcall(springboot_nvim.boot_stop)
      vim.defer_fn(function()
        local ok2, err = pcall(springboot_nvim.boot_run)
        if not ok2 then
          vim.notify("Erro ao reiniciar Spring Boot: " .. err, vim.log.levels.ERROR)
        end
      end, 1000)
    end, {desc = "[J]ava Spring Boot Restart ([W]ipe and run)"})
  end,
}