# AI-Native Monorepo Starter Kit

## 🚀 Overview

This repository provides a robust, pre-configured Nx monorepo designed for building AI-native applications with a polyglot stack. It's tailored for individual developers or small teams seeking high productivity, automation, and a "batteries-included" experience without the usual configuration headaches.

We've integrated a modern Python toolchain (uv, ruff, mypy, pytest, pyenv) and orchestrated it seamlessly with Nx for a streamlined developer workflow, automated CI/CD, and simplified microservices transformation. This setup minimizes "fuss" so you can focus on building your core AI products.

## ✨ Features

- **Nx Monorepo**: Centralized codebase for React frontends, Python backends, and infrastructure-as-code.
- **Python Toolchain**:
  - **uv**: Blazing-fast dependency management and virtual environment orchestration.
  - **ruff**: High-performance Python linter and formatter.
  - **mypy** (or Pyre): Strict static type checking for Python.
  - **pytest**: Robust testing framework with coverage.
  - **pyenv**: Seamless Python version management.
- **Automated Setup**: A single `just setup` command orchestrates environment bootstrapping, Nx plugin generation, and pre-commit hook installation, with core logic now implemented in Python for cross-platform reliability.
- **Simplified Project Generation**: Use `just app` and `just lib` for instantly configured Python applications and libraries.
- **Intelligent Task Execution**: Leverages Nx's affected commands for fast, incremental linting, testing, and building across your monorepo.
- **Pre-commit Hooks**: Enforces code quality locally before commits, preventing CI failures.
- **CI/CD Ready**: Designed for straightforward integration with platforms like GitHub Actions.
- **IaC Integration**: High-level `just` commands for orchestrating Terraform, Pulumi, and Ansible within the monorepo.
- **Microservice Transformation**: Simplified `just containerize` command to build Docker images for any application.

## 🛠️ Prerequisites

Before you clone and conquer, ensure you have these essentials installed:

- **Git**: Version control is fundamental.
- **Node.js & pnpm**: Node.js LTS (e.g., v20) and pnpm (install via `npm install -g pnpm`).
- **Pyenv**: Follow the official installation guide: https://github.com/pyenv/pyenv#installation. Crucially, add pyenv initialization to your shell's config (`.bashrc`, `.zshrc`, etc.) and restart your terminal.
- **Just**: Install the Just command runner:
  ```bash
  # Ubuntu/Debian
  sudo snap install just

  # macOS
  brew install just

  # Windows
  choco install just
  ```

## 🚀 Getting Started

Follow these steps to get your AI-Native Monorepo up and running:

### 📋 Step 1: Create Your New Project

Clone this project template:

```bash
git clone https://github.com/SPRIME01/AI-Native-Monorepo-Starter-Kit.git <new_project_directory_name>
```

This pulls down the template and initializes it as a Git repository, still linked to the original.

Navigate into the New Project Directory:

```bash
cd <new_project_directory_name>
```

Delete the `.git` Folder:

This step is crucial to break the link with the original template repository, allowing you to start fresh with your own project history.

If you're on macOS/Linux, run:

```bash
rm -rf .git
```

If you're on Windows, use PowerShell:

```powershell
Remove-Item -Recurse -Force .git
```

Your project is now just a plain directory with files, no longer a Git repository. This is where your new, independent project truly begins.

Initialize a New Git Repository:

```bash
git init
```

Now, Git sees this as a brand new, empty repository. No history, no remote connections yet.

Add Your Files to the New Repository:

```bash
git add .
```

This stages all your template files (which are now your new project's files) for the first commit.

Make Your Initial Commit:

```bash
git commit -m "Initial commit for new project based on template"
```

This creates the very first commit for your new project's unique history.

Link to a New Remote (e.g., GitHub/GitLab/etc.): If you're going to host this new project online, create an empty repository on your chosen platform (GitHub, GitLab, etc.). Then, link your local repo to it:

```bash
git remote add origin <url_to_your_new_empty_remote_repo>
git branch -M main # Or 'master' if you prefer, but 'main' is the modern default
git push -u origin main
```

This pushes your new project's initial commit to its own dedicated remote.

### ⚙️ Step 2: Setup Your Development Environment

Run the One-Time Setup: This `just` command automates everything, leveraging a Python script (`scripts/setup.py`) for cross-platform compatibility: Nx initialization, Python environment setup (pyenv, uv), custom Nx generator creation, and pre-commit hook installation.

```bash
just setup
```

- Initial run might take a few minutes as it downloads dependencies and sets up environments.
- If uv installation via pip fails, you might need to install Rust toolchain first and set `RUST_TOOLCHAIN_UV_INSTALL ?= true` in the Makefile, then retry `just setup`.

## ⚡ Daily Workflow

Here's how to interact with your monorepo for daily development:

### 🏗️ Hexagonal Architecture Scaffolding

This starter kit supports rapid scaffolding of hexagonal (ports & adapters) architecture:

Generate complete workspace structure:

```bash
just scaffold
# Creates apps and domain libraries based on APPS and DOMAINS lists in justfile
```

View current workspace structure:

```bash
just tree
# Pretty-prints the directory tree with intelligent filtering
```

Clean generated structure (use with caution!):

```bash
just clean
# Removes generated build artifacts and caches
```

Customize your architecture: Edit the APPS and DOMAINS lists in the justfile:

```just
APPS := "allocation-api payments-api invoicing-api"
DOMAINS := "allocation payments invoicing inventory shipping analytics"
```

### 🆕 Project Generation

New Python Application:

```bash
just app NAME=my-fastapi-service
```

This command automatically generates the app, configures it with ruff, mypy, pytest, and installs its initial dependencies using uv.

New Python Library:

```bash
just lib NAME=my-shared-data-models
```

This command works similarly for Python libraries.

### 🏃 Running Tasks

Lint all affected projects:

```bash
just lint
```

Type-check all affected projects:

```bash
just typecheck
```

Run tests for all affected projects:

```bash
just test
```

Build all affected projects (JS/TS apps/libs):

```bash
just build
```

Serve a specific application (e.g., React frontend or Python API):

```bash
just serve PROJECT=my-react-app
just serve PROJECT=my-fastapi-service
```

Visualize the Nx dependency graph:

```bash
just graph
```

### 🌍 Infrastructure-as-Code (IaC)

Run a plan for an IaC target (e.g., Terraform VPC stack):

```bash
just infra-plan TARGET=vpc
```

Requires an Nx project named infrastructure with a plan-<TARGET> task.

Apply changes for an IaC target (e.g., Kubernetes cluster):

```bash
just infra-apply TARGET=kubernetes-cluster
```

Requires an Nx project named infrastructure with an apply-<TARGET> task.

Run an Ansible playbook:

```bash
just ansible-run PLAYBOOK=deploy-edge-nodes HOSTS=production-cluster
```

Requires an Nx project named ansible-playbooks with a run-<PLAYBOOK> task.

### 📦 Containerization (Microservices)

Build a Docker image for any application:

```bash
just containerize PROJECT=my-fastapi-service
```

Requires a Dockerfile in the project's root and a container target in its project.json.

### 🔄 Reversible Microservice Architecture

This starter kit features a unique reversible microservice architecture that allows you to:

**Extract contexts to microservices:**

```bash
just service-split CTX=accounting TRANSPORT=fastapi
```

This creates a complete microservice with:
- FastAPI application with health checks
- Docker container configuration
- Kubernetes manifests
- Production-ready structure

**Merge microservices back to monolith:**

```bash
just service-merge CTX=accounting
```

This removes the service application while preserving the domain logic in the monolith - zero code impact!

**View deployment status:**

```bash
just service-status
```

Shows which contexts are deployed as services and which remain in the monolith.

**Deploy services:**

```bash
just deploy-service CTX=accounting
just deploy-services  # Deploy all services
```

### 🎯 Domain-Driven Development

This starter kit supports domain-driven architecture with specialized commands for organizing code by business domains:

Create a DDD context with hexagonal architecture:

```bash
just context-new CTX=orders
```

This creates domain, application, and infrastructure layers for the context.

Create domain-specific libraries:

```bash
just model-new CTX=orders
```

Generate full microservice stack for a domain:

```bash
just domain-stack DOMAIN=allocation
# Creates: allocation-api, allocation-models, allocation-database, allocation-shared
```

### 🧹 Cleanup

Clean build artifacts and caches:

```bash
just clean
```

Use with caution! This removes node_modules, .venv, and Nx caches. You'll need to run `just setup` again to restore the environment.

## ⚙️ Customization & Advanced Usage

- **Justfile Variables**: Adjust `PYTHON_VERSION`, `NX_PYTHON_PLUGIN_VERSION`, and `RUST_TOOLCHAIN_UV_INSTALL` directly in the justfile if needed.
- **Custom Nx Generators**: The `libs/shared-python-tools` plugin contains the generator.ts files that define how new Python projects are structured and configured. Feel free to modify them to fit specific architectural patterns or add new default dependencies/tools.
- **pyproject.toml**: For project-specific Python dependencies, edit the pyproject.toml inside your individual `apps/<project-name>` or `libs/<project-name>` directories, then run `pnpm nx run <project-name>:install-deps` (or use `just app`/`just lib` for new projects which does it automatically).
- **project.json**: Each Nx project (including your Python and IaC ones) has a project.json. This is where specific tasks (like container, infra-plan, infra-apply) are defined using nx:run-commands. You'll customize these as you build out your IaC and microservice projects.

## 🤝 Contributing

This is designed as a personal starter kit, but feedback or suggestions for improvements are always welcome!

For example, if your `.env` file contains:

```sh
# a comment, will be ignored
DATABASE_ADDRESS=localhost:6379
SERVER_PORT=1337
```

And your `justfile` contains:

```just
set dotenv-load

serve:
  @echo "Starting server with database $DATABASE_ADDRESS on port $SERVER_PORT…"
  ./server --database $DATABASE_ADDRESS --port $SERVER_PORT
```

`just serve` will output:

```sh
$ just serve
Starting server with database localhost:6379 on port 1337…
./server --database $DATABASE_ADDRESS --port $SERVER_PORT
```

### Variables and Substitution

Variables, strings, concatenation, path joining, and substitution using `{{…}}` are supported:

```just
tmpdir  := `mktemp`
version := "0.2.7"
tardir  := tmpdir / "awesomesauce-" + version
tarball := tardir + ".tar.gz"

publish:
  rm -f {{tarball}}
  mkdir {{tardir}}
  cp README.md *.c {{tardir}}
  tar zcvf {{tarball}} {{tardir}}
  scp {{tarball}} me@server.com:release/
  rm -rf {{tarball}} {{tardir}}
```

#### Joining Paths

The `/` operator can be used to join two strings with a slash:

```just
foo := "a" / "b"
```

```
$ just --evaluate foo
a/b
```

Note that a `/` is added even if one is already present:

```just
foo := "a/"
bar := foo / "b"
```

```
$ just --evaluate bar
a//b
```

Absolute paths can also be constructed<sup>1.5.0</sup>:

```just
foo := / "b"
```

```
$ just --evaluate foo
/b
```

The `/` operator uses the `/` character, even on Windows. Thus, using the `/` operator should be avoided with paths that use universal naming convention (UNC), i.e., those that start with `\?`, since forward slashes are not supported with UNC paths.

#### Escaping `{{`

To write a recipe containing `{{`, use `{{{{`:

```just
braces:
  echo 'I {{{{LOVE}} curly braces!'
```

(An unmatched `}}` is ignored, so it doesn't need to be escaped.)

Another option is to put all the text you'd like to escape inside of an interpolation:

```just
braces:
  echo '{{'I {{LOVE}} curly braces!'}}'
```

Yet another option is to use `{{ "{{" }}`:

```just
braces:
  echo 'I {{ "{{" }}LOVE}} curly braces!'
```

### Strings

Double-quoted strings support escape sequences:

```just
string-with-tab             := "\t"
string-with-newline         := "\n"
string-with-carriage-return := "\r"
string-with-double-quote    := "\""
string-with-slash           := "\\"
string-with-no-newline      := "\
"
```

```sh
$ just --evaluate
"tring-with-carriage-return := "
string-with-double-quote    := """
string-with-newline         := "
"
string-with-no-newline      := ""
string-with-slash           := "\"
string-with-tab             := "     "
```

Strings may contain line breaks:

```just
single := '
hello
'

double := "
goodbye
"
```

Single-quoted strings do not recognize escape sequences:

```just
escapes := '\t\n\r\"\\'
```

```sh
$ just --evaluate
escapes := "\t\n\r\"\\"
```

Indented versions of both single- and double-quoted strings, delimited by triple single- or triple double-quotes, are supported. Indented string lines are stripped of leading whitespace common to all non-blank lines:

```just
# this string will evaluate to `foo\nbar\n`
x := '''
  foo
  bar
'''

# this string will evaluate to `abc\n  wuv\nbar\n`
y := """
  abc
    wuv
  xyz
"""
```

Similar to unindented strings, indented double-quoted strings process escape sequences, and indented single-quoted strings ignore escape sequences. Escape sequence processing takes place after unindentation. The unindentation algorithm does not take escape-sequence produced whitespace or newlines into account.

### Ignoring Errors

Normally, if a command returns a non-zero exit status, execution will stop. To continue execution after a command, even if it fails, prefix the command with `-`:

```just
foo:
  -cat foo
  echo 'Done!'
```

```sh
$ just foo
cat foo
cat: foo: No such file or directory
echo 'Done!'
Done!
```

### Functions

`just` provides a few built-in functions that might be useful when writing recipes.

#### System Information

- `arch()` — Instruction set architecture. Possible values are: `"aarch64"`, `"arm"`, `"asmjs"`, `"hexagon"`, `"mips"`, `"msp430"`, `"powerpc"`, `"powerpc64"`, `"s390x"`, `"sparc"`, `"wasm32"`, `"x86"`, `"x86_64"`, and `"xcore"`.
- `os()` — Operating system. Possible values are: `"android"`, `"bitrig"`, `"dragonfly"`, `"emscripten"`, `"freebsd"`, `"haiku"`, `"ios"`, `"linux"`, `"macos"`, `"netbsd"`, `"openbsd"`, `"solaris"`, and `"windows"`.
- `os_family()` — Operating system family; possible values are: `"unix"` and `"windows"`.

For example:

```just
system-info:
  @echo "This is an {{arch()}} machine".
```

```sh
$ just system-info
This is an x86_64 machine
```

The `os_family()` function can be used to create cross-platform `justfile`s that work on various operating systems. For an example, see [cross-platform.just](https://github.com/casey/just/blob/master/examples/cross-platform.just) file.

#### Environment Variables

- `env_var(key)` — Retrieves the environment variable with name `key`, aborting if it is not present.

```just
home_dir := env_var('HOME')

test:
  echo "{{home_dir}}"
```

```sh
$ just
/home/user1
```

- `env_var_or_default(key, default)` — Retrieves the environment variable with name `key`, returning `default` if it is not present.

#### Invocation Directory

- `invocation_directory()` - Retrieves the absolute path to the current
  directory when `just` was invoked, before  `just` changed it (chdir'd) prior
  to executing commands. On Windows, `invocation_directory()` uses `cygpath` to
  convert the invocation directory to a Cygwin-compatible `/`-separated path.
  Use `invocation_directory_native()` to return the verbatim invocation
  directory on all platforms.

For example, to call `rustfmt` on files just under the "current directory"
(from the user/invoker's perspective), use the following rule:

```just
rustfmt:
  find {{invocation_directory()}} -name \*.rs -exec rustfmt {} \;
```

Alternatively, if your command needs to be run from the current directory, you
could use (e.g.):

```just
build:
  cd {{invocation_directory()}}; ./some_script_that_needs_to_be_run_from_here
```

- `invocation_directory_native()` - Retrieves the absolute path to the current
  directory when `just` was invoked, before  `just` changed it (chdir'd) prior
  to executing commands.

#### Justfile and Justfile Directory

- `justfile()` - Retrieves the path of the current `justfile`.

- `justfile_directory()` - Retrieves the path of the parent directory of the current `justfile`.

For example, to run a command relative to the location of the current `justfile`:

```just
script:
  ./{{justfile_directory()}}/scripts/some_script
```

#### Just Executable

- `just_executable()` - Absolute path to the `just` executable.

For example:

```just
executable:
  @echo The executable is at: {{just_executable()}}
```

```sh
$ just
The executable is at: /bin/just
```

#### String Manipulation

- `quote(s)` - Replace all single quotes with `'\''` and prepend and append single quotes to `s`. This is sufficient to escape special characters for many shells, including most Bourne shell descendants.
- `replace(s, from, to)` - Replace all occurrences of `from` in `s` to `to`.
- `replace_regex(s, regex, replacement)` - Replace all occurrences of `regex` in `s` to `replacement`. Regular expressions are provided by the [Rust `regex` crate](https://docs.rs/regex/latest/regex/). See the [syntax documentation](https://docs.rs/regex/latest/regex/#syntax) for usage examples.
- `trim(s)` - Remove leading and trailing whitespace from `s`.
- `trim_end(s)` - Remove trailing whitespace from `s`.
- `trim_end_match(s, pat)` - Remove suffix of `s` matching `pat`.
- `trim_end_matches(s, pat)` - Repeatedly remove suffixes of `s` matching `pat`.
- `trim_start(s)` - Remove leading whitespace from `s`.
- `trim_start_match(s, pat)` - Remove prefix of `s` matching `pat`.
- `trim_start_matches(s, pat)` - Repeatedly remove prefixes of `s` matching `pat`.

#### Case Conversion

- `capitalize(s)`<sup>1.7.0</sup> - Convert first character of `s` to uppercase and the rest to lowercase.
- `kebabcase(s)`<sup>1.7.0</sup> - Convert `s` to `kebab-case`.
- `lowercamelcase(s)`<sup>1.7.0</sup> - Convert `s` to `lowerCamelCase`.
- `lowercase(s)` - Convert `s` to lowercase.
- `shoutykebabcase(s)`<sup>1.7.0</sup> - Convert `s` to `SHOUTY-KEBAB-CASE`.
- `shoutysnakecase(s)`<sup>1.7.0</sup> - Convert `s` to `SHOUTY_SNAKE_CASE`.
- `snakecase(s)`<sup>1.7.0</sup> - Convert `s` to `snake_case`.
- `titlecase(s)`<sup>1.7.0</sup> - Convert `s` to `Title Case`.
- `uppercamelcase(s)`<sup>1.7.0</sup> - Convert `s` to `UpperCamelCase`.
- `uppercase(s)` - Convert `s` to uppercase.

#### Path Manipulation

##### Fallible

- `absolute_path(path)` - Absolute path to relative `path` in the working directory. `absolute_path("./bar.txt")` in directory `/foo` is `/foo/bar.txt`.
- `extension(path)` - Extension of `path`. `extension("/foo/bar.txt")` is `txt`.
- `file_name(path)` - File name of `path` with any leading directory components removed. `file_name("/foo/bar.txt")` is `bar.txt`.
- `file_stem(path)` - File name of `path` without extension. `file_stem("/foo/bar.txt")` is `bar`.
- `parent_directory(path)` - Parent directory of `path`. `parent_directory("/foo/bar.txt")` is `/foo`.
- `without_extension(path)` - `path` without extension. `without_extension("/foo/bar.txt")` is `/foo/bar`.

These functions can fail, for example if a path does not have an extension, which will halt execution.

##### Infallible

- `clean(path)` - Simplify `path` by removing extra path separators, intermediate `.` components, and `..` where possible. `clean("foo//bar")` is `foo/bar`, `clean("foo/..")` is `.`, `clean("foo/./bar")` is `foo/bar`.
- `join(a, b…)` - *This function uses `/` on Unix and `\` on Windows, which can be lead to unwanted behavior. The `/` operator, e.g., `a / b`, which always uses `/`, should be considered as a replacement unless `\`s are specifically desired on Windows.* Join path `a` with path `b`. `join("foo/bar", "baz")` is `foo/bar/baz`. Accepts two or more arguments.

#### Filesystem Access

- `path_exists(path)` - Returns `true` if the path points at an existing entity and `false` otherwise. Traverses symbolic links, and returns `false` if the path is inaccessible or points to a broken symlink.

##### Error Reporting

- `error(message)` - Abort execution and report error `message` to user.

#### UUID and Hash Generation

- `sha256(string)` - Return the SHA-256 hash of `string` as a hexadecimal string.
- `sha256_file(path)` - Return the SHA-256 hash of the file at `path` as a hexadecimal string.
- `uuid()` - Return a randomly generated UUID.

### Recipe Attributes

Recipes may be annotated with attributes that change their behavior.

| Name                | Description                                     |
| ------------------- | ----------------------------------------------- |
| `[no-cd]`           | Don't change directory before executing recipe. |
| `[no-exit-message]` | Don't print an error message if recipe fails.   |
| `[linux]`           | Enable recipe on Linux.                         |
| `[macos]`           | Enable recipe on MacOS.                         |
| `[unix]`            | Enable recipe on Unixes.                        |
| `[windows]`         | Enable recipe on Windows.                       |

#### Enabling and Disabling Recipes

The `[linux]`, `[macos]`, `[unix]`, and `[windows]` attributes are
configuration attributes. By default, recipes are always enabled. A recipe with
one or more configuration attributes will only be enabled when one or more of
those configurations is active.

This can be used to write `justfile`s that behave differently depending on
which operating system they run on. The `run` recipe in this `justfile` will
compile and run `main.c`, using a different C compiler and using the correct
output binary name for that compiler depending on the operating system:

```just
[unix]
run:
  cc main.c
  ./a.out

[windows]
run:
  cl main.c
  main.exe
```

#### Disabling Changing Directory<sup>1.9.0</sup>

`just` normally executes recipes with the current directory set to the
directory that contains the `justfile`. This can be disabled using the
`[no-cd]` attribute. This can be used to create recipes which use paths
relative to the invocation directory, or which operate on the current
directory.

For example, this `commit` recipe:

```just
[no-cd]
commit file:
  git add {{file}}
  git commit
```

Can be used with paths that are relative to the current directory, because
`[no-cd]` prevents `just` from changing the current directory when executing
`commit`.

### Command Evaluation Using Backticks

Backticks can be used to store the result of commands:

```just
localhost := `dumpinterfaces | cut -d: -f2 | sed 's/\/.*//' | sed 's/ //g'`

serve:
  ./serve {{localhost}} 8080
```

Indented backticks, delimited by three backticks, are de-indented in the same manner as indented strings:

````just
# This backtick evaluates the command `echo foo\necho bar\n`, which produces the value `foo\nbar\n`.
stuff := ```
    echo foo
    echo bar
  ```
````

See the [Strings](#strings) section for details on unindenting.

Backticks may not start with `#!`. This syntax is reserved for a future upgrade.

### Conditional Expressions

`if`/`else` expressions evaluate different branches depending on if two expressions evaluate to the same value:

```just
foo := if "2" == "2" { "Good!" } else { "1984" }

bar:
  @echo "{{foo}}"
```

```sh
$ just bar
Good!
```

It is also possible to test for inequality:

```just
foo := if "hello" != "goodbye" { "xyz" } else { "abc" }

bar:
  @echo {{foo}}
```

```sh
$ just bar
xyz
```

And match against regular expressions:

```just
foo := if "hello" =~ 'hel+o' { "match" } else { "mismatch" }

bar:
  @echo {{foo}}
```

```sh
$ just bar
match
```

Regular expressions are provided by the [regex crate](https://github.com/rust-lang/regex), whose syntax is documented on [docs.rs](https://docs.rs/regex/1.5.4/regex/#syntax). Since regular expressions commonly use backslash escape sequences, consider using single-quoted string literals, which will pass slashes to the regex parser unmolested.

Conditional expressions short-circuit, which means they only evaluate one of their branches. This can be used to make sure that backtick expressions don't run when they shouldn't.

```just
foo := if env_var("RELEASE") == "true" { `get-something-from-release-database` } else { "dummy-value" }
```

Conditionals can be used inside of recipes:

```just
bar foo:
  echo {{ if foo == "bar" { "hello" } else { "goodbye" } }}
```

Note the space after the final `}`! Without the space, the interpolation will be prematurely closed.

Multiple conditionals can be chained:

```just
foo := if "hello" == "goodbye" {
  "xyz"
} else if "a" == "a" {
  "abc"
} else {
  "123"
}

bar:
  @echo {{foo}}
```

```sh
$ just bar
abc
```

### Stopping execution with error

Execution can be halted with the `error` function. For example:

```just
foo := if "hello" == "goodbye" {
  "xyz"
} else if "a" == "b" {
  "abc"
} else {
  error("123")
}
```

Which produce the following error when run:

```
error: Call to function `error` failed: 123
   |
16 |   error("123")
```

### Setting Variables from the Command Line

Variables can be overridden from the command line.

```just
os := "linux"

test: build
  ./test --test {{os}}

build:
  ./build {{os}}
```

```sh
$ just
./build linux
./test --test linux
```

Any number of arguments of the form `NAME=VALUE` can be passed before recipes:

```sh
$ just os=plan9
./build plan9
./test --test plan9
```

Or you can use the `--set` flag:

```sh
$ just --set os bsd
./build bsd
./test --test bsd
```

### Getting and Setting Environment Variables

#### Exporting `just` Variables

Assignments prefixed with the `export` keyword will be exported to recipes as environment variables:

```just
export RUST_BACKTRACE := "1"

test:
  # will print a stack trace if it crashes
  cargo test
```

Parameters prefixed with a `$` will be exported as environment variables:

```just
test $RUST_BACKTRACE="1":
  # will print a stack trace if it crashes
  cargo test
```

Exported variables and parameters are not exported to backticks in the same scope.

```just
export WORLD := "world"
# This backtick will fail with "WORLD: unbound variable"
BAR := `echo hello $WORLD`
```

```just
# Running `just a foo` will fail with "A: unbound variable"
a $A $B=`echo $A`:
  echo $A $B
```

When [export](#export) is set, all `just` variables are exported as environment variables.

#### Getting Environment Variables from the environment

Environment variables from the environment are passed automatically to the recipes.

```just
print_home_folder:
  echo "HOME is: '${HOME}'"
```

```sh
$ just
HOME is '/home/myuser'
```
#### Loading Environment Variables from a `.env` File

`just` will load environment variables from a `.env` file if [dotenv-load](#dotenv-load) is set. The variables in the file will be available as environment variables to the recipes. See [dotenv-integration](#dotenv-integration) for more information.

#### Setting `just` Variables from Environment Variables

Environment variables can be propagated to `just` variables using the functions `env_var()` and `env_var_or_default()`.
See [environment-variables](#environment-variables).

### Recipe Parameters

Recipes may have parameters. Here recipe `build` has a parameter called `target`:

```just
build target:
  @echo 'Building {{target}}…'
  cd {{target}} && make
```

To pass arguments on the command line, put them after the recipe name:

```sh
$ just build my-awesome-project
Building my-awesome-project…
cd my-awesome-project && make
```

To pass arguments to a dependency, put the dependency in parentheses along with the arguments:

```just
default: (build "main")

build target:
  @echo 'Building {{target}}…'
  cd {{target}} && make
```

Variables can also be passed as arguments to dependencies:

```just
target := "main"

_build version:
  @echo 'Building {{version}}…'
  cd {{version}} && make

build: (_build target)
```

A command's arguments can be passed to dependency by putting the dependency in parentheses along with the arguments:

```just
build target:
  @echo "Building {{target}}…"

push target: (build target)
  @echo 'Pushing {{target}}…'
```

Parameters may have default values:

```just
default := 'all'

test target tests=default:
  @echo 'Testing {{target}}:{{tests}}…'
  ./test --tests {{tests}} {{target}}
```

Parameters with default values may be omitted:

```sh
$ just test server
Testing server:all…
./test --tests all server
```

Or supplied:

```sh
$ just test server unit
Testing server:unit…
./test --tests unit server
```

Default values may be arbitrary expressions, but concatenations or path joins must be parenthesized:

```just
arch := "wasm"

test triple=(arch + "-unknown-unknown") input=(arch / "input.dat"):
  ./test {{triple}}
```

The last parameter of a recipe may be variadic, indicated with either a `+` or a `*` before the argument name:

```just
backup +FILES:
  scp {{FILES}} me@server.com:
```

Variadic parameters prefixed with `+` accept _one or more_ arguments and expand to a string containing those arguments separated by spaces:

```sh
$ just backup FAQ.md GRAMMAR.md
scp FAQ.md GRAMMAR.md me@server.com:
FAQ.md                  100% 1831     1.8KB/s   00:00
GRAMMAR.md              100% 1666     1.6KB/s   00:00
```

Variadic parameters prefixed with `*` accept _zero or more_ arguments and expand to a string containing those arguments separated by spaces, or an empty string if no arguments are present:

```just
commit MESSAGE *FLAGS:
  git commit {{FLAGS}} -m "{{MESSAGE}}"
```

Variadic parameters can be assigned default values. These are overridden by arguments passed on the command line:

```just
test +FLAGS='-q':
  cargo test {{FLAGS}}
```

`{{…}}` substitutions may need to be quoted if they contain spaces. For example, if you have the following recipe:

```just
search QUERY:
  lynx https://www.google.com/?q={{QUERY}}
```

And you type:

```sh
$ just search "cat toupee"
```

`just` will run the command `lynx https://www.google.com/?q=cat toupee`, which will get parsed by `sh` as `lynx`, `https://www.google.com/?q=cat`, and `toupee`, and not the intended `lynx` and `https://www.google.com/?q=cat toupee`.

You can fix this by adding quotes:

```just
search QUERY:
  lynx 'https://www.google.com/?q={{QUERY}}'
```

Parameters prefixed with a `$` will be exported as environment variables:

```just
foo $bar:
  echo $bar
```

### Running Recipes at the End of a Recipe

Normal dependencies of a recipes always run before a recipe starts. That is to say, the dependee always runs before the depender. These dependencies are called "prior dependencies".

A recipe can also have subsequent dependencies, which run after the recipe and are introduced with an `&&`:

```just
a:
  echo 'A!'

b: a && c d
  echo 'B!'

c:
  echo 'C!'

d:
  echo 'D!'
```

…running _b_ prints:

```sh
$ just b
echo 'A!'
A!
echo 'B!'
B!
echo 'C!'
C!
echo 'D!'
D!
```

### Running Recipes in the Middle of a Recipe

`just` doesn't support running recipes in the middle of another recipe, but you can call `just` recursively in the middle of a recipe. Given the following `justfile`:

```just
a:
  echo 'A!'

b: a
  echo 'B start!'
  just c
  echo 'B end!'

c:
  echo 'C!'
```

…running _b_ prints:

```sh
$ just b
echo 'A!'
A!
echo 'B start!'
B start!
echo 'C!'
C!
echo 'B end!'
B end!
```

This has limitations, since recipe `c` is run with an entirely new invocation of `just`: Assignments will be recalculated, dependencies might run twice, and command line arguments will not be propagated to the child `just` process.

### Writing Recipes in Other Languages

Recipes that start with `#!` are called shebang recipes, and are executed by
saving the recipe body to a file and running it. This lets you write recipes in
different languages:

```just
polyglot: python js perl sh ruby nu

python:
  #!/usr/bin/env python3
  print('Hello from python!')

js:
  #!/usr/bin/env node
  console.log('Greetings from JavaScript!')

perl:
  #!/usr/bin/env perl
  print "Larry Wall says Hi!\n";

sh:
  #!/usr/bin/env sh
  hello='Yo'
  echo "$hello from a shell script!"

nu:
  #!/usr/bin/env nu
  let hello = 'Hola'
  echo $"($hello) from a nushell script!"

ruby:
  #!/usr/bin/env ruby
  puts "Hello from ruby!"
```

```sh
$ just polyglot
Hello from python!
Greetings from JavaScript!
Larry Wall says Hi!
Yo from a shell script!
Hola from a nushell script!
Hello from ruby!
```

On Unix-like operating systems, including Linux and MacOS, shebang recipes are
executed by saving the recipe body to a file in a temporary directory, marking
the file as executable, and executing it. The OS then parses the shebang line
into a command line and invokes it, including the path to the file. For
example, if a recipe starts with `#!/usr/bin/env bash`, the final command that
the OS runs will be something like `/usr/bin/env bash
/tmp/PATH_TO_SAVED_RECIPE_BODY`. Keep in mind that different operating systems
split shebang lines differently.

Windows does not support shebang lines. On Windows, `just` splits the shebang
line into a command and arguments, saves the recipe body to a file, and invokes
the split command and arguments, adding the path to the saved recipe body as
the final argument.

### Safer Bash Shebang Recipes

If you're writing a `bash` shebang recipe, consider adding `set -euxo pipefail`:

```just
foo:
  #!/usr/bin/env bash
  set -euxo pipefail
  hello='Yo'
  echo "$hello from Bash!"
```

It isn't strictly necessary, but `set -euxo pipefail` turns on a few useful features that make `bash` shebang recipes behave more like normal, linewise `just` recipe:

- `set -e` makes `bash` exit if a command fails.

- `set -u` makes `bash` exit if a variable is undefined.

- `set -x` makes `bash` print each script line before it's run.

- `set -o pipefail` makes `bash` exit if a command in a pipeline fails. This is `bash`-specific, so isn't turned on in normal linewise `just` recipes.

Together, these avoid a lot of shell scripting gotchas.

#### Shebang Recipe Execution on Windows

On Windows, shebang interpreter paths containing a `/` are translated from Unix-style paths to Windows-style paths using `cygpath`, a utility that ships with [Cygwin](http://www.cygwin.com).

For example, to execute this recipe on Windows:

```just
echo:
  #!/bin/sh
  echo "Hello!"
```

The interpreter path `/bin/sh` will be translated to a Windows-style path using `cygpath` before being executed.

If the interpreter path does not contain a `/` it will be executed without being translated. This is useful if `cygpath` is not available, or you wish to pass a Windows-style path to the interpreter.

### Setting Variables in a Recipe

Recipe lines are interpreted by the shell, not `just`, so it's not possible to set `just` variables in the middle of a recipe:

```mf
foo:
  x := "hello" # This doesn't work!
  echo {{x}}
```

It is possible to use shell variables, but there's another problem. Every recipe line is run by a new shell instance, so variables set in one line won't be set in the next:

```just
foo:
  x=hello && echo $x # This works!
  y=bye
  echo $y            # This doesn't, `y` is undefined here!
```

The best way to work around this is to use a shebang recipe. Shebang recipe bodies are extracted and run as scripts, so a single shell instance will run the whole thing:

```just
foo:
  #!/usr/bin/env bash
  set -euxo pipefail
  x=hello
  echo $x
```

### Sharing Environment Variables Between Recipes

Each line of each recipe is executed by a fresh shell, so it is not possible to share environment variables between recipes.

#### Using Python Virtual Environments

Some tools, like [Python's venv](https://docs.python.org/3/library/venv.html), require loading environment variables in order to work, making them challenging to use with `just`. As a workaround, you can execute the virtual environment binaries directly:

```just
venv:
  [ -d foo ] || python3 -m venv foo

run: venv
  ./foo/bin/python3 main.py
```

### Changing the Working Directory in a Recipe

Each recipe line is executed by a new shell, so if you change the working directory on one line, it won't have an effect on later lines:

```just
foo:
  pwd    # This `pwd` will print the same directory…
  cd bar
  pwd    # …as this `pwd`!
```

There are a couple ways around this. One is to call `cd` on the same line as the command you want to run:

```just
foo:
  cd bar && pwd
```

The other is to use a shebang recipe. Shebang recipe bodies are extracted and run as scripts, so a single shell instance will run the whole thing, and thus a `pwd` on one line will affect later lines, just like a shell script:

```just
foo:
  #!/usr/bin/env bash
  set -euxo pipefail
  cd bar
  pwd
```

### Indentation

Recipe lines can be indented with spaces or tabs, but not a mix of both. All of a recipe's lines must have the same indentation, but different recipes in the same `justfile` may use different indentation.

### Multi-Line Constructs

Recipes without an initial shebang are evaluated and run line-by-line, which means that multi-line constructs probably won't do what you want.

For example, with the following `justfile`:

```mf
conditional:
  if true; then
    echo 'True!'
  fi
```

The extra leading whitespace before the second line of the `conditional` recipe will produce a parse error:

```sh
$ just conditional
error: Recipe line has extra leading whitespace
  |
3 |         echo 'True!'
  |     ^^^^^^^^^^^^^^^^
```

To work around this, you can write conditionals on one line, escape newlines with slashes, or add a shebang to your recipe. Some examples of multi-line constructs are provided for reference.

#### `if` statements

```just
conditional:
  if true; then echo 'True!'; fi
```

```just
conditional:
  if true; then \
    echo 'True!'; \
  fi
```

```just
conditional:
  #!/usr/bin/env sh
  if true; then
    echo 'True!'
  fi
```

#### `for` loops

```just
for:
  for file in `ls .`; do echo $file; done
```

```just
for:
  for file in `ls .`; do \
    echo $file; \
  done
```

```just
for:
  #!/usr/bin/env sh
  for file in `ls .`; do
    echo $file
  done
```

#### `while` loops

```just
while:
  while `server-is-dead`; do ping -c 1 server; done
```

```just
while:
  while `server-is-dead`; do \
    ping -c 1 server; \
  done
```

```just
while:
  #!/usr/bin/env sh
  while `server-is-dead`; do
    ping -c 1 server
  done
```

### Command Line Options

`just` supports a number of useful command line options for listing, dumping, and debugging recipes and variable:

```sh
$ just --list
Available recipes:
  js
  perl
  polyglot
  python
  ruby
$ just --show perl
perl:
  #!/usr/bin/env perl
  print "Larry Wall says Hi!\n";
$ just --show polyglot
polyglot: python js perl sh ruby
```

Run `just --help` to see all the options.

### Private Recipes

Recipes and aliases whose name starts with a `_` are omitted from `just --list`:

```just
test: _test-helper
  ./bin/test

_test-helper:
  ./bin/super-secret-test-helper-stuff
```

```sh
$ just --list
Available recipes:
    test
```

And from `just --summary`:

```sh
$ just --summary
test
```

The `[private]` attribute<sup>1.10.0</sup> may also be used to hide recipes or aliases without needing to change the name:

```just
[private]
foo:

[private]
alias b := bar

bar:
```

```sh
$ just --list
Available recipes:
    bar
```

This is useful for helper recipes which are only meant to be used as dependencies of other recipes.

### Quiet Recipes

A recipe name may be prefixed with `@` to invert the meaning of `@` before each line:

```just
@quiet:
  echo hello
  echo goodbye
  @# all done!
```

Now only the lines starting with `@` will be echoed:

```sh
$ j quiet
hello
goodbye
# all done!
```

Shebang recipes are quiet by default:

```just
foo:
  #!/usr/bin/env bash
  echo 'Foo!'
```

```sh
$ just foo
Foo!
```

Adding `@` to a shebang recipe name makes `just` print the recipe before executing it:

```just
@bar:
  #!/usr/bin/env bash
  echo 'Bar!'
```

```sh
$ just bar
#!/usr/bin/env bash
echo 'Bar!'
Bar!
```

`just` normally prints error messages when a recipe line fails. These error
messages can be suppressed using the `[no-exit-message]` attribute. You may find
this especially useful with a recipe that recipe wraps a tool:

```just
git *args:
    @git {{args}}
```

```sh
$ just git status
fatal: not a git repository (or any of the parent directories): .git
error: Recipe `git` failed on line 2 with exit code 128
```

Add the attribute to suppress the exit error message when the tool exits with a
non-zero code:

```just
[no-exit-message]
git *args:
    @git {{args}}
```

```sh
$ just git status
fatal: not a git repository (or any of the parent directories): .git
```

### Selecting Recipes to Run With an Interactive Chooser

The `--choose` subcommand makes `just` invoke a chooser to select which recipes to run. Choosers should read lines containing recipe names from standard input and print one or more of those names separated by spaces to standard output.

Because there is currently no way to run a recipe that requires arguments with `--choose`, such recipes will not be given to the chooser. Private recipes and aliases are also skipped.

The chooser can be overridden with the `--chooser` flag. If `--chooser` is not given, then `just` first checks if `$JUST_CHOOSER` is set. If it isn't, then the chooser defaults to `fzf`, a popular fuzzy finder.

Arguments can be included in the chooser, i.e. `fzf --exact`.

The chooser is invoked in the same way as recipe lines. For example, if the chooser is `fzf`, it will be invoked with `sh -cu 'fzf'`, and if the shell, or the shell arguments are overridden, the chooser invocation will respect those overrides.

If you'd like `just` to default to selecting recipes with a chooser, you can use this as your default recipe:

```just
default:
  @just --choose
```

### Invoking `justfile`s in Other Directories

If the first argument passed to `just` contains a `/`, then the following occurs:

1.  The argument is split at the last `/`.

2.  The part before the last `/` is treated as a directory. `just` will start its search for the `justfile` there, instead of in the current directory.

3.  The part after the last slash is treated as a normal argument, or ignored if it is empty.

This may seem a little strange, but it's useful if you wish to run a command in a `justfile` that is in a subdirectory.

For example, if you are in a directory which contains a subdirectory named `foo`, which contains a `justfile` with the recipe `build`, which is also the default recipe, the following are all equivalent:

```sh
$ (cd foo && just build)
$ just foo/build
$ just foo/
```

Additional recipes after the first are sought in the same `justfile`. For
example, the following are both equivalent:

```sh
$ just foo/a b
$ (cd foo && just a b)
```

And will both invoke recipes `a` and `b` in `foo/justfile`.

### Include Directives

The `!include` directive, currently unstable, can be used to include the
verbatim text of another file.

If you have the following `justfile`:

```mf
!include foo/bar.just

a: b
  @echo A

```

And the following text in `foo/bar.just`:

```mf
b:
  @echo B
```

`foo/bar.just` will be included in `justfile` and recipe `b` will be defined:

```sh
$ just --unstable b
B
$ just --unstable a
B
A
```

The `!include` directive path can be absolute or relative to the location of
the justfile containing it. `!include` directives must appear at the beginning
of a line.

Justfiles are insensitive to order, so included files can reference variables
and recipes defined after the `!include` directive.

`!include` directives are only processed before the first non-blank,
non-comment line.

Included files can themselves contain `!include` directives, which are
processed recursively.

### Hiding `justfile`s

`just` looks for `justfile`s named `justfile` and `.justfile`, which can be used to keep a `justfile` hidden.

### Just Scripts

By adding a shebang line to the top of a `justfile` and making it executable, `just` can be used as an interpreter for scripts:

```sh
$ cat > script <<EOF
#!/usr/bin/env just --justfile

foo:
  echo foo
EOF
$ chmod +x script
$ ./script foo
echo foo
foo
```

When a script with a shebang is executed, the system supplies the path to the script as an argument to the command in the shebang. So, with a shebang of `#!/usr/bin/env just --justfile`, the command will be `/usr/bin/env just --justfile PATH_TO_SCRIPT`.

With the above shebang, `just` will change its working directory to the location of the script. If you'd rather leave the working directory unchanged, use `#!/usr/bin/env just --working-directory . --justfile`.

Note: Shebang line splitting is not consistent across operating systems. The previous examples have only been tested on macOS. On Linux, you may need to pass the `-S` flag to `env`:

```just
#!/usr/bin/env -S just --justfile

default:
  echo foo
```

### Dumping `justfile`s as JSON

The `--dump` command can be used with `--dump-format json` to print a JSON representation of a `justfile`. The JSON format is currently unstable, so the `--unstable` flag is required.

### Fallback to parent `justfile`s

If a recipe is not found in a `justfile` and the `fallback` setting is set,
`just` will look for `justfile`s in the parent directory and up, until it
reaches the root directory. `just` will stop after it reaches a `justfile` in
which the `fallback` setting is `false` or unset.

As an example, suppose the current directory contains this `justfile`:

```just
set fallback
foo:
  echo foo
```

And the parent directory contains this `justfile`:

```just
bar:
  echo bar
```

```sh
$ just bar
Trying ../justfile
echo bar
bar
```

### Avoiding Argument Splitting

Given this `justfile`:

```just
foo argument:
  touch {{argument}}
```

The following command will create two files, `some` and `argument.txt`:

```sh
$ just foo "some argument.txt"
```

The users shell will parse `"some argument.txt"` as a single argument, but when `just` replaces `touch {{argument}}` with `touch some argument.txt`, the quotes are not preserved, and `touch` will receive two arguments.

There are a few ways to avoid this: quoting, positional arguments, and exported arguments.

#### Quoting

Quotes can be added around the `{{argument}}` interpolation:

```just
foo argument:
  touch '{{argument}}'
```

This preserves `just`'s ability to catch variable name typos before running, for example if you were to write `{{argument}}`, but will not do what you want if the value of `argument` contains single quotes.

#### Positional Arguments

The `positional-arguments` setting causes all arguments to be passed as positional arguments, allowing them to be accessed with `$1`, `$2`, …, and `$@`, which can be then double-quoted to avoid further splitting by the shell:

```just
set positional-arguments

foo argument:
  touch "$1"
```

This defeats `just`'s ability to catch typos, for example if you type `$2`, but works for all possible values of `argument`, including those with double quotes.

#### Exported Arguments

All arguments are exported when the `export` setting is set:

```just
set export

foo argument:
  touch "$argument"
```

Or individual arguments may be exported by prefixing them with `$`:

```just
foo $argument:
  touch "$argument"
```

This defeats `just`'s ability to catch typos, for example if you type `$argumant`, but works for all possible values of `argument`, including those with double quotes.

### Configuring the Shell

There are a number of ways to configure the shell for linewise recipes, which are the default when a recipe does not start with a `#!` shebang. Their precedence, from highest to lowest, is:

1. The `--shell` and `--shell-arg` command line options. Passing either of these will cause `just` to ignore any settings in the current justfile.
2. `set windows-shell := [...]`
3. `set windows-powershell` (deprecated)
4. `set shell := [...]`

Since `set windows-shell` has higher precedence than `set shell`, you can use `set windows-shell` to pick a shell on Windows, and `set shell` to pick a shell for all other platforms.

Changelog
---------

A changelog for the latest release is available in [CHANGELOG.md](https://raw.githubusercontent.com/casey/just/master/CHANGELOG.md). Changelogs for previous releases are available on [the releases page](https://github.com/casey/just/releases). `just --changelog` can also be used to make a `just` binary print its changelog.

Miscellanea
-----------

### Companion Tools

Tools that pair nicely with `just` include:

- [`watchexec`](https://github.com/mattgreen/watchexec) — a simple tool that watches a path and runs a command whenever it detects modifications.

### Shell Alias

For lightning-fast command running, put `alias j=just` in your shell's configuration file.

In `bash`, the aliased command may not keep the shell completion functionality described in the next section. Add the following line to your `.bashrc` to use the same completion function as `just` for your aliased command:

```sh
complete -F _just -o bashdefault -o default j
```

### Shell Completion Scripts

Shell completion scripts for Bash, Zsh, Fish, PowerShell, and Elvish are available in the [completions](https://github.com/casey/just/tree/master/completions) directory. Please refer to your shell's documentation for how to install them.

The `just` binary can also generate the same completion scripts at runtime, using the `--completions` command:

```sh
$ just --completions zsh > just.zsh
```

*macOS Note:* Recent versions of macOS use zsh as the default shell. If you use Homebrew to install `just`, it will automatically install the most recent copy of the zsh completion script in the Homebrew zsh directory, which the built-in version of zsh doesn't know about by default. It's best to use this copy of the script if possible, since it will be updated whenever you update `just` via Homebrew. Also, many other Homebrew packages use the same location for completion scripts, and the built-in zsh doesn't know about those either. To take advantage of `just` completion in zsh in this scenario, you can set `fpath` to the Homebrew location before calling `compinit`. Note also that Oh My Zsh runs `compinit` by default. So your `.zshrc` file could look like this:

```zsh
# Init Homebrew, which adds environment variables
eval "$(brew shellenv)"

fpath=($HOMEBREW_PREFIX/share/zsh/site-functions $fpath)

# Then choose one of these options:
# 1. If you're using Oh My Zsh, you can initialize it here
# source $ZSH/oh-my-zsh.sh

# 2. Otherwise, run compinit yourself
# autoload -U compinit
# compinit
```

### Grammar

A non-normative grammar of `justfile`s can be found in [GRAMMAR.md](https://github.com/casey/just/blob/master/GRAMMAR.md).

### just.sh

Before `just` was a fancy Rust program it was a tiny shell script that called `make`. You can find the old version in [extras/just.sh](https://github.com/casey/just/blob/master/extras/just.sh).

### User `justfile`s

If you want some recipes to be available everywhere, you have a few options.

First, create a `justfile` in `~/.user.justfile` with some recipes.

#### Recipe Aliases

If you want to call the recipes in `~/.user.justfile` by name, and don't mind creating an alias for every recipe, add the following to your shell's initialization script:

```sh
for recipe in `just --justfile ~/.user.justfile --summary`; do
  alias $recipe="just --justfile ~/.user.justfile --working-directory . $recipe"
done
```

Now, if you have a recipe called `foo` in `~/.user.justfile`, you can just type `foo` at the command line to run it.

It took me way too long to realize that you could create recipe aliases like this. Notwithstanding my tardiness, I am very pleased to bring you this major advance in `justfile` technology.

#### Forwarding Alias

If you'd rather not create aliases for every recipe, you can create a single alias:

```sh
alias .j='just --justfile ~/.user.justfile --working-directory .'
```

Now, if you have a recipe called `foo` in `~/.user.justfile`, you can just type `.j foo` at the command line to run it.

I'm pretty sure that nobody actually uses this feature, but it's there.

¯\\\_(ツ)\_/¯

#### Customization

You can customize the above aliases with additional options. For example, if you'd prefer to have the recipes in your `justfile` run in your home directory, instead of the current directory:

```sh
alias .j='just --justfile ~/.user.justfile --working-directory ~'
```

### Node.js `package.json` Script Compatibility

The following export statement gives `just` recipes access to local Node module binaries, and makes `just` recipe commands behave more like `script` entries in Node.js `package.json` files:

```just
export PATH := "./node_modules/.bin:" + env_var('PATH')
```

### Alternatives and Prior Art

There is no shortage of command runners! Some more or less similar alternatives to `just` include:

- [make](https://en.wikipedia.org/wiki/Make_(software)): The Unix build tool that inspired `just`. There are a few different modern day descendents of the original `make`, including [FreeBSD Make](https://www.freebsd.org/cgi/man.cgi?make(1)) and [GNU Make](https://www.gnu.org/software/make/).
- [task](https://github.com/go-task/task): A YAML-based command runner written in Go.
- [maid](https://github.com/egoist/maid): A Markdown-based command runner written in JavaScript.
- [microsoft/just](https://github.com/microsoft/just): A JavaScript-based command runner written in JavaScript.
- [cargo-make](https://github.com/sagiegurari/cargo-make): A command runner for Rust projects.
- [mmake](https://github.com/tj/mmake): A wrapper around `make` with a number of improvements, including remote includes.
- [robo](https://github.com/tj/robo): A YAML-based command runner written in Go.
- [mask](https://github.com/jakedeichert/mask): A Markdown-based command runner written in Rust.
- [makesure](https://github.com/xonixx/makesure): A simple and portable command runner written in AWK and shell.
- [haku](https://github.com/VladimirMarkelov/haku): A make-like command runner written in Rust.

Contributing
------------

`just` welcomes your contributions! `just` is released under the maximally permissive [CC0](https://creativecommons.org/publicdomain/zero/1.0/legalcode.txt) public domain dedication and fallback license, so your changes must also be released under this license.

### Janus

[Janus](https://github.com/casey/janus) is a tool that collects and analyzes `justfile`s, and can determine if a new version of `just` breaks or changes the interpretation of existing `justfile`s.

Before merging a particularly large or gruesome change, Janus should be run to make sure that nothing breaks. Don't worry about running Janus yourself, Casey will happily run it for you on changes that need it.

### Minimum Supported Rust Version

The minimum supported Rust version, or MSRV, is current stable Rust. It may build on older versions of Rust, but this is not guaranteed.

### New Releases

New releases of `just` are made frequently so that users quickly get access to new features.

Release commit messages use the following template:

```
Release x.y.z

- Bump version: x.y.z → x.y.z
- Update changelog
- Update changelog contributor credits
- Update dependencies
- Update man page
- Update version references in readme
```

Frequently Asked Questions
--------------------------

### What are the idiosyncrasies of Make that Just avoids?

`make` has some behaviors which are confusing, complicated, or make it unsuitable for use as a general command runner.

One example is that under some circumstances, `make` won't actually run the commands in a recipe. For example, if you have a file called `test` and the following makefile:

```just
test:
  ./test
```

`make` will refuse to run your tests:

```sh
$ make test
make: `test' is up to date.
```

`make` assumes that the `test` recipe produces a file called `test`. Since this file exists and the recipe has no other dependencies, `make` thinks that it doesn't have anything to do and exits.

To be fair, this behavior is desirable when using `make` as a build system, but not when using it as a command runner. You can disable this behavior for specific targets using `make`'s built-in [`.PHONY` target name](https://www.gnu.org/software/make/manual/html_node/Phony-Targets.html), but the syntax is verbose and can be hard to remember. The explicit list of phony targets, written separately from the recipe definitions, also introduces the risk of accidentally defining a new non-phony target. In `just`, all recipes are treated as if they were phony.

Other examples of `make`'s idiosyncrasies include the difference between `=` and `:=` in assignments, the confusing error messages that are produced if you mess up your makefile, needing `$$` to use environment variables in recipes, and incompatibilities between different flavors of `make`.

### What's the relationship between Just and Cargo build scripts?

[`cargo` build scripts](http://doc.crates.io/build-script.html) have a pretty specific use, which is to control how `cargo` builds your Rust project. This might include adding flags to `rustc` invocations, building an external dependency, or running some kind of codegen step.

`just`, on the other hand, is for all the other miscellaneous commands you might run as part of development. Things like running tests in different configurations, linting your code, pushing build artifacts to a server, removing temporary files, and the like.

Also, although `just` is written in Rust, it can be used regardless of the language or build system your project uses.

Further Ramblings
-----------------

I personally find it very useful to write a `justfile` for almost every project, big or small.

On a big project with multiple contributors, it's very useful to have a file with all the commands needed to work on the project close at hand.

There are probably different commands to test, build, lint, deploy, and the like, and having them all in one place is useful and cuts down on the time you have to spend telling people which commands to run and how to type them.

And, with an easy place to put commands, it's likely that you'll come up with other useful things which are part of the project's collective wisdom, but which aren't written down anywhere, like the arcane commands needed for some part of your revision control workflow, install all your project's dependencies, or all the random flags you might need to pass to the build system.

Some ideas for recipes:

- Deploying/publishing the project

- Building in release mode vs debug mode

- Running in debug mode or with logging enabled

- Complex git workflows

- Updating dependencies

- Running different sets of tests, for example fast tests vs slow tests, or running them with verbose output

- Any complex set of commands that you really should write down somewhere, if only to be able to remember them

Even for small, personal projects it's nice to be able to remember commands by name instead of ^Reverse searching your shell history, and it's a huge boon to be able to go into an old project written in a random language with a mysterious build system and know that all the commands you need to do whatever you need to do are in the `justfile`, and that if you type `just` something useful (or at least interesting!) will probably happen.

For ideas for recipes, check out [this project's `justfile`](https://github.com/casey/just/blob/master/justfile), or some of the `justfile`s [out in the wild](https://github.com/search?o=desc&q=filename%3Ajustfile&s=indexed&type=Code).

Anyways, I think that's about it for this incredibly long-winded README.

I hope you enjoy using `just` and find great success and satisfaction in all your computational endeavors!

😸
