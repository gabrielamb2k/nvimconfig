return {
  "elmcgill/springboot-nvim", -- Repositório correto
  dependencies = {
    "neovim/nvim-lspconfig",
    "mfussenegger/nvim-jdtls",
    -- Este plugin pode precisar de nvim-dap se for usar funcionalidades de debug
    -- 'mfussenegger/nvim-dap', -- Descomente se for usar debug Spring Boot
  },
  ft = { "java", "groovy", "xml", "yaml", "properties" }, -- Carrega em mais tipos de arquivo relevantes para Spring
  config = function()
    local springboot_nvim = require("springboot-nvim")

    -- --- IMPORTANTE: CHAMAR O SETUP DO PLUGIN PRIMEIRO ---
    -- O setup() deve ser chamado antes de usar outras funções ou definir keymaps,
    -- pois ele inicializa o plugin. Verifique a documentação do plugin para configurações específicas.
    local ok_setup, err_setup = pcall(springboot_nvim.setup, {
      -- Defina suas configurações aqui, se houver.
      -- Ex: enable_debug = true, -- se o plugin tiver essa opção
    })
    if not ok_setup then
      vim.notify("Erro ao configurar springboot-nvim: " .. err_setup, vim.log.levels.ERROR)
      -- Não retorne aqui, pois as keymaps podem ser definidas de qualquer forma
    end

    -- --- LÓGICA DE DETECÇÃO DE PROJETO (MELHORADA E MOVIDA) ---
    -- A detecção de projeto geralmente deve ser feita pelo próprio plugin ou
    -- por um autocommand que redefine as keymaps quando o diretório muda.
    -- No entanto, para fins de teste e simplificação inicial,
    -- vamos definir as keymaps de forma que elas EXISTAM sempre,
    -- mas apenas funcionem se a condição for satisfeita INTERNAMENTE na função.

    -- Mapeamentos de tecla Spring Boot com prefixo <leader>S
    -- Estes atalhos estarão SEMPRE DISPONÍVEIS, mas as funções internas
    -- podem notificar o usuário se não for um projeto Spring Boot.

    -- Nota: A sua função is_spring_boot_project() não pode ser usada aqui diretamente
    -- para envolver cada keymap, pois ela lê arquivos, o que pode ser lento.
    -- É melhor que a função do plugin (boot_run, generate_class etc.)
    -- faça sua própria verificação de contexto se necessário.

    vim.keymap.set('n', '<leader>Sr', function()
      -- A própria função do plugin (boot_run) deve lidar com o contexto do projeto.
      -- Se não, você pode adicionar um check aqui com notificação.
      -- Ex: if not is_spring_boot_project() then vim.notify("Não é um projeto Spring Boot!", vim.log.levels.INFO) return end
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

    -- Remova a sua função is_spring_boot_project() se ela não for usada em outro lugar,
    -- pois o plugin geralmente lida com a detecção internamente para suas funções.
    -- Se você quiser ter um feedback de "não é Spring Boot", a verificação deve ir dentro de cada keymap's function.

    -- Sua função is_spring_boot_project não é ideal aqui porque ela é lenta (lê arquivos)
    -- e é executada apenas uma vez no carregamento do plugin.
    -- Se você realmente precisa desse tipo de detecção, ela deve ser feita com autocommands
    -- em 'BufEnter' ou 'DirChanged' para definir as keymaps apenas quando necessário.
    -- Mas para este plugin, é mais provável que as funções 'boot_run' etc. façam sua própria verificação.
    -- Portanto, a is_spring_boot_project() que você definiu acima pode ser removida se não for usada.
    -- Apenas mantenha a chamada springboot_nvim.setup({}) no início do bloco config.
  end,
}
