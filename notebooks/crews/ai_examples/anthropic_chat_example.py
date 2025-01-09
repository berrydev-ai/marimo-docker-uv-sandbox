# /// script
# requires-python = ">=3.13"
# dependencies = [
#     "marimo",
#     "anthropic",
# ]
# ///


import marimo

__generated_with = "0.10.9"
app = marimo.App()


@app.cell
def _():
    import marimo as mo
    return (mo,)


@app.cell(hide_code=True)
def _():
    import subprocess
    import json


    def is_package_installed_uv(package_name: str) -> bool:
        try:
            # Run uv pip list with JSON format output
            result = subprocess.run(["uv", "pip", "list", "--format", "json"], capture_output=True, text=True)

            # Parse the JSON output
            packages = json.loads(result.stdout)

            # Check if package exists in the list
            return any(package["name"].lower() == package_name.lower() for package in packages)
        except subprocess.CalledProcessError:
            print("Error running uv pip list")
            return False
        except json.JSONDecodeError:
            print("Error parsing uv output")
            return False
    return is_package_installed_uv, json, subprocess


@app.cell
def _(mo):
    mo.md(
        r"""
        # Using Anthropic

        This example shows how to use [`mo.ui.chat`](https://docs.marimo.io/api/inputs/chat.html#marimo.ui.chat) to make a chatbot backed by Anthropic.
        """
    )
    return


@app.cell
def _(is_package_installed_uv, mo):
    if is_package_installed_uv("anthropic"):
        print("The 'anthropic' package has been installed.")
    else:
        print("You must first install the 'anthropic' package prior to running this notebook.")
        mo.md("You must first install the 'anthropic' package prior to running this notebook.")
        mo.stop
    return


@app.cell
def _(mo):
    import os

    os_key = os.environ.get("MARIMO_ANTHROPIC_API_KEY")
    input_key = mo.ui.text(label="Anthropic API key", kind="password")
    input_key if not os_key else None
    return input_key, os, os_key


@app.cell
def _(input_key, mo, os_key):
    key = os_key or input_key.value

    mo.stop(
        not key,
        mo.md("Please provide your Anthropic API key in the input field."),
    )
    return (key,)


@app.cell
def _(key, mo):
    chatbot = mo.ui.chat(
        mo.ai.llm.anthropic(
            "claude-3-5-sonnet-20240620",
            system_message="You are a helpful assistant.",
            api_key=key,
        ),
        allow_attachments=[
            "image/png",
            "image/jpeg",
        ],
        prompts=[
            "Hello",
            "How are you?",
            "I'm doing great, how about you?",
        ],
        max_height=400,
    )
    chatbot
    return (chatbot,)


@app.cell
def _(mo):
    mo.md("""Access the chatbot's historical messages with [`chatbot.value`](https://docs.marimo.io/api/inputs/chat.html#accessing-chat-history).""")
    return


@app.cell
def _(chatbot):
    chatbot.value
    return


if __name__ == "__main__":
    app.run()
