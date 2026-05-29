if status is-interactive
    # Commands to run in interactive sessions can go here
    starship init fish | source

    alias ls='lsd'
    alias ll='lsd -alF'
    alias icat="kitty +kitten icat"
    # Test Text
end

# >>> mamba initialize >>>
# !! Contents within this block are managed by 'mamba shell init' !!
set -gx MAMBA_EXE /home/tr/conda/bin/mamba
set -gx MAMBA_ROOT_PREFIX /home/tr/conda
$MAMBA_EXE shell hook --shell fish --root-prefix $MAMBA_ROOT_PREFIX | source
# <<< mamba initialize <<<
