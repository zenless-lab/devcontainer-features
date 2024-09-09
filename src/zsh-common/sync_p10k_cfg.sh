# >>> powerlevel10k >>>
if [ -e /.p10k.zsh ]; then
    if [ -e ~/.p10k.zsh ]; then
        rm ~/.p10k.zsh
    fi
    ln -s /.p10k.zsh ~/.p10k.zsh
else
    if [ -e ~/.p10k.zsh ]; then
        cp ~/.p10k.zsh /.p10k.zsh
    fi
    ln -s /.p10k.zsh ~/.p10k.zsh
fi
# <<< powerlevel10k <<<