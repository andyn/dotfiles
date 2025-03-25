" system wide defaults
if filereadable("/usr/share/vim/vimrc")
  source /usr/share/vim/vimrc
endif

python3 from powerline.vim import setup as powerline_setup
python3 powerline_setup()
python3 del powerline_setup

set laststatus=2

" terminal title
set title

" 256 color support \o/
set t_Co=256
" Disable background color erase
set t_ut=
"set t_AB=^[[48;5;%dm
"set t_AF=^[[38;5;%dm

" color scheme
" colorscheme xterm16
colorscheme monokai

" Syntax hilighting and other bells 'n' whistles
syntax enable
filetype plugin indent on

set tabstop=4
set expandtab

" advanced mouse use
" set mouse=a

" we aren't interested in donating any money to uganda
set shortmess+=I
