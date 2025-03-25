__bash_git_branch () {
    if (git rev-parse --is-inside-work-tree | grep true) >/dev/null 2>&1; then
        FETCH_HEAD="$(git rev-parse --show-toplevel)/.git/FETCH_HEAD"
        if [ -f ${FETCH_HEAD} ]; then
            FETCHED_AT=$(stat -c %Y ${FETCH_HEAD})
        else
            FETCHED_AT=0
        fi
        NOW=$(date +%s)
        if [ $(($NOW - $FETCHED_AT)) -ge 900 ]; then
            tput sc
            echo -en "" && tput civis; tput cnorm
            git fetch --no-tags --prune --filter=blob:none >/dev/null 2>&1;
            tput rc
            tput el
        fi

        BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null || git describe --tags --exact-match 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
        STATUS=$(git status --porcelain=v2 --branch --show-stash)

        if ! git diff --quiet ; then
            DIRTY="!"
        elif git status --porcelain | grep '^??' >/dev/null; then
            DIRTY="*"
        else
            DIRTY=""
        fi

        AHEAD="$(echo " $(echo "${STATUS}" | grep -F "# branch.ab" | cut -d" " -f3)" | grep -- "+[1-9]")"
        BEHIND="$(echo " $(echo "${STATUS}" | grep -F "# branch.ab" | cut -d" " -f4)" | grep -- "-[1-9]")"
        STASH="$(echo " ~$(echo "${STATUS}" | grep -F "# stash" | cut -d" " -f3)" | grep -- "[1-9]")"
        echo -e "\[\e[38;5;214m\]⌥ ${BRANCH}${DIRTY}\[\e[1;32m\]${AHEAD}\[\e[0m\]\[\e[1;31m\]${BEHIND}\[\e[0m\]\[\e[1;34m\]${STASH}\[\e[0m\]"
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

__bash_exit_status () {
    local status=$?
    if [ $status -eq 0 ]; then
        return
    elif [ $status -ge 128 ] && [ $status -lt 255 ]; then
        local signal_name=$(kill -l $((status - 128)))
        echo -ne "\[\e[1;31m\]$signal_name \[\e[0m\]"
    else
        echo -ne "\[\e[1;31m\]$status \[\e[0m\]"
    fi
}

__bash_prompt () {
    EXIT_STATUS=$"$(__bash_exit_status)"
    KUBE_CONTEXT="$(__bash_kube_context_or_hostname)"
    GIT_BRANCH="$(__bash_git_branch)"
    PS1="${EXIT_STATUS}${KUBE_CONTEXT}:\[\033[01;34m\]\W${GIT_BRANCH}\[\033[00m\]\[\e[91m\]\[\e[00m\]$ "

    prompt_command__isnewline__last="$prompt_command__isnewline__curr"
    prompt_command__isnewline__curr="$(history 1 | sed 's/^[[:space:]]*[0-9]\+[[:space:]]*//')"
    if [ "$prompt_command__isnewline__curr" = "$prompt_command__isnewline__last" ]; then
        PS1=$(echo "$PS1" | sed 's/\\W/\\w/g')
    fi
}

export PROMPT_COMMAND=__bash_prompt
