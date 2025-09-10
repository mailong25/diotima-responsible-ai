import os
import json
from collections import defaultdict
HELM_OUT_DIR = 'benchmark_output/runs/test/'
HALU_OUT_DIR = 'long-form-factuality/results/'

## READ results from HELM dataset
label_tags = ['quasi_exact_match', 'chain_of_thought_correctness', 'ifeval_strict_accuracy',
              'exact_match', 'toxic_frac', 'safety_score']
test_names = ['simple_safety_tests', 'gpqa', 'mmlu', 'ifeval', 'bbq', 'real_toxicity_prompts']

predictions = {}
for test in test_names:
    predictions[test] = defaultdict(list)

tests = [path for path in os.listdir(HELM_OUT_DIR) if ':' in path]

for test in tests:
    test_name = test.split(':')[0]
    model_name = test.split('model=')[1]
    file_path = HELM_OUT_DIR + test + '/display_predictions.json'
    data = json.load(open(file_path))
    for sample in data:
        label_tag = [label for label in label_tags if label in sample['stats']][0]
        pred = sample['stats'][label_tag]
        predictions[test_name][model_name].append(pred)

for test_name in predictions:
    models = predictions[test_name].keys()
    for model in models:
        predictions[test_name][model] = round(sum(predictions[test_name][model]) / len(predictions[test_name][model]), 4)
    predictions[test_name] = dict(predictions[test_name])

## READ results from longfact dataset
predictions['Halu'] = {}
file_paths = [path for path in os.listdir(HALU_OUT_DIR) if '-SAFE' in path]

for path in file_paths:
    data = json.load(open(os.path.join(HALU_OUT_DIR, path)))
    model_name = path.split('-SAFE')[0]
    num_claims, not_support = 0, 0 
    
    for sample in data['per_prompt_data']:
        num_claims  += sample['side2_posthoc_eval_data']['num_claims']
        not_support += sample['side2_posthoc_eval_data']['Not Supported']

    halu_rate = round(not_support / num_claims, 4)
    predictions['Halu'][model_name] = halu_rate

#### DISPLAY THE RESULTS IN TERMINAL
import pandas as pd
df = pd.DataFrame.from_dict({k: v for k, v in predictions.items()}, orient='columns')
df = df.sort_index()
output_str = df.to_string(float_format=lambda x: f"{x:.4f}" if isinstance(x, float) else str(x))
print(output_str)
with open('results.txt', 'w') as f:
    f.write(output_str)
####
