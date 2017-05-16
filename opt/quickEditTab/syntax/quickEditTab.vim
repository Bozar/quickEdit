syntax case ignore

syntax match qetKeyword /\v^\s*[0-9a-zA-Z_]+\ze\s+\{\s*$/
syntax match qetBracket /\v\s+\zs\{\s*$/
syntax match qetBracket /\v^\s*\zs\}\s*$/
syntax match qetCommand /\v^\s*#(EDIT|TABE):.*$/ contains=qetPath
syntax match qetPath /\v^\s*#(EDIT|TABE):\s*\zs.*$/ contained
syntax match qetPlaceHolder /\v^\s*\?\s*[^?].*$/
syntax match qetExeString /\v^\s*\?{2}\s*.*$/
syntax match qetComment /\v^\s*\/.*$/
syntax region qetError start=/\v^\s*\}\s*$/ skip=/\v^\s*\// end=/\v\ze\S+\s+\{\s*$/ contains=qetBracket, qetComment 

highlight link qetKeyword Type
highlight link qetBracket PreProc
highlight link qetCommand Identifier
highlight link qetPath Type
highlight link qetPlaceHolder Type
highlight link qetExeString Constant
highlight link qetComment Comment
highlight link qetError Error

