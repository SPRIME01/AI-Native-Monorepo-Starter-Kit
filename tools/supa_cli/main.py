import subprocess
import sys
import os

def run_command(command):
    try:
        result = subprocess.run(command, shell=True, check=True, capture_output=True, text=True)
        print(result.stdout)
        if result.stderr:
            print(result.stderr, file=sys.stderr)
    except subprocess.CalledProcessError as e:
        print(f"Error executing command: {e}", file=sys.stderr)
        print(f"Stdout: {e.stdout}", file=sys.stderr)
        print(f"Stderr: {e.stderr}", file=sys.stderr)
        sys.exit(e.returncode)

def supa_up():
    print("Starting Supabase local development...")
    original_dir = os.getcwd()
    os.chdir("supabase")
    run_command("supabase start")
    os.chdir(original_dir)

def supa_down():
    print("Stopping Supabase local development...")
    original_dir = os.getcwd()
    os.chdir("supabase")
    run_command("supabase stop")
    os.chdir(original_dir)

def supa_reset():
    print("Resetting Supabase database...")
    original_dir = os.getcwd()
    os.chdir("supabase")
    run_command("supabase db reset")
    os.chdir(original_dir)

def supa_seed():
    print("Seeding Supabase via CLI wrapper...")
    original_dir = os.getcwd()
    os.chdir("supabase")
    # This assumes a seed.sql or similar is handled by supabase db reset
    # For more complex seeding, you might add specific logic here
    run_command("supabase db reset --data-only")
    os.chdir(original_dir)

def supa_types():
    print("Generating TypeScript types from Supabase...")
    original_dir = os.getcwd()
    os.chdir("supabase")
    try:
        result = subprocess.run(
            ["supabase", "gen", "types", "typescript", "--local"],
            check=True,
            capture_output=True,
            text=True
        )
        os.makedirs("supabase/types", exist_ok=True)
        with open("supabase/types/supabase.ts", "w", encoding="utf-8") as f:
            f.write(result.stdout)
        if result.stderr:
            print(result.stderr, file=sys.stderr)
    except subprocess.CalledProcessError as e:
        print(f"Error executing command: {e}", file=sys.stderr)
        print(f"Stdout: {e.stdout}", file=sys.stderr)
        print(f"Stderr: {e.stderr}", file=sys.stderr)
    finally:
        os.chdir(original_dir)
    run_command("supabase gen types typescript --local > supabase/types/supabase.ts")
    os.chdir(original_dir)

def supa_status():
    print("Checking Supabase status...")
    original_dir = os.getcwd()
    os.chdir("supabase")
    run_command("supabase status")
    os.chdir(original_dir)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python main.py [up|down|reset|seed|types|status]", file=sys.stderr)
        sys.exit(1)

    command = sys.argv[1]
    if command == "up":
        supa_up()
    elif command == "down":
        supa_down()
    elif command == "reset":
        supa_reset()
    elif command == "seed":
        supa_seed()
    elif command == "types":
        supa_types()
    elif command == "status":
        supa_status()
    else:
        print(f"Unknown command: {command}", file=sys.stderr)
        sys.exit(1)
