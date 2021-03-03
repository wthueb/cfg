command! -nargs=+ Silent execute 'silent ! <args>' | redraw!

nmap <leader>r :w<CR>:Silent pdflatex % && open -a Preview && open -a iTerm<CR>
