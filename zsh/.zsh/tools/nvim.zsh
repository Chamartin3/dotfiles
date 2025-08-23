#!/bin/zsh

function nvim:plugins() {
    # List all installed plugins with their directories and URLs

    local all_plugins=$(nvim --headless -c "lua for _, p in pairs(require('lazy').plugins()) do print(p.name .. ' - ' .. p.dir .. ' - ' .. p.url) end" +q 2>&1)

    echo "$all_plugins" | awk -F' - ' '{print $1 " \t " $2 "  \t " $3}' | fzf --delimiter '\t' --with-nth=1 --preview 'echo "URL: {3}\n\n"; cat {2}/README.md echo "No README.md found"'
}
