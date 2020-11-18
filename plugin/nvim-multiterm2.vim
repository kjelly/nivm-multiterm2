lua require('nvim-multiterm2')
autocmd! TermOpen * :lua onTermOpen()
autocmd! TermEnter * :lua updateLastTerminalID()
