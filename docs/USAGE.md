# Usage Guide

## Prerequisites

-   Python 3.10+
-   A valid API Key for Google Gemini (or another supported LLM backend).

## Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/yourusername/snackPersona.git
    cd snackPersona
    ```

2.  **Create a virtual environment (recommended):**
    ```bash
    python3 -m venv venv
    source venv/bin/activate
    ```

3.  **Install dependencies:**
    ```bash
    pip install -r requirements.txt
    ```

## Configuration

1.  **Set up your API Key:**
    You must set the `GEMINI_API_KEY` environment variable.
    ```bash
    export GEMINI_API_KEY="AIzaSy..."
    ```

2.  **Adjust Simulation Parameters (Optional):**
    You can modify `snackPersona/orchestrator/engine.py` to change mutation rates or fitness weights.
    Seeds are located in `snackPersona/config/seed_personas.json`.

## Running the Simulation

Set required runtime environment variables first:

```bash
export GEMINI_API_KEY="AIzaSy..."
export GOOGLE_CSE_API_KEY="..."
export GOOGLE_CSE_CX="..."
export AWS_ENDPOINT_URL=http://localstack:4566
export AWS_REGION=us-east-1
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export DYNAMODB_TABLE=SnackTable
export PYTHONPATH=apps/persona/src
```

Then start the evolution loop:

```bash
python3 -m snackpersona.main --generations 4 --pop_size 4
```

- `--generations`: Number of evolutionary generations to run.
- `--pop_size`: Number of agents per generation.

At startup, the app now verifies:

- Gemini API key presence (for Gemini presets)
- Google Custom Search JSON API config presence (`GOOGLE_CSE_API_KEY`, `GOOGLE_CSE_CX`)
- DynamoDB endpoint reachability and table availability
- Web search/crawl connectivity
- LLM connectivity

## Verification Scripts

We provide scripts to verify individual components:

1.  **Verify Persona -> Traveler Integration**:
    Checks if a Bio is correctly translated into search parameters.
    ```bash
    python verify_integration.py
    ```

2.  **Verify Bio Evaluation**:
    Checks if the `BioStyleEvaluator` can distinguish between "Story" and "Resume" styles.
    ```bash
    python verify_bio_eval.py
    ```

3.  **Verify Traveler Fitness**:
    Checks the calculation of `Uniqueness` and other fitness metrics.
    ```bash
    python verify_traveler_fitness.py
    ```

## Analyzing Results

After a run, check the `persona_data/{timestamp}/` directory for:
-   `gen_X_fitness.json`: Fitness scores for each generation.
-   `transcripts/`: Logs of social interactions.
