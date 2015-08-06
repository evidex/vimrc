setl ts=2
setl sts=2
setl sw=2
setl et
setl keywordprg="puppet describe --providers"
setl iskeyword=-,:,@,48-57,_,192-255
setl commentstring=#%s
setl foldmethod=syntax
nmap <Leader>l :!PPVER=$(puppet --version); if [[ $PPVER > 2.7.0 ]]; then puppet parser validate % ;else puppet --parseonly %;fi; [[ $? = 0 ]] && puppet-lint %<CR>

" Have detection for tagbar
let g:tagbar_type_puppet = {
      \ 'ctagstype' : 'puppet',
      \ 'kinds'     : [
        \ 'c:class',
        \ 's:site',
        \ 'n:node',
        \ 'd:define'
      \ ],
      \ 'sort'    : 1
\ }

