#!/bin/bash
#将规范化后的命令行参数分配至位置参数（$1,$2,...)
temp=`getopt -n $0 -o ut:r:p:: -l help,tlong:,long-t1:,long-t2:: -- "$@"`

[ $? != 0 ] && { 
    echo 'Try '$0 '--help for more information.'
    exit 1
    }
set -- $temp



while true;do
    case "$1" in
        -u) 
            echo '-u has be used';
            shift
            ;;
        -r)
            echo '-r has be used with:' $2;
            shift 2
            ;;
        -p)
            case "$2" in
                "")
                    echo '-p has be used without arg'
                    shift 2
                    ;;
                *)
                    echo '-p has be used with:' $2
                    shift 2
                    ;;
            esac
            ;;
        -t|--tlong)
            echo '-t or --tlong has be used with: ' $2
            shift 2
            ;;
        --help)
            #help_function_msg
            echo 'some information about how to usage'
            shift 1
            ;;
        --long-t1)
            echo '--long-t1 has be used with: ' $2
            shift 2
            ;;
        --long-t2)
            case "$2" in
                "")
                    echo '--long-t2 has be used without arg'
                    ;;
                *)
                    echo '--long-t2 has be used with:' $2
                    shift 2
                    ;;
            esac
            ;;
		--)
            shift
            break
            ;;
        *)
            echo "Internal error!"
            exit 1
            ;;
    esac
done
