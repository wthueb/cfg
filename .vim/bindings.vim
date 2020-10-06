"nnoremap ; :
"vnoremap ; :

inoremap kj <Esc>
cnoremap kj <C-c>

" C-hjkl for left/down/up/right in insert and command mode
inoremap <C-h> <Left>
inoremap <C-j> <Down>
inoremap <C-k> <Up>
inoremap <C-l> <Right>
cnoremap <C-h> <Left>
cnoremap <C-j> <Down>
cnoremap <C-k> <Up>
cnoremap <C-l> <Right>

"nnoremap S :%s/

nnoremap <leader><leader> :w<CR>:sus<CR>
nnoremap \\ :wq<CR>

" get rid of highlighting
nnoremap <silent> <leader>. :nohl<CR>

" switching between panes
nnoremap <C-j> <C-w><C-j>
nnoremap <C-k> <C-w><C-k>
nnoremap <C-l> <C-w><C-l>
nnoremap <C-h> <C-w><C-h>

" buffers
nnoremap <leader>b :bp<CR>
