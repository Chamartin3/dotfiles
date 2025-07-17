function set_ext_keyboard() {
    local picked_conf=$(gum choose $(ls "$EXT_KEYBOARD_CONFIGS" | grep "yaml"))
    local keyboard_configuration=$EXT_KEYBOARD_CONFIGS/$picked_conf
    eval "$EXT_KEYBOARD_TOOL validate < $keyboard_configuration" &&
        eval "$EXT_KEYBOARD_TOOL upload < $keyboard_configuration"
    echo "Setted $picked_conf"
    print_layout "$keyboard_configuration"
}
