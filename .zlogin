# macOS では path_helper と brew shellenv が PATH を並べ替えた後なので組み直す（.zshenv 参照）。
# `[[ ]] && …` にしないのは、Linux で条件が偽になると .zlogin の終了ステータスが 1 になり、
# 最初のプロンプトが「直前のコマンドが失敗した」表示（p10k の赤い ❯）で始まるため。
if [[ $OSTYPE == darwin* ]]; then
    dotfiles_path
fi
