def Settings(**kwargs):
    client_data = kwargs['client_data']

    return {
        'interpreter_path': client_data['g:ycm_python_interpreter_path'],

        # -I../include works assume the header files
        # are in proj/include/ and the source file is in proj/*/
        'flags': ['-x', 'c++', '-Wall', '-Wextra', '-std=c++14', '-I../include']
    }
