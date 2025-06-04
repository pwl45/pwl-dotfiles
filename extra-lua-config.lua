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
