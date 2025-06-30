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
        vim.g.copilot_no_tab_map = true
        vim.api.nvim_set_keymap("i", "<C-J>", 'copilot#Accept("<CR>")', { silent = true, expr = true})
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
else
    -- Convert the vimscript keymaps to lua
    -- j/k move by visual line (wrapped)
    vim.keymap.set('n', 'j', 'gj')
    vim.keymap.set('n', 'k', 'gk')
    
    -- gj/gk move by real line
    vim.keymap.set('n', 'gj', 'j')
    vim.keymap.set('n', 'gk', 'k')
end
