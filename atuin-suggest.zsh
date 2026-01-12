# atuin-suggest.zsh - Fish-style autosuggestions powered by atuin
# Lightweight clone of zsh-autosuggestions using atuin's history search

#-----------------------------------------------------------------------------
# Configuration
#-----------------------------------------------------------------------------
: ${ATUIN_SUGGEST_HIGHLIGHT_STYLE:="fg=8"}
: ${ATUIN_SUGGEST_SEARCH_MODE:="prefix"}

#-----------------------------------------------------------------------------
# Internal State
#-----------------------------------------------------------------------------
typeset -g _atuin_suggest_suggestion=""
typeset -g _atuin_suggest_last_highlight=""

#-----------------------------------------------------------------------------
# Suggestion Fetching
#-----------------------------------------------------------------------------
_atuin_suggest_fetch() {
    local prefix="$BUFFER"

    # Don't suggest for empty buffer
    if [[ -z "$prefix" ]]; then
        _atuin_suggest_suggestion=""
        return
    fi

    # Query atuin for the best match
    _atuin_suggest_suggestion=$(atuin search --cmd-only --limit 1 --search-mode "$ATUIN_SUGGEST_SEARCH_MODE" "$prefix" 2>/dev/null)

    # Only keep if it starts with our prefix (sanity check for prefix mode)
    if [[ "$_atuin_suggest_suggestion" != "$prefix"* ]]; then
        _atuin_suggest_suggestion=""
    fi
}

#-----------------------------------------------------------------------------
# Highlighting (managed by widget wrappers, not action functions)
#-----------------------------------------------------------------------------
_atuin_suggest_highlight_reset() {
    if [[ -n "$_atuin_suggest_last_highlight" ]]; then
        region_highlight=("${(@)region_highlight:#$_atuin_suggest_last_highlight}")
        _atuin_suggest_last_highlight=""
    fi
}

_atuin_suggest_highlight_apply() {
    if (( $#POSTDISPLAY )); then
        _atuin_suggest_last_highlight="$#BUFFER $(($#BUFFER + $#POSTDISPLAY)) $ATUIN_SUGGEST_HIGHLIGHT_STYLE"
        region_highlight+=("$_atuin_suggest_last_highlight")
    else
        _atuin_suggest_last_highlight=""
    fi
}

#-----------------------------------------------------------------------------
# Action Functions (only modify BUFFER/POSTDISPLAY, no highlight management)
#-----------------------------------------------------------------------------
_atuin_suggest_suggest() {
    if [[ -n "$_atuin_suggest_suggestion" && "$_atuin_suggest_suggestion" != "$BUFFER" ]]; then
        POSTDISPLAY="${_atuin_suggest_suggestion#$BUFFER}"
    else
        POSTDISPLAY=""
    fi
}

_atuin_suggest_clear() {
    POSTDISPLAY=""
    _atuin_suggest_suggestion=""
}

_atuin_suggest_modify() {
    zle .self-insert
    _atuin_suggest_fetch
    _atuin_suggest_suggest
}

_atuin_suggest_delete() {
    zle .backward-delete-char
    _atuin_suggest_fetch
    _atuin_suggest_suggest
}

_atuin_suggest_accept_full() {
    if (( $#POSTDISPLAY )); then
        BUFFER="$BUFFER$POSTDISPLAY"
        POSTDISPLAY=""
        _atuin_suggest_suggestion=""
        CURSOR=$#BUFFER
    else
        zle .end-of-line
    fi
}

_atuin_suggest_accept_word() {
    if (( $#POSTDISPLAY )); then
        local suggestion="$_atuin_suggest_suggestion"
        local remaining="$POSTDISPLAY"

        # Extract next word (including leading spaces)
        local next_word=""
        if [[ "$remaining" =~ ^[[:space:]]*[^[:space:]]+ ]]; then
            next_word="$MATCH"
        else
            next_word="$remaining"
        fi

        BUFFER="$BUFFER$next_word"
        CURSOR=$#BUFFER

        # Update POSTDISPLAY with remaining suggestion
        if [[ "$BUFFER" == "$suggestion" ]]; then
            POSTDISPLAY=""
            _atuin_suggest_suggestion=""
        else
            POSTDISPLAY="${suggestion#$BUFFER}"
        fi
    else
        zle .forward-char
    fi
}

_atuin_suggest_up() {
    POSTDISPLAY=""
    _atuin_suggest_suggestion=""
    zle .up-line-or-history
}

_atuin_suggest_down() {
    POSTDISPLAY=""
    _atuin_suggest_suggestion=""
    zle .down-line-or-history
}

#-----------------------------------------------------------------------------
# Widget Wrappers (handle highlight reset -> action -> highlight apply -> redraw)
#-----------------------------------------------------------------------------
_atuin_suggest_widget_modify() {
    _atuin_suggest_highlight_reset
    _atuin_suggest_modify
    _atuin_suggest_highlight_apply
    zle -R
}

_atuin_suggest_widget_delete() {
    _atuin_suggest_highlight_reset
    _atuin_suggest_delete
    _atuin_suggest_highlight_apply
    zle -R
}

_atuin_suggest_widget_accept_full() {
    _atuin_suggest_highlight_reset
    _atuin_suggest_accept_full
    _atuin_suggest_highlight_apply
    zle -R
}

_atuin_suggest_widget_accept_word() {
    _atuin_suggest_highlight_reset
    _atuin_suggest_accept_word
    _atuin_suggest_highlight_apply
    zle -R
}

_atuin_suggest_widget_up() {
    _atuin_suggest_highlight_reset
    _atuin_suggest_up
    _atuin_suggest_highlight_apply
    zle -R
}

_atuin_suggest_widget_down() {
    _atuin_suggest_highlight_reset
    _atuin_suggest_down
    _atuin_suggest_highlight_apply
    zle -R
}

#-----------------------------------------------------------------------------
# Widget Registration
#-----------------------------------------------------------------------------
zle -N self-insert _atuin_suggest_widget_modify
zle -N backward-delete-char _atuin_suggest_widget_delete
zle -N atuin-suggest-accept-full _atuin_suggest_widget_accept_full
zle -N atuin-suggest-accept-word _atuin_suggest_widget_accept_word
zle -N up-line-or-history _atuin_suggest_widget_up
zle -N down-line-or-history _atuin_suggest_widget_down

#-----------------------------------------------------------------------------
# Key Bindings
#-----------------------------------------------------------------------------
bindkey '^[[F' atuin-suggest-accept-full    # End key
bindkey '^[[4~' atuin-suggest-accept-full   # End key (alternate)
bindkey '^[OF' atuin-suggest-accept-full    # End key (application mode)
bindkey '^E' atuin-suggest-accept-full      # Ctrl-E
bindkey '^[[C' atuin-suggest-accept-word    # Right arrow
bindkey '^[OC' atuin-suggest-accept-word    # Right arrow (application mode)
