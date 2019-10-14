from os import environ
import os.path

def Settings(**kwargs):
    client_data = kwargs['client_data']

    path = None

    if 'PATH' in environ:
        for p in environ['PATH'].split(':'):
            potential = os.path.join(p, 'python')

            if os.path.exists(potential):
                path = potential
                break

    if not path:
        if os.path.exists('env/bin'):
            path = 'env/bin/python'
        else:
            path = '/usr/local/bin/python'

    return {
        # python interpreter path for python syntax highlighting and completion
        'interpreter_path': path,

        # gcc flags for c syntax highlighting and completion

        # -I../include works assuming the header files are
        # in PRJ_ROOT/include/ and the source files are in PRJ_ROOT/src/
        'flags': ['-x', 'c++', '-Wall', '-Wextra', '-std=c++14', '-I../include']
    }
