#!/bin/bash

# 设置 MAX_DELAY 和 MIN_DELAY 的范围和步长
MAX_DELAY_MIN=3.0    # MAX_DELAY 的最小值
MAX_DELAY_MAX=6.0   # MAX_DELAY 的最大值
MAX_DELAY_STEP=0.2   # MAX_DELAY 的步长

MIN_DELAY_MIN=0.0    # MIN_DELAY 的最小值
MIN_DELAY_STEP=0.5   # MIN_DELAY 的步长

# 遍历 MAX_DELAY
for MAX_DELAY in $(seq $MAX_DELAY_MIN $MAX_DELAY_STEP $MAX_DELAY_MAX); do
    # 动态计算当前 MAX_DELAY 下 MIN_DELAY 的最大值
    CURRENT_MIN_DELAY_MAX=$(echo "$MAX_DELAY - 1.5" | bc -l)

    # 确保 MIN_DELAY 最大值不小于 MIN_DELAY 最小值
    if (( $(echo "$CURRENT_MIN_DELAY_MAX >= $MIN_DELAY_MIN" | bc -l) )); then
        for MIN_DELAY in $(seq $MIN_DELAY_MIN $MIN_DELAY_STEP $CURRENT_MIN_DELAY_MAX); do
            # 检查 MIN_DELAY 是否小于等于 MAX_DELAY
            if (( $(echo "$MIN_DELAY < $MAX_DELAY" | bc -l) )); then
                # 创建目录
                DIR_NAME="mult_${MAX_DELAY}_${MIN_DELAY}"
                mkdir -p "$DIR_NAME"
                MAX_DELAY="$MAX_DELAY" MIN_DELAY="$MIN_DELAY" dc_shell-t -f synth.tcl
            fi
        done
    fi
done
