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

To start the evolution loop:

```bash
python -m snackPersona.main --generations 5 --population 10
```

-   `--generations`: Number of evolutionary generations to run.
-   `--population`: Number of agents per generation.

The simulation will output logs and save generation data to `persona_data/`.

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
