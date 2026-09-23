# Bash Boilerplate

A Bash script template with logging, prerequisite checks, temporary directory
cleanup, retries, and option parsing. Copy `bash-boilerplate.sh` and add your
work to `main`.

## Requirements

- Bash 4.3 or newer to run the template's color setup.
- [ShellCheck](https://www.shellcheck.net/) and
  [shfmt](https://github.com/mvdan/sh) to lint the scaffold's check scripts.

## Run

```bash
bash bash-boilerplate.sh -h
bash bash-boilerplate.sh -v
```

The template accepts `-h` for help and `-v` for verbose output. It reports
ordinary status on stdout and errors on stderr. Add functions above `main`
as needed and call them from `main`.

## Check

```bash
./scripts/check.sh
```

The check runs `bash -n` on all scripts, ShellCheck and shfmt on the scaffold's
check scripts, and smoke tests for the template. It does not lint or format
`bash-boilerplate.sh`; the current template has findings from both tools. To
inspect them without changing the script, run:

```bash
shellcheck bash-boilerplate.sh
shfmt -i 2 -ci -bn -d bash-boilerplate.sh
```
