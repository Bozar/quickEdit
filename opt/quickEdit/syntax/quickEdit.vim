syntax case ignore

syntax match qeKeyword /\v[0-9a-zA-Z_]+\ze\s+\{\s*$/
syntax match qeBracket /\v\s+\{\s*$/
syntax match qeBracket /\v^\s*\}\s*$/
syntax match qeCommand /\v^\s*#(EDIT|TABE):.*/ contains=qePath
syntax match qePath /\v^\s*#(EDIT|TABE):\s*\zs.*/ contained
syntax match qeComment /\v^\s*\/.*$/
syntax region qeError start=/\v^\s*\}\s*$/ skip=/\v^\s*\// end=/\v\ze\S+\s+\{\s*$/ contains=qeBracket, qeComment 

highlight link qeKeyword Type
highlight link qeBracket PreProc
highlight link qeCommand Identifier
highlight link qePath Constant
highlight link qeComment Comment
highlight link qeError Error

