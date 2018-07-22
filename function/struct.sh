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
    local inst=$1
    local slot_sym=$2
    local slot_id=$(_symbol_lookup ${slot_sym}; echo $?)

    eval echo \${${inst}[${slot_id}]}
}

_struct_set()
{
    local inst=$1
    local slot_sym=$2
    local value=$3
    local slot_id=$(_symbol_lookup ${slot_sym}; echo $?)

    eval ${inst}[${slot_id}]=${value}
}

_defsetter()
{
    local struct=$1
    local sym_name=$2

    eval "${struct}_${sym_name}_set() { _struct_set ${struct}_\$1 ${sym_name} \$2; }"
}

_defgetter()
{
    local struct=$1
    local sym_name=$2

    eval "${struct}_${sym_name}_get() { _struct_get ${struct}_\$1 ${sym_name}; }"
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


shell实现结构体定义和获取值
参考
https://gist.github.com/rayfill/3523717
但是作者39行代码有问题,加了转义斜线后正常
```bash
[root@k8s-n1 ~]# source test.shell 
[root@k8s-n1 ~]# defstruct human age sex
[root@k8s-n1 ~]# human_age_set guan 22
[root@k8s-n1 ~]# human_age_set boss 36
[root@k8s-n1 ~]# human_age_get guan
22
[root@k8s-n1 ~]# human_sex_set guan man
[root@k8s-n1 ~]# human_sex_get guan 
man
```
修改好后突然想起来底层是关联型数组实现的,所以还发现存在下面问题
```bash
[root@k8s-n1 ~]# defstruct human age sex
[root@k8s-n1 ~]# human_age_set guan 22
[root@k8s-n1 ~]# defstruct cat age sex
[root@k8s-n1 ~]# cat_age_get guan
22
```
于是修改了57和65行
```bash
[root@k8s-n1 ~]# defstruct human age sex
[root@k8s-n1 ~]# human_age_set guan 22
[root@k8s-n1 ~]# defstruct cat age sex
[root@k8s-n1 ~]# cat_age_get guan

```
