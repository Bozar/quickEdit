syntax case ignore

syntax match qeKeyword /\v^\s*[0-9a-zA-Z_]+\ze\s+\{\s*$/
syntax match qeBracket /\v\s+\zs\{\s*$/
syntax match qeBracket /\v^\s*\zs\}\s*$/
syntax match qeCommand /\v^\s*#(EDIT|TABE):.*$/ contains=qePath
syntax match qePath /\v^\s*#(EDIT|TABE):\s*\zs.*$/ contained
syntax match qePlaceHolder /\v^\s*\?\s*[^?].*$/
syntax match qeExeString /\v^\s*\?{2}\s*.*$/
syntax match qeComment /\v^\s*\/.*$/
syntax region qeError start=/\v^\s*\}\s*$/ skip=/\v^\s*\// end=/\v\ze\S+\s+\{\s*$/ contains=qeBracket, qeComment 

highlight link qeKeyword Type
highlight link qeBracket PreProc
highlight link qeCommand Identifier
highlight link qePath Type
highlight link qePlaceHolder Type
highlight link qeExeString Constant
highlight link qeComment Comment
highlight link qeError Error

