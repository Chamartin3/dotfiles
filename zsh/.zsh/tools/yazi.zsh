
function yy() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp"
	local cwd="$(cat -- "$tmp")"
	if [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
	  builtin cd -- "$cwd" || exit
	fi
	rm -f -- "$tmp"
}
