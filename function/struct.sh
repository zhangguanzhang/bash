#!/bin/bash

_INTERNED_SYMBOLS=()

_symbol_lookup()
{
    local symbol=$1
    local offset
    for (( offset = 0; offset < ${#_INTERNED_SYMBOLS[*]}; ++offset )); do
    if [ z${_INTERNED_SYMBOLS[${offset}]} == z${symbol} ]; then
        return ${offset}
    fi
    done
    return 255
}

_symbol_intern()
{
    local symbol=$1

    _symbol_lookup ${symbol}
    local intern_id=$?

    if [ ${intern_id} -ne 255 ]; then
    return ${intern_id}
    fi

    local offset=${#_INTERNED_SYMBOLS[*]}
    _INTERNED_SYMBOLS[${offset}]=${symbol}
    return ${offset}
}

_struct_get()
{
    local slot_sym=$2
    local inst=${slot_sym}_$1
    local slot_id=$(_symbol_lookup ${slot_sym}; echo $?)

    eval echo \${${inst}[${slot_id}]}
}

_struct_set()
{
    local slot_sym=$2
    local inst=${slot_sym}_$1
    local value=$3
    local slot_id=$(_symbol_lookup ${slot_sym}; echo $?)

    eval ${inst}[${slot_id}]=${value}
}

_defsetter()
{
    local struct=$1
    local sym_name=$2

    eval "${struct}_${sym_name}_set() { _struct_set \$1 ${sym_name} \$2; }"
}

_defgetter()
{
    local struct=$1
    local sym_name=$2

    eval "${struct}_${sym_name}_get() { _struct_get \$1 ${sym_name}; }"
}

defstruct()
{
    local struct_name=$1
    shift
    local slots="$@"

    local sym
    for sym in ${slots}; do
        _symbol_intern ${sym}
        _defsetter ${struct_name} ${sym}
        _defgetter ${struct_name} ${sym}
    done
}
