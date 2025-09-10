#!/bin/bash

# ===============================
#  Run Benchmark
# ===============================

# Check if model argument is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <EVAL_MODEL>"
  exit 1
fi

# Set evaluation instance limit and model
export MAX_EVAL_INSTANCES=100
export MAX_EVAL_INSTANCES_HALU=20
export SUITE_NAME="test"
export EVAL_MODEL="$1"
export HALU_FACTCHECK_MODEL="openai/gpt-4.1-mini"

# ===============================
# Subject Knowledge Test
# ===============================

echo "Running GPQA..."
helm-run --run-entries gpqa:subset=gpqa_main,model=$EVAL_MODEL --suite $SUITE_NAME --max-eval-instances $MAX_EVAL_INSTANCES

echo "Running MMLU - High School Biology..."
helm-run --run-entries mmlu:subject=high_school_biology,model=$EVAL_MODEL --suite $SUITE_NAME --max-eval-instances $((MAX_EVAL_INSTANCES/5))

echo "Running MMLU - Abstract Algebra..."
helm-run --run-entries mmlu:subject=abstract_algebra,model=$EVAL_MODEL --suite $SUITE_NAME --max-eval-instances $((MAX_EVAL_INSTANCES/5))

echo "Running MMLU - College Chemistry..."
helm-run --run-entries mmlu:subject=college_chemistry,model=$EVAL_MODEL --suite $SUITE_NAME --max-eval-instances $((MAX_EVAL_INSTANCES/5))

echo "Running MMLU - Computer Security..."
helm-run --run-entries mmlu:subject=computer_security,model=$EVAL_MODEL --suite $SUITE_NAME --max-eval-instances $((MAX_EVAL_INSTANCES/5))

echo "Running MMLU - Econometrics..."
helm-run --run-entries mmlu:subject=econometrics,model=$EVAL_MODEL --suite $SUITE_NAME --max-eval-instances $((MAX_EVAL_INSTANCES/5))

# ===============================
# Safety Test
# ===============================

echo "Running Simple Safety Tests..."
helm-run --run-entries simple_safety_tests:model=$EVAL_MODEL --suite $SUITE_NAME --max-eval-instances $MAX_EVAL_INSTANCES

# ===============================
# Instruction Following Test
# ===============================

echo "Running Instruction Following Evaluation..."
helm-run --run-entries ifeval:model=$EVAL_MODEL --suite $SUITE_NAME --max-eval-instances $MAX_EVAL_INSTANCES

# ===============================
# Bias/Fairness Test
# ===============================

echo "Running BBQ (Bias/Fairness) Evaluation..."
helm-run --run-entries bbq:subject=all,model=$EVAL_MODEL --suite $SUITE_NAME --max-eval-instances $MAX_EVAL_INSTANCES

# ===============================
# Toxicity Test
# ===============================

echo "Running Real Toxicity Prompts..."
helm-run --run-entries real_toxicity_prompts:model=$EVAL_MODEL --suite $SUITE_NAME --max-eval-instances $MAX_EVAL_INSTANCES -n 1

### Summarize
helm-summarize --suite $SUITE_NAME

# # # ===============================
# # # Hallucination Test
# # # ===============================

echo "Running Hallucination Test..."
cd long-form-factuality
export GEN_MODEL="$EVAL_MODEL"
python -m main.pipeline
export GEN_MODEL="$HALU_FACTCHECK_MODEL"
python -m eval.run_eval --result_path="results/$(echo "$EVAL_MODEL" | sed 's|/|_|g').json" --eval_side1=False --eval_side2=True --parallelize=True --max_claim=-1
cd ..

echo "All evaluations done!"