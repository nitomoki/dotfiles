# macOS では path_helper と brew shellenv が PATH を並べ替えた後なので組み直す（.zshenv 参照）。
[[ $OSTYPE == darwin* ]] && dotfiles_path
