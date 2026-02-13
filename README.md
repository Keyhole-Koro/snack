# SnackPersona

**SnackPersona** is an advanced evolution simulation where AI agents develop distinct personalities, search habits, and social behaviors.

It explores the interplay between **Identity (Who)**, **Discovery (What)**, and **Action (How)**.

## Core Features

### 1. Bio-Driven Identity
Agents are not defined by static attribute lists. They possess **Rich Story Bios**—first-person narratives that drive every decision.
-   *Mutation*: Bios evolve naturally using an LLM to rewrite life stories (e.g., a "burned-out lawyer" mutates into a "cynical legal consultant").
-   *Authenticity*: The system penalizes "resume-speak" and rewards messy, human-like narratives.

### 2. "Moto-mo-ko-mo-nai" (Bluntness & Silence)
Agents are designed to be incisive, not polite.
-   **Bluntness**: Evaluations reward agents who cut to the chase and make decisive, conversation-stopping statements (whether brutally honest or confidently false).
-   **Silence**: Agents can choose to `PASS` (stay silent) if a topic doesn't interest them. "Judiciousness" is a key fitness metric.

### 3. Persona-Driven Discovery (Traveler)
Discovery behavior is a direct function of personality.
-   A **Conspiracy Theorist** bias searches towards blogs and forums.
-   A **Scientist** bias searches towards `.edu` and `.gov` sites.
-   **Uniqueness**: Agents are rewarded for finding content that *no one else* in the population has found, encouraging the emergence of distinct subcultures.

### 4. Evolutionary Optimization
The system breeds agents based on:
-   **Social Success**: Engagement, Authenticity, Incisiveness.
-   **Discovery Success**: Uniqueness of information found.

## Project Structure

The project is now a single monolithic package `snackPersona`:

-   **`snackPersona/simulation`**: The social feed environment.
-   **`snackPersona/orchestrator`**: The evolutionary engine (Selection, Mutation, Crossover).
-   **`snackPersona/traveler`**: The information retrieval subsystem.
-   **`snackPersona/llm`**: Unified LLM infrastructure (Gemini, etc.).

## Quick Start

1.  **Install**:
    ```bash
    pip install -r requirements.txt
    ```

2.  **Configure**:
    ```bash
    export GEMINI_API_KEY="your_api_key"
    ```

3.  **Run**:
    ```bash
    python -m snackPersona.main --generations 5 --population 10
    ```

See [USAGE.md](USAGE.md) for detailed configuration options.
See [ARCHITECTURE.md](ARCHITECTURE.md) for system design diagrams.
