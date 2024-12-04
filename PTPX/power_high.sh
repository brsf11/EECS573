#!/bin/bash

# 设置 MAX_DELAY 和 MIN_DELAY 的范围和步长
MAX_DELAY_MIN=6.0    # MAX_DELAY 的最小值
MAX_DELAY_MAX=16.0   # MAX_DELAY 的最大值
MAX_DELAY_STEP=1.0   # MAX_DELAY 的步长

MIN_DELAY_MIN=1.0    # MIN_DELAY 的最小值
MIN_DELAY_STEP=1.0   # MIN_DELAY 的步长

# 遍历 MAX_DELAY
for MAX_DELAY in $(seq $MAX_DELAY_MIN $MAX_DELAY_STEP $MAX_DELAY_MAX); do
    # 动态计算当前 MAX_DELAY 下 MIN_DELAY 的最大值
    CURRENT_MIN_DELAY_MAX=$(echo "($MAX_DELAY / 2) - 1.0" | bc -l)

    # 确保 MIN_DELAY 最大值不小于 MIN_DELAY 最小值
    if (( $(echo "$CURRENT_MIN_DELAY_MAX >= $MIN_DELAY_MIN" | bc -l) )); then
        for MIN_DELAY in $(seq $MIN_DELAY_MIN $MIN_DELAY_STEP $CURRENT_MIN_DELAY_MAX); do
            # 检查 MIN_DELAY 是否小于等于 MAX_DELAY
            if (( $(echo "$MIN_DELAY < $MAX_DELAY" | bc -l) )); then
                # 创建目录
                DIR_NAME="mult_${MAX_DELAY}_${MIN_DELAY}"
                mkdir -p "$DIR_NAME"
                cd ..
                make nuke
                make syn MAX_DELAY=${MAX_DELAY} MIN_DELAY=${MIN_DELAY}
                # MAX_DELAY="$MAX_DELAY" MIN_DELAY="$MIN_DELAY" dc_shell-t -f synth.tcl
                cp feed.txt compare.txt syn.out synth/mult.rep PTPX/mult_${MAX_DELAY}_${MIN_DELAY}
                cd PTPX
                make clean
                make pp
                mv *.rpt mult_${MAX_DELAY}_${MIN_DELAY}
            fi
        done
    fi
done
