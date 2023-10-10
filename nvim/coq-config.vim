
" remap this later:
" I want an insert only remap; this maps insert and normal mode
" may be a better way
let g:coq_settings = { "keymap.jump_to_mark": "",  "keymap.manual_complete": ""  }

" let g:coq_settings = {}

" Keybindings
ino <silent><expr> <Esc>   pumvisible() ? "\<C-e><Esc>" : "\<Esc>"
ino <silent><expr> <C-c>   pumvisible() ? "\<C-e><C-c>" : "\<C-c>"
ino <silent><expr> <BS>    pumvisible() ? "\<C-e><BS>"  : "\<BS>"
ino <silent><expr> <CR>    pumvisible() ? (complete_info().selected == -1 ? "\<C-e><CR>" : "\<C-y>") : "\<CR>"
ino <silent><expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
ino <silent><expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<BS>"

" C-h is what the teriminal reads as shift backspace - I don't like that being used for nav marks
" replacing that with C-f or C-d
inoremap <silent><expr> <C-h>   pumvisible() ? "\<C-e><BS>"  : "\<BS>"
" ino <C-f>                  <C-\><C-N><Cmd>lua COQ.Nav_mark()<CR>

"hooooo boy is this nice.
ino jkl                  <C-\><C-N><Cmd>lua COQ.Nav_mark()<CR>
ino lkj                  <C-\><C-N><Cmd>lua COQ.Nav_mark()<CR>

" ino <C-d>                  <C-\><C-N><Cmd>lua COQ.Nav_mark()<CR>

