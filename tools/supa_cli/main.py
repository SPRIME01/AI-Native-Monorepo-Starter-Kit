import subprocess
import sys

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
    run_command("supabase start")

def supa_down():
    print("Stopping Supabase local development...")
    run_command("supabase stop")

def supa_reset():
    print("Resetting Supabase database...")
    run_command("supabase db reset")

def supa_seed():
    print("Seeding Supabase via CLI wrapper...")
    # This assumes a seed.sql or similar is handled by supabase db reset
    # For more complex seeding, you might add specific logic here
    run_command("supabase db reset --data-only")

def supa_types():
    print("Generating TypeScript types from Supabase...")
    run_command("supabase gen types typescript --local > supabase/types/supabase.ts")

def supa_status():
    print("Checking Supabase status...")
    run_command("supabase status")

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
