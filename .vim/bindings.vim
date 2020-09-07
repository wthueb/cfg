nnoremap ; :
vnoremap ; :

inoremap kj <Esc>
cnoremap kj <C-c>

nnoremap S :%s/

nnoremap <leader><leader> :w<CR>:sus<CR>
nnoremap \\ :wq<CR>

" get rid of highlighting
nnoremap <leader>. :nohl<CR>

" switching between panes
nnoremap <C-j> <C-w><C-j>
nnoremap <C-k> <C-w><C-k>
nnoremap <C-l> <C-w><C-l>
nnoremap <C-h> <C-w><C-h>

" buffers
nnoremap <leader>l :ls<CR>
nnoremap <leader>b :bp<CR>
nnoremap <leader>1 :1b<CR>
nnoremap <leader>2 :2b<CR>
nnoremap <leader>3 :3b<CR>
nnoremap <leader>4 :4b<CR>
nnoremap <leader>5 :5b<CR>
nnoremap <leader>6 :6b<CR>
nnoremap <leader>7 :7b<CR>
nnoremap <leader>8 :8b<CR>
nnoremap <leader>9 :9b<CR>
nnoremap <leader>0 :10b<CR>
