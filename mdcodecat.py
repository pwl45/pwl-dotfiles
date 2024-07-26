#!/usr/bin/env python3

import sys
import os

# Mapping of file extensions to their corresponding language and comment style
FILE_TYPES = {
    '.py': ('python', '#'),
    '.c': ('c', '//'),
    '.h': ('c', '//'),
    '.cpp': ('cpp', '//'),
    '.cc': ('cpp', '//'),
    '.cxx': ('cpp', '//'),
    '.hpp': ('cpp', '//'),
    '.hh': ('cpp', '//'),
    '.hxx': ('cpp', '//'),
    '.rs': ('rust', '//'),
    '.nix': ('nix', '#'),
    '.java': ('java', '//'),
    '.vim': ('vim', '"'),
    '.lua': ('lua', '--'),
    '.el': ('emacs-lisp', ';'),
    '.lisp': ('lisp', ';'),
    '.clj': ('clojure', ';'),
    '.scm': ('scheme', ';'),
    '.go': ('go', '//'),
    '.js': ('javascript', '//'),
    '.ts': ('typescript', '//'),
    '.rb': ('ruby', '#'),
    '.sh': ('bash', '#'),
    '.html': ('html', '<!--'),
    '.css': ('css', '/*'),
    '.sql': ('sql', '--'),
    '.php': ('php', '//'),
    '.swift': ('swift', '//'),
    '.kt': ('kotlin', '//'),
    '.scala': ('scala', '//'),
    '.hs': ('haskell', '--'),
    '.ml': ('ocaml', '(*'),
    '.fs': ('fsharp', '//'),
    '.r': ('r', '#'),
    '.jl': ('julia', '#'),
    '.m': ('matlab', '%'),
    '.pl': ('perl', '#'),
    '.yaml': ('yaml', '#'),
    '.toml': ('toml', '#'),
}

def get_file_info(file_path):
    _, ext = os.path.splitext(file_path)
    return FILE_TYPES.get(ext, ('plaintext', '#'))

def mdcodecat(file_paths):
    for file_path in file_paths:
        try:
            with open(file_path, 'r') as file:
                content = file.read()
            
            lang, comment = get_file_info(file_path)
            filename = os.path.basename(file_path)
            
            print(f"```{lang}")
            if lang == 'html':
                print(f"{comment} {filename} -->")
            elif lang == 'css':
                print(f"{comment} {filename} */")
            elif lang == 'ocaml':
                print(f"{comment} {filename} *)")
            else:
                print(f"{comment} {filename}")
            print(content.rstrip())
            print("```")
            print()  # Add an empty line between files
        except IOError as e:
            print(f"Error reading file {file_path}: {e}", file=sys.stderr)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: mdcodecat <file1> <file2> ...", file=sys.stderr)
        sys.exit(1)
    
    mdcodecat(sys.argv[1:])
