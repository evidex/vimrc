" dpaste.vim: Vim plugin for pasting to dpaste.com (#django's favourite paste
" bin! )
" Maintainer:   Evidex <evidex @ github>
" Version:      0.2-dev1
"
" Thanks To: 
"   - Paul Bissex (pbx on irc) for creating dpaste :)
"   - The creator of the LodgeIt.vim plugin, in which I blatantly steal some
"   vim specific code from.
"   - Bartek Ciszkowski <bart.ciszk@gmail.com> Maintainer of the DPaste plugin this version is based on 
"
" Usage:
"   :Dpaste     create a paste from the current buffer or selection.
"   
" You can also map paste to CTRL + P, just add this to your .vimrc:
" map ^P :Dpaste<CR>
" (Where ^P is entered using CTRL + V, CTRL + P in Vim)

function! s:DpasteInit()
python << EOF

import vim
import urllib2, urllib
import json

BASE_URL = 'http://dpaste.com/api/v2/'

def get_syntax_mapping():
    """
    Gets a dictionary of syntax mappings from dpaste.com
    """
    print 'Loading Dpaste syntax mappings'
    try: 
        fd = urllib2.urlopen(BASE_URL + 'syntax-choices/')
    except urllib2.URLError:
        print 'Failed to download syntax mapping from dpaste.com'
        return False

    syntax_mapping = {}
    try:
        raw_json = fd.read()
        syntax_mapping = json.JSONDecoder().decode(raw_json)
    except:
        print 'Failed to parse syntax mapping from dpaste.com'
        return False
    return syntax_mapping


def new_paste(**paste_data):
    """
    The function that does all the magic work
    """
    print 'Creating paste'

    data = urllib.urlencode(paste_data)

    try:
        req = urllib2.Request(BASE_URL)
        fd = urllib2.urlopen(req, data)
    except urllib2.URLError:
        print 'Failed to send request to dpaste.com'
        return False

    return fd.getcode(), fd.read()

def make_utf8(code):
    enc = vim.eval('&fenc') or vim.eval('&enc')
    return code.decode(enc, 'ignore').encode('utf-8')

EOF
endfunction


function! s:Dpasteit(line1,line2,count,...)
call s:DpasteInit()
python << endpython

# new paste
if vim.eval('a:0') != '1':
    rng_start = int(vim.eval('a:line1')) - 1
    rng_end = int(vim.eval('a:line2'))

    if int( vim.eval('a:count') ):
        code = "\n".join(vim.current.buffer[rng_start:rng_end])
    else:
        code = "\n".join(vim.current.buffer)

    code = make_utf8(code)
    syntax_mapping = get_syntax_mapping()

    syntax = syntax_mapping.get(vim.eval('&ft'), '')
    paste_data = dict(language=syntax, content=code)

    rcode, paste_url = new_paste(**paste_data)

    if rcode != 201:
        print "Failed paste to Dpaste [%s]" % (rcode)
    else:
        print "Pasted content to %s" % (paste_url)

        vim.command('setlocal nomodified')
        vim.command('let b:dpaste_url="%s"' % paste_url)


endpython
endfunction

command! -range=0 -nargs=* Dpaste :call s:Dpasteit(<line1>,<line2>,<count>,<f-args>)




