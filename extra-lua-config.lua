        vim.cmd[[
          nnoremap S :%s//g<Left><Left>
          vnoremap S :s//g<Left><Left>

          nmap ds  <Plug>Dsurround
          nmap cs  <Plug>Csurround
          nmap cS  <Plug>CSurround
          nmap ys  <Plug>Ysurround
          nmap yS  <Plug>YSurround
          nmap yss <Plug>Yssurround
          nmap ySs <Plug>YSsurround
          nmap ySS <Plug>YSsurround
          " xmap S   <Plug>VSurround
          xmap gS  <Plug>VgSurround
          imap    <C-S> <Plug>Isurround
          imap      <C-G>s <Plug>Isurround
          imap      <C-G>S <Plug>ISurround
        ]]
        vim.keymap.set('n', '<leader>S', '<cmd>lua require("spectre").toggle()<CR>', {
            desc = "Toggle Spectre"
        })
        vim.keymap.set('n', '<leader>sw', '<cmd>lua require("spectre").open_visual({select_word=true})<CR>', {
            desc = "Search current word"
        })
        vim.keymap.set('v', '<leader>sw', '<esc><cmd>lua require("spectre").open_visual()<CR>', {
            desc = "Search current word"
        })
        vim.keymap.set('n', '<leader>sp', '<cmd>lua require("spectre").open_file_search({select_word=true})<CR>', {
            desc = "Search on current file"
        })
    vim.filetype.add({
      extension = {
        sky = "bzl",
      },
    })

-- sidekick.nvim keymaps (skip inside vscode-neovim)
if not vim.g.vscode then
    local sk = require("sidekick")
    local cli = require("sidekick.cli")
    -- Lower-level handles: let us attach to a *specific* Claude session without
    -- going through sidekick's picker (which lists every Claude running in tmux
    -- system-wide). Uses sidekick internals, so may need a tweak if its session
    -- API changes.
    local cli_state = require("sidekick.cli.state")
    local cli_session = require("sidekick.cli.session")
    local sk_config = require("sidekick.config")

    -- Attach-or-create THE one sidekick-managed Claude for the current repo.
    -- Its session id is deterministic per (tool, cwd), so this always targets
    -- the same Claude for this project: no picker, and it's created if none is
    -- running. (A plain cli.show{filter={cwd=true}} can't create one when none
    -- exists, because the "new session" entry has no cwd to match.)
    local function claude_here(focus)
        cli_session.setup() -- register session backends (tmux/zellij/terminal); idempotent
        local sid = cli_session.sid({ tool = "claude" }) -- deterministic per (tool, cwd)
        -- If this repo's Claude is already attached, reuse its window (focus it)
        -- instead of opening a new one. Otherwise attach-or-create.
        for _, s in pairs(cli_session.attached()) do
            if s.sid == sid then
                cli_state.attach(cli_state.get_state(s), { show = true, focus = focus ~= false })
                return
            end
        end
        cli_state.attach(
            { tool = sk_config.get_tool("claude") },
            { show = true, focus = focus ~= false }
        )
    end

    -- Spawn a brand-new, independent Claude session (unique id) even when one is
    -- already running for this repo.
    local claude_new_seq = 0
    local function claude_new()
        cli_session.setup() -- register session backends (tmux/zellij/terminal); idempotent
        claude_new_seq = claude_new_seq + 1
        local id = ("claude-new-%d-%d"):format(os.time(), claude_new_seq)
        cli_state.attach(
            { tool = sk_config.get_tool("claude"), session = cli_session.new({ tool = "claude", id = id }) },
            { show = true, focus = true }
        )
    end

    -- <tab>: jump to / apply the next edit suggestion, else normal <Tab>
    vim.keymap.set("n", "<tab>", function()
        if not sk.nes_jump_or_apply() then
            return "<Tab>"
        end
    end, { expr = true, desc = "Goto/Apply Next Edit Suggestion" })

    -- Window switching: <C-w> cycles windows directly (the builtin prefix
    -- lives on <Space>w instead). From the CLI terminal, <C-w> also exits
    -- terminal mode first, so it gets you straight back to your code.
    -- vim.keymap.set("n", "<C-w>", "<C-w>w", { desc = "Cycle windows" })
    -- vim.keymap.set("t", "<C-w>", [[<C-\><C-n><C-w>w]], { desc = "Cycle windows (from terminal)" })

    -- <C-c>: jump to this repo's Claude (normal), or send the selection to it
    -- (visual). Safe to steal: only <C-c> *inside the terminal* is SIGINT; in
    -- normal/visual mode <C-c> just acts like <Esc>.
    vim.keymap.set("n", "<C-c>", function() claude_here(true) end,
        { desc = "Claude (this project)" })
    vim.keymap.set("x", "<C-c>", function() cli.send({ msg = "{selection}", name = "claude" }) end,
        { desc = "Send selection to Claude" })
    vim.keymap.set("n", "<leader>aa", function() cli.toggle() end,
        { desc = "Sidekick Toggle CLI" })
    vim.keymap.set("n", "<leader>as", function() cli.select() end,
        { desc = "Sidekick Select CLI" })
    vim.keymap.set("n", "<leader>ad", function() cli.close() end,
        { desc = "Sidekick Detach CLI Session" })
    vim.keymap.set({ "x", "n" }, "<leader>at", function() cli.send({ msg = "{this}" }) end,
        { desc = "Sidekick Send This" })
    vim.keymap.set("n", "<leader>af", function() cli.send({ msg = "{file}" }) end,
        { desc = "Sidekick Send File" })
    vim.keymap.set("x", "<leader>av", function() cli.send({ msg = "{selection}" }) end,
        { desc = "Sidekick Send Visual Selection" })
    vim.keymap.set({ "n", "x" }, "<leader>ap", function() cli.prompt() end,
        { desc = "Sidekick Select Prompt" })
    vim.keymap.set("n", "<leader>ac", function() claude_here(true) end,
        { desc = "Sidekick Claude (this project)" })
    vim.keymap.set("n", "<leader>an", function() claude_new() end,
        { desc = "Sidekick New Claude session" })
end

local function move_visual_line(d)
  return function()
    -- Only works in charwise visual mode
    if vim.api.nvim_get_mode().mode ~= 'v' then 
      return 'g' .. d 
    end
    require('vscode-neovim').action('cursorMove', {
      args = {
        {
          to = d == 'j' and 'down' or 'up',
          by = 'wrappedLine',
          value = vim.v.count1,
          select = true,
        },
      },
    })
    return '<Ignore>'
  end
end

local function move_real_line(d)
  return function()
    -- Only works in charwise visual mode
    if vim.api.nvim_get_mode().mode ~= 'v' then 
      return d 
    end
    require('vscode-neovim').action('cursorMove', {
      args = {
        {
          to = d == 'j' and 'down' or 'up',
          by = 'line',
          value = vim.v.count1,
          select = true,
        },
      },
    })
    return '<Ignore>'
  end
end

if vim.g.vscode then
    -- j/k move by visual line (wrapped)
    vim.keymap.set({ 'v' }, 'j', move_visual_line('j'), { expr = true })
    vim.keymap.set({ 'v' }, 'k', move_visual_line('k'), { expr = true })
    
    -- gj/gk move by real line
    vim.keymap.set({ 'v' }, 'gj', move_real_line('j'), { expr = true })
    vim.keymap.set({ 'v' }, 'gk', move_real_line('k'), { expr = true })

	require('render-markdown').disable()
else
    -- Convert the vimscript keymaps to lua
    -- j/k move by visual line (wrapped)
    vim.keymap.set('n', 'j', 'gj')
    vim.keymap.set('n', 'k', 'gk')
    
    -- gj/gk move by real line
    vim.keymap.set('n', 'gj', 'j')
    vim.keymap.set('n', 'gk', 'k')
end
