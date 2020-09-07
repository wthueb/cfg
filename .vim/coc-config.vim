call coc#config('coc.preferences', {
        \ 'formatOnTypeFiletypes': ['css', 'markdown']
        \})

call coc#config('json', {
        \ 'enable': v:true,
        \ 'format.enable': v:true
        \})

call coc#config('python', {
        \ 'autoUpdateLanguageServer': v:true,
        \ 'formatting.provider': 'flake8',
        \ 'jediEnabled': v:false,
        \ 'linting.enabled': v:true,
        \ 'linting.flake8Enabled': v:true,
        \ 'linting.pep8Enabled': v:false,
        \ 'linting.pylintEnabled': v:false
        \})
