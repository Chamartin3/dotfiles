#!/bin/zsh

# zsh:perf - Measure zsh startup time broken down by component
#
# Usage:
#   zsh:perf            Component-level timing (configs, tools, plugins)
#   zsh:perf --zprof    Function-level profiling via zsh/zprof
#   zsh:perf --total    Just total startup time (average of 5 runs)

function zsh:perf() {
    local mode="${1:-components}"
    local LC_NUMERIC=C

    case "$mode" in
        --zprof)
            ZDOTDIR="$HOME" zsh -i -c '
                zmodload zsh/zprof
                source ~/.zshrc
                zprof
            ' 2>/dev/null
            ;;
        --total)
            echo "Averaging 5 runs..."
            local total=0
            for i in {1..5}; do
                local t=$({ TIMEFMT="%E"; time zsh -i -c exit } 2>&1 | tail -1 | tr ',' '.')
                total=$(echo "$total + $t" | bc)
            done
            local avg=$(echo "scale=3; $total / 5" | bc)
            echo "Average startup: ${avg}s"
            ;;
        --help)
            echo "Usage: zsh:perf [--zprof|--total|--help]"
            echo ""
            echo "  (default)   Component-level timing by sourced file"
            echo "  --zprof     Function-level profiling (zsh/zprof)"
            echo "  --total     Average total startup time (5 runs)"
            ;;
        *)
            local results="/tmp/zsh-profile-$$.tsv"
            LC_NUMERIC=C ZSH_PROFILE=1 ZSH_PROFILE_OUT="$results" zsh -i -c exit 2>/dev/null

            if [[ ! -f "$results" ]]; then
                echo "Profiling failed — no results generated." >&2
                return 1
            fi

            # Header
            printf "\n  %-10s  %-40s  %-10s\n" "Time (ms)" "Component" "Category"
            printf "  %-10s  %-40s  %-10s\n" "─────────" "────────────────────────────────────────" "────────"

            # Print sorted results and accumulate total
            local total=0
            while IFS=$'\t' read -r ms component category; do
                total=$(( total + ${ms%.*} ))
                local bar_len=$(( ${ms%.*} / 10 ))
                (( bar_len > 40 )) && bar_len=40
                local bar="${(l:$bar_len::█:)}"
                printf "  %7.1f ms  %-40s  %-10s  %s\n" "$ms" "$component" "$category" "$bar"
            done < "$results"

            printf "\n  Total: %d ms\n\n" "$total"
            rm -f "$results"
            ;;
    esac
}
