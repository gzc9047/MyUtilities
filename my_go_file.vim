function! louix:GoFile(...)
    let pattern   = ""
    let argcnt = 1
    if argcnt <= a:0
        let pattern = a:{argcnt}
    endif
    if pattern == ""
        let pattern = input("Search filename for pattern: ", expand("<cword>"))
    endif

    let tmpfile = tempname()
    let cmd = 'grep . -m 1 -In `find $PWD | grep ' . pattern . '`'
    let cmd_output = system(cmd)

    let old_verbose = &verbose
    set verbose&vim

    exe "redir! > " . tmpfile
    silent echon '[Search filename results for pattern: ' . pattern . "]\n"
    silent echon cmd_output
    redir END

    let &verbose = old_verbose

    let old_efm = &efm
    set efm=%f:%\\s%#%l:%m

    execute "silent! cgetfile " . tmpfile
    botright copen
    let &efm = old_efm
    call delete(tmpfile)
endfunction

command! -nargs=* -complete=file GoFile call louix:GoFile(<f-args>)
