syn match shShebang '^#!.*$' containedin=shComment

syn match shOperator '||'
syn match shOperator '&&'

syn match shSemicolon ';' containedin=shOperator

syn match Constant '\v/dev/\w+' containedin=shFunctionOne,shIf,shCmdParenRegion,shCommandSub

" vim isn't nice about splitting up lists into multiple lines
let commands = [ 'arch', 'awk', 'b2sum', 'base32', 'base64', 'basename', 'basenc', 'bash', 'brew', 'cat', 'chcon', 'chgrp', 'chown', 'chroot', 'cksum', 'comm', 'cp', 'csplit', 'curl', 'cut', 'date', 'dd', 'defaults', 'df', 'dir', 'dircolors', 'dirname', 'ed', 'env', 'expand', 'factor', 'fmt', 'fold', 'git', 'grep', 'groups', 'head', 'hexdump', 'hostid', 'hostname', 'hugo', 'id', 'install', 'join', 'killall', 'link', 'ln', 'logname', 'md5sum', 'mkdir', 'mkfifo', 'mknod', 'mktemp', 'nice', 'nl', 'nohup', 'npm', 'nproc', 'numfmt', 'od', 'open', 'paste', 'pathchk', 'pr', 'printenv', 'printf', 'ptx', 'readlink', 'realpath', 'rg', 'runcon', 'scutil', 'sed', 'seq', 'sha1sum', 'sha2', 'shred', 'shuf', 'split', 'stat', 'stdbuf', 'stty', 'sudo', 'sum', 'sync', 'tac', 'tee', 'terminfo', 'timeout', 'tmux', 'top', 'touch', 'tput', 'tr', 'truncate', 'tsort', 'tty', 'uname', 'unexpand', 'uniq', 'unlink', 'uptime', 'users', 'vdir', 'vim', 'wc', 'who', 'whoami', 'yabai', 'yes' ]

for c in commands
    execute 'syn match shStatement "\v(\w|-)@<!'
                    \ . c
                    \ . '(\w|-)@!" containedin=shFunctionOne,shIf,shCmdParenRegion,shCommandSub'
endfor

hi def link bashSpecialVariables Identifier
hi def link shCmdSubRegion Delimiter
hi def link shDerefSimple Identifier
hi def link shFor Identifier
hi def link shFunctionKey Statement
hi def link shQuote StringDelimiter
hi def link shRange Delimiter
hi def link shSnglCase Delimiter
hi def link shStatement Statement
hi def link shTestOpr Operator
hi def link shVarAssign Operator

hi def link shSemicolon Delimiter
hi def link shShebang PreProc
