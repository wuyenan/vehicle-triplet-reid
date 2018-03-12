#!/bin/sh
#
# This file calls train.py with all hyperparameters as for the TriNet
# experiment on market1501 in the original paper.

# Shift the arguments so that we can just forward the remainder.
export CUDA_VISIBLE_DEVICES=6

source ../triplet-reid-rl-attention/venv/bin/activate

METRIC='euclidean'
HEADS='fc1024_inception_multi-residual-head_attention_5_branch'
BACKBONE='inception'
HIDDEN_UNITS=256
EXPR_NAME='_ft_rl_'${HIDDEN_UNITS}'_multi-head_1'
INIT_CHECKPT='./experiments/pku-vd/ckpt_multi-residual-head_5-branch/checkpoint-340000' ; shift
# INIT_CHECKPT=./experiments/pku-vd/ckpt_inception_mixed_attention/checkpoint-240000 ; shift
# INIT_CHECKPT=./experiments/pku-vd/ckpt_inception_v4/checkpoint-285886 ; shift

EXP_ROOT=./experiments/pku-vd/expr_attention_${METRIC}_${HEADS}_${BACKBONE}${EXPR_NAME} ; shift
IMAGE_ROOT=/data2/wangq/VD1/ ; shift

python train_rl_5_branch.py \
    --train_set data/pku-vd/VD1_train.csv \
    --model_name ${BACKBONE} \
    --image_root $IMAGE_ROOT \
    --initial_checkpoint $INIT_CHECKPT \
    --experiment_root $EXP_ROOT \
    --flip_augment \
    --crop_augment \
    --detailed_logs \
    --embedding_dim 128 \
    --batch_p 18 \
    --batch_k 5 \
    --pre_crop_height 300 --pre_crop_width 300 \
    --net_input_height 224 --net_input_width 224 \
    --margin soft \
    --metric ${METRIC} \
    --loss batch_hard \
    --checkpoint_frequency 1000 \
    --head_name ${HEADS} \
    --learning_rate 1e-5 \
    --train_iterations 60000 \
    --decay_start_iteration 0 \
    --lr_decay_factor 0.96 \
    --lr_decay_steps 500 \
    --weight_decay_factor 0.0002 \
    --rl_learning_rate 1e-2 \
    --rl_epsilon 0.6 \
    --rl_epsilon_decay 0.1 \
    --rl_activation sigmoid \
    --rl_sample_num 12 \
    --rl_hidden_units ${HIDDEN_UNITS} \
    --rl_baseline mean-std \
    "$@"
    # --resume \
