import os
import shutil
import subprocess
import sys


def run_command(command, description):
    """
    Runs a command in the shell, streams its output, and checks for errors.
    """
    print(f"--- {description} ---")
    try:
        # Using shell=True because npm on Windows is often a .cmd file
        # and this is generally easier for cross-platform compatibility.
        process = subprocess.Popen(
            command,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            shell=True,
        )

        if process.stdout is None:
            raise ValueError("process.stdout is None")

        # Stream output in real-time
        for line in iter(process.stdout.readline, ""):
            sys.stdout.write(line)

        process.stdout.close()
        return_code = process.wait()

        if return_code:
            raise subprocess.CalledProcessError(return_code, command)

        print(f"--- Successfully completed: {description} ---\n")
        return True
    except FileNotFoundError:
        print(
            f"Error: Command '{command[0]}' not found. Please ensure it is installed and in your system's PATH."
        )
        return False
    except subprocess.CalledProcessError as e:
        print(f"Error during: {description}.")
        print(f"Command '{e.cmd}' returned non-zero exit status {e.returncode}.")
        return False
    except Exception as e:
        print(f"An unexpected error occurred: {e}")
        return False


def install_mermaid_cli():
    """
    Installs the Mermaid CLI tool globally using npm if it's not already installed.
    """
    if shutil.which("mmdc"):
        print("Mermaid CLI (mmdc) is already installed. Skipping installation.\n")
        return True

    print("Mermaid CLI (mmdc) not found. Attempting to install globally via npm...")
    install_command = "npm install -g @mermaid-js/mermaid-cli"
    return run_command(install_command, "Install @mermaid-js/mermaid-cli")


def render_diagram():
    """
    Renders the ERD diagram from 'erd.mmd' to 'erd.png'.
    """
    input_file = "erd.mmd"
    output_file = "erd.png"

    if not os.path.exists(input_file):
        print(f"Error: Input file '{input_file}' not found in the current directory.")
        print(
            "Please ensure the 'erd.mmd' file exists and contains your Mermaid diagram syntax."
        )
        return False

    render_command = f"mmdc -i {input_file} -o {output_file}"
    return run_command(render_command, f"Render '{input_file}' to '{output_file}'")


def main():
    """
    Main function to orchestrate the installation and rendering process.
    """
    print("Starting ERD diagram rendering script.")
    print("=" * 40 + "\n")

    if not install_mermaid_cli():
        print("\n" + "=" * 40)
        print(
            "Failed to install Mermaid CLI. Please ensure Node.js and npm are installed and accessible in your PATH."
        )
        sys.exit(1)

    if not render_diagram():
        print("\n" + "=" * 40)
        print("Failed to render the ERD diagram.")
        sys.exit(1)

    print("=" * 40)
    print("Script finished successfully. Your diagram is available at 'erd.png'.")


if __name__ == "__main__":
    main()
