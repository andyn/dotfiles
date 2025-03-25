__bash_git_branch () {
    BRANCH=$(git branch --show-current 2>/dev/null)
    if [ $? -eq 0 ]; then
        STATUS=$(git status --porcelain=v2 --branch --show-stash)
        AHEAD=$(echo "$STATUS" | grep -F "# branch.ab" | cut -d" " -f3)
        BEHIND=$(echo "$STATUS" | grep -F "# branch.ab" | cut -d" " -f4)
        STASH=$(echo "$STATUS" | grep -F "# stash" | cut -d" " -f3)
        echo -e "\[\e[38;5;214m\]⌥ $BRANCH \[\e[1;32m\]$AHEAD\[\e[0m\] \[\e[1;31m\]$BEHIND\[\e[0m\] \[\e[1;34m\]$STASH\[\e[0m\]"
    fi
}

__bash_kube_context () {
    CONTEXT=$(kubectl config current-context 2>/dev/null)
    if [ $? -eq 0 ]; then
        NAMESPACE=$(kubectl config view --minify -o jsonpath='{..namespace}')
        echo -e "\[\e[1;38;5;33m\]⎈ $CONTEXT/$NAMESPACE\[\e[0m\]"
        return 0
    else
        return 1
    fi
}

__bash_kube_context_or_hostname () {
    KUBECONTEXT=$(__bash_kube_context)
    if [ $? -eq 0 ]; then
        echo "$KUBECONTEXT"
    else
        echo "\[\033[01;32m\]\h\[\033[00m\]"
    fi
}

__bash_check_empty_line () {
    PS1="$(__bash_kube_context_or_hostname):\[\033[01;34m\]\W$(__bash_git_branch)\[\033[00m\]\[\e[91m\]\[\e[00m\]$ "

    prompt_command__isnewline__last="$prompt_command__isnewline__curr"
    prompt_command__isnewline__curr="$(history 1 | sed 's/^[[:space:]]*[0-9]\+[[:space:]]*//')"
    if [ "$prompt_command__isnewline__curr" = "$prompt_command__isnewline__last" ]; then
        PS1=$(echo "$PS1" | sed 's/\\W/\\w/g')
    fi
}

export PROMPT_COMMAND=__bash_check_empty_line
