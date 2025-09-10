# diotima-responsible-ai
The repository is for the Diotima project on responsible AI, including various responsible AI tests.


## 🚀 Installation
Clone the repositories:

```bash
git clone https://github.com/mailong25/long-form-factuality.git
git clone https://github.com/mailong25/helm.git
```

Install dependencies:

```bash
cd helm
pip install -e .
pip install -r requirements_extra.txt
cd ..
```

---

## 🔑 Environment Setup

Set the required API keys before running evaluations.

### Mandatory API Keys
```bash
export OPENAI_API_KEY="your_openai_api_key"
export SERPER_API_KEY="your_serper_api_key"
export PERSPECTIVE_API_KEY="your_perspective_api_key"
```

### Optional API Keys
(only needed if you want to test additional providers)
```bash
export GEMINI_API_KEY="your_gemini_api_key"
export MISTRAL_API_KEY="your_mistral_api_key"
export XAI_API_KEY="your_xai_api_key"
```

> ✅ Currently supported providers: **openai, xai, gemini, mistral**  
> To add new providers, modify:  
> `helm/clients/custom_client.py`

---

## 🤝 Hugging Face Authentication

Datasets are pulled from Hugging Face. Log in with:

```bash
huggingface-cli login
```

---

## ⚙️ Running Evaluations

Edit `full_eval.sh` if you want to customize evaluation parameters.

Run the full evaluation for a model:

```bash
sh full_eval.sh openai/gpt-4.1-mini
```

### Example Models
```bash
sh full_eval.sh xai/grok-3-mini
sh full_eval.sh gemini/gemini-flash-2.5
sh full_eval.sh mistral/mistral-medium-latest
```

---

## 📊 Summarizing Results

After running an evaluation, summarize results with:

```bash
python summarize_result.py --helm_out_dir benchmark_output/runs/test/ --halu_out_dir long-form-factuality/results/ --output_file results.txt
```

---
