#!/usr/bin/env zsh

_zabb_debug() {
    if [ -n "$debug" ]; then
        echo "$*"
    fi
}

_zabb_dangerous() {
    local strippedWhitespace=$(echo "$@" | xargs)
    if [[ "$*" != "$strippedWhitespace" ]]; then
        _zabb_debug "space is a bad abbreviation ($*)"
        return 0
    fi
    # -i and -s cannot be arguments to zoxide query
    if [[ "$*" == "-i" ]]; then
        _zabb_debug "sorry, can't check for -i"
        return 0
    fi
    if [[ "$*" == "-s" ]]; then
        _zabb_debug "sorry, can't check for -s"
        return 0
    fi
    if [[ "$*" == "~" ]]; then
        _zabb_debug "tilde is a bad abbreviation"
        return 0
    fi
    if [[ "$*" =~ ^"~".* ]]; then
        _zabb_debug "starting with tilde is a bad abbreviation"
        return 0
    fi
    return 4
}

_zabb_find_abbrevs() {
    local directory="$*"
    local basename=$(basename "$directory" | tr '[:upper:]' '[:lower:]')
    local baseLength=${#basename}

    for ((length = 1; length < baseLength + 1; length++)); do
        local abbrevs=()
        local endoffset=$([ -n "$shortest" ] || [ -n "$all" ] && echo $((baseLength - length + 1)) || echo 1)
        for ((offset = 0; offset < endoffset; offset++)); do
            local fragment="${basename:$offset:$length}"
            if _zabb_dangerous "$fragment"; then
                continue
            fi
            if ! local foundDirectory=$((eval ""$z_query" "$fragment"") 2>/dev/null); then
                continue
            fi
            if [[ "$foundDirectory" == '' ]]; then
                continue
            fi
            local realFoundDirectory=$(realpath "$foundDirectory")

            if [[ "$realFoundDirectory" == "$directory" ]]; then
                abbrevs+="$fragment"
            fi
        done
        if [ ${#abbrevs[@]} -gt 0 ]; then
            local abbrevs_found=true
            # only report unique abbrevs
            (
                IFS=$'\n'
                echo "${abbrevs[*]}"
            ) | awk '!a[$0]++'

            if [ -z "$all" ]; then
                return
            fi
        fi
    done

    if [[ "$abbrevs_found" == true ]]; then
        return
    fi

    echo "No abbreviation found for $(basename "${directory}")" 1>&2
    return 1
}

_zabb_help() {
    echo 'Find the shortest abbreviations that can be used to autojump (a.k.a. "z") to the given (or current) directory'
    echo
    echo "By default, only abbreviations that start the same way as the directory name are returned."
    echo "Non-contiguous, i.e. space separated, abbreviations are not looked for. So, in some fairly rare circumstances the shortest abbreviations may not be found."
    _zabb_usage
}

_zabb_usage() {
    echo
    echo "USAGE:"
    echo "  zabb [<DIRECTORY>]"
    echo
    echo "ARGS:"
    echo "  <DIRECTORY>"
    echo "      Directory to find z abbrevs for. If none is given, it defaults to current working directory"
    echo
    echo "FLAGS:"
    echo "  -s  Allow abbreviations even if they do not start the same way as the directory name. (This will often find shorter abbreviations, but they may be less easy to remember)"
    echo "  -a  List all (contiguous) abbreviations (implies -s)"
    echo "  -h  Print help"
}

zabb() {
    local z_command=zoxide
    if [ ! -x "$(command -v "$z_command")" ]; then
        echo ""$0" only works if you have \""$z_command"\" installed to implement the \"z\" autojump command" 1>&2
        return 1
    fi
    local z_query=""$z_command" query"

    while getopts "sadh" opt; do
        case $opt in
        s) local shortest=1 ;;
        a) local all=1 ;;
        d) local debug=1 ;;
        h)
            _zabb_help
            return
            ;;
        *)
            _zabb_usage
            return 2
            ;;
        esac
    done
    shift $((OPTIND - 1))

    local directory
    if [ -z "$*" ]; then
        directory=$(realpath "$PWD")
    else
        directory=$(realpath "$*")
        if [ ! -d "$directory" ]; then
            echo "$directory is not a valid, existing directory" 1>&2
            return 3
        fi
    fi

    _zabb_find_abbrevs "$directory"
}
