import typer
import subprocess
from pathlib import Path

app = typer.Typer()
ROOT = Path(__file__).parent.parent

@app.command()
def seed():
    """Apply SQL seeds from supabase/seed.sql"""
    sql_file = ROOT / "supabase" / "seed.sql"
    if not sql_file.exists():
        typer.echo("❌ No seed.sql found")
        raise typer.Exit(1)
    subprocess.run(["supabase", "db", "query", str(sql_file)], check=True)
    typer.echo("✅ Database seeded")

@app.command()
def open():
    """Open local PostgREST API explorer"""
    typer.launch("http://localhost:54323")

@app.command()
def lint():
    """Lint SQL migrations with sqlfluff"""
    subprocess.run(["sqlfluff", "lint", "supabase/migrations"])

if __name__ == "__main__":
    app()
