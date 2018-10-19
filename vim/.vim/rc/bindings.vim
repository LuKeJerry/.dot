" enable mouse integration
set mouse=a

" map leader key to <space>
let mapleader = ' '
" map local leader key to <comma>
let maplocalleader = ','

" Trigger to preserve indentation on pastes
set pastetoggle=<F12>
" Easier than escape. Pinnacle of laziness.
inoremap jk <ESC>
inoremap Jk <ESC>
inoremap JK <ESC>
inoremap jK <ESC>
" Turn off search highlighting
noremap <silent> <leader>? :nohlsearch<CR>

nnoremap <leader>h :<C-u>h

" Navigation {{{
    " Normalize all the navigation keys to move by row/col despite any wrapped text
    noremap j gj
    noremap k gk
    " % matchit shortcut, but only in normal mode!
    nmap <Tab> %
    " Easier fold toggle
    nnoremap <Space> 5j
    vnoremap <Space> 5j
    nnoremap <Backspace> 5k
    vnoremap <Backspace> 5k

    " Make motions sensitive to wrapped lines
    " Same for 0, home, end, etc
    function! WrapRelativeMotion(key, ...)
        let vis_sel=""
        if a:0
            let vis_sel="gv"
        endif
        if &wrap
            execute "normal!" vis_sel . "g" . a:key
        else
            execute "normal!" vis_sel . a:key
        endif
    endfunction

    " Map g* keys in Normal, Operator-pending, and Visual+select
    noremap <silent> $ :call WrapRelativeMotion("$")<CR>
    noremap <silent> <End> :call WrapRelativeMotion("$")<CR>
    noremap <silent> 0 :call WrapRelativeMotion("0")<CR>
    noremap <silent> <Home> :call WrapRelativeMotion("0")<CR>
    noremap <silent> ^ :call WrapRelativeMotion("^")<CR>
    " Overwrite the operator pending $/<End> mappings from above
    " to force inclusive motion with :execute normal!
    onoremap <silent> $ v:call WrapRelativeMotion("$")<CR>
    onoremap <silent> <End> v:call WrapRelativeMotion("$")<CR>
    " Overwrite the Visual+select mode mappings from above
    " to ensure the correct vis_sel flag is passed to function
    vnoremap <silent> $ :<C-U>call WrapRelativeMotion("$", 1)<CR>
    vnoremap <silent> <End> :<C-U>call WrapRelativeMotion("$", 1)<CR>
    vnoremap <silent> 0 :<C-U>call WrapRelativeMotion("0", 1)<CR>
    vnoremap <silent> <Home> :<C-U>call WrapRelativeMotion("0", 1)<CR>
    vnoremap <silent> ^ :<C-U>call WrapRelativeMotion("^", 1)<CR>
" }}}

" Editing {{{
    nnoremap <C-b> <C-^>
    " Insert-mode navigation
    " Go to end of line
    inoremap <C-e> <Esc>A
    " Go to start of line
    inoremap <C-a> <Esc>I

    " Make Y act consistant with C and D
    nnoremap Y y$

    " Don't leave visual mode after indenting
    vnoremap < <gv
    vnoremap > >gv

    " Textmate-like CMD+Enter (O in insert mode)
    inoremap <S-CR> <C-O>o
    inoremap <C-S-CR> <C-O>O

    " Enabling repeat in visual mode
    vmap . :normal .<CR>
" }}}

" Buffers {{{
    " Next/prev buffer
    nnoremap ]b :<C-u>bnext<CR>
    nnoremap [b :<C-u>bprevious<CR>
" }}}

" Command {{{
    " Annoying command mistakes <https://github.com/spf13/spf13-vim>
    com! -bang -nargs=* -complete=file E e<bang> <args>
    com! -bang -nargs=* -complete=file W w<bang> <args>
    com! -bang -nargs=* -complete=file Wq wq<bang> <args>
    com! -bang -nargs=* -complete=file WQ wq<bang> <args>
    com! -bang Wa wa<bang>
    com! -bang WA wa<bang>
    com! -bang Q q<bang>
    com! -bang QA qa<bang>
    com! -bang Qa qa<bang>
    " Forget to sudo?
    com! WW w !sudo tree % >/dev/null

    " Shortcuts
    cnoremap ;/ <C-R>=expand('%:p:h').'/'<CR>
    cnoremap ;; <C-R>=expand("%:t")<CR>
    cnoremap ;. <C-R>=expand("%:p:r")<CR>

    " Mimic shortcuts in the terminal
    cnoremap <C-a> <Home>
    cnoremap <C-e> <End>
" }}}

" External Tools {{{
    " Send cwd to tmux
    nnoremap <leader>t. :<C-u>call VimuxRunCommand("cd <C-r>=expand("%:p:h")<CR>")<CR>
    nnoremap <leader>t/ :<C-u>call VimuxRunCommand("cd <C-r>=getcwd()<CR>")<CR>
    nnoremap <leader>ts :<C-u>call VimuxRunCommand("tmux split-window")<CR>
    nnoremap <leader>tv :<C-u>call VimuxRunCommand("tmux split-window -h")<CR>
    nnoremap <leader>tc :<C-u>call VimuxRunCommand("tmux new-window")<CR>

    com! -nargs=* T call VimuxRunCommand(<q-args>)
" }}}

" Plugins {{{
    " bufkill
    nnoremap zx :Bdelete<CR>

    " Tabularize
    nmap <leader>= :Tabularize /
    vmap <leader>= :Tabularize /

    " Sneak
    "replace 'f' with 1-char Sneak
    nmap f <Plug>Sneak_f
    nmap F <Plug>Sneak_F
    xmap f <Plug>Sneak_f
    xmap F <Plug>Sneak_F
    omap f <Plug>Sneak_f
    omap F <Plug>Sneak_F
    "replace 't' with 1-char Sneak
    nmap t <Plug>Sneak_t
    nmap T <Plug>Sneak_T
    xmap t <Plug>Sneak_t
    xmap T <Plug>Sneak_T
    omap t <Plug>Sneak_t
    omap T <Plug>Sneak_T

    " vim-switch
    nnoremap ! :Switch<CR>
" }}}

" Completion {{{
    inoremap <expr> <C-Space> pumvisible() \|\| &omnifunc == '' ?
            \ "\<lt>C-n>" :
            \ "\<lt>C-x>\<lt>C-o><c-r>=pumvisible() ?" .
            \ "\"\\<lt>c-n>\\<lt>c-p>\\<lt>c-n>\" :" .
            \ "\" \\<lt>bs>\\<lt>C-n>\"\<CR>"
    imap <C-@> <C-Space>
" }}}

" Windows {{{
    map <C-h> <C-w>h
    map <C-j> <C-w>j
    map <C-k> <C-w>k
    map <C-l> <C-w>l
" }}}


nnoremap <silent> <Leader>bs :w<CR>