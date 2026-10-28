#!/usr/bin/env python3
"""Run a matched deployment comparison without publishing authenticated output."""

import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import tempfile
import time


SOURCE = "force-app/main/default"
TEST_LEVEL = "RunLocalTests"


class ComparisonError(Exception):
    """Only fixed, credential-free messages may be displayed."""


def git(repo, *args):
    return subprocess.check_output(
        ["git", "-C", str(repo), *args], stderr=subprocess.DEVNULL
    )


def snapshot(repo, sha, destination):
    """Read blobs from Git, never from potentially modified working files."""
    resolved = git(repo, "rev-parse", "--verify", sha + "^{commit}").decode().strip()
    if resolved != sha:
        raise ComparisonError("Source must be an exact commit SHA.")
    tree = git(repo, "ls-tree", "-rz", "--full-tree", sha, "--",
               SOURCE, "sfdx-project.json", ".forceignore")
    entries = []
    for entry in tree.split(b"\0"):
        if not entry:
            continue
        metadata, raw_name = entry.split(b"\t", 1)
        mode, kind, blob = metadata.split()
        name = raw_name.decode("utf-8")
        if mode not in (b"100644", b"100755") or kind != b"blob":
            raise ComparisonError("Source contains a symlink or submodule; regular files are required.")
        if Path(name).is_absolute() or ".." in Path(name).parts:
            raise ComparisonError("Invalid source path.")
        entries.append((name, blob))
    if not any(name.startswith(SOURCE + "/") for name, _ in entries):
        raise ComparisonError("The selected commit has no force-app/main/default source.")
    if not any(name == "sfdx-project.json" for name, _ in entries):
        raise ComparisonError("The selected commit has no sfdx-project.json.")

    destination.mkdir()
    git(destination, "init", "-q")
    commit = ["-c", "user.name=Salesforce comparison", "-c",
              "user.email=comparison@example.invalid", "-c", "core.hooksPath=/dev/null",
              "commit", "-q", "--allow-empty", "--no-gpg-sign", "-m"]
    git(destination, *commit, "Empty comparison base")
    base = git(destination, "rev-parse", "HEAD").decode().strip()
    digest = hashlib.sha256()
    for name, blob in sorted(entries):
        data = git(repo, "cat-file", "blob", blob.decode())
        target = destination / name
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(data)
        digest.update(name.encode() + b"\0" + hashlib.sha256(data).digest())
    git(destination, "add", "--force", ".")
    git(destination, *commit, "Committed source snapshot")
    return base, digest.hexdigest(), len(entries)


def quiet_command(args, cwd, log, env, stage):
    # Raw output can contain freshly issued access tokens that GitHub does not
    # know to mask. Keep it private, never print it or upload it as an artifact.
    try:
        result = subprocess.run(args, cwd=cwd, env=env, stdout=log,
                                stderr=subprocess.STDOUT, timeout=3600)
    except subprocess.TimeoutExpired:
        raise ComparisonError(stage + " timed out; check Salesforce Deployment Status.") from None
    except OSError:
        raise ComparisonError(stage + " could not start; check the tool installation.") from None
    if result.returncode:
        raise ComparisonError(stage + " failed; authenticated output is suppressed. Check Salesforce Deployment Status or JWT setup.")


def execute(args, report):
    if not re.fullmatch(r"[0-9a-f]{40}", args.source_sha):
        raise ComparisonError("source_sha must be a full lowercase 40-character commit SHA.")
    if args.tool not in ("simplesfcli", "hardis") or args.mode not in ("validate", "deploy"):
        raise ComparisonError("Unsupported tool or mode.")
    environment = os.environ.get("SF_ENVIRONMENT", "PRODUCTION")
    if environment not in ("PRODUCTION", "SANDBOX"):
        raise ComparisonError("SF_ENVIRONMENT must be PRODUCTION or SANDBOX.")
    for name in ("SF_USERNAME", "SF_CLIENT_ID", "SF_JWT_KEY"):
        if not os.environ.get(name, "").strip():
            raise ComparisonError("Missing required Salesforce secrets; see setup documentation.")

    report.update(tool=args.tool, mode=args.mode, source_sha=args.source_sha,
                  test_level=TEST_LEVEL, salesforce_environment=environment,
                  tool_pins=json.loads(Path(__file__).with_name("comparison-tools.json").read_text()))
    with tempfile.TemporaryDirectory(prefix="sf-compare-", dir=os.environ.get("RUNNER_TEMP")) as temp:
        root = Path(temp)
        root.chmod(0o700)
        work = root / "source"
        base, digest, count = snapshot(Path(args.source_repo), args.source_sha, work)
        report.update(input_sha256=digest, input_files=count)
        key = root / "server.key"
        # Set permissions on creation, before writing private material.
        with os.fdopen(os.open(key, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600), "w") as key_file:
            key_file.write(os.environ["SF_JWT_KEY"])
        command_env = dict(os.environ, CI="true", SF_DISABLE_TELEMETRY="true",
                           SF_DISABLE_AUTOUPDATE="true", SFDX_DISABLE_AUTOUPDATE="true")
        # Tools need the key path, not a second copy of the private key in env.
        command_env.pop("SF_JWT_KEY", None)
        report["command_seconds"] = 0
        started = time.monotonic()
        with (root / "authenticated-output.log").open("wb") as log:
            try:
                if args.tool == "simplesfcli":
                    command = ["simpleSfCli", "--username", os.environ["SF_USERNAME"],
                               "--clientId", os.environ["SF_CLIENT_ID"], "--privateKey", str(key),
                               "--env", environment, "--source", SOURCE, "--baseBranch", base,
                               "--targetBranch", "HEAD", "--testLevel", TEST_LEVEL]
                    if args.mode == "validate":
                        command.append("--validateOnly")
                    command.append("deploy")
                    quiet_command(command, work, log, command_env, "SimpleSfCLI deployment")
                else:
                    login_url = ("https://login.salesforce.com" if environment == "PRODUCTION"
                                 else "https://test.salesforce.com")
                    quiet_command(["sf", "org", "login", "jwt", "--username", os.environ["SF_USERNAME"],
                                   "--client-id", os.environ["SF_CLIENT_ID"], "--jwt-key-file", str(key),
                                   "--instance-url", login_url, "--alias", "comparison-org", "--json"],
                                  work, log, command_env, "Salesforce JWT login")
                    # Hardis 8.20.1 forwards --agent to core sf, which rejects it.
                    # CI=true and the explicit authenticated target avoid prompts.
                    command = ["sf", "hardis:project:deploy:start", "--source-dir", SOURCE,
                               "--target-org", "comparison-org", "--test-level", TEST_LEVEL,
                               "--wait", "90"]
                    if args.mode == "validate":
                        command.append("--dry-run")
                    quiet_command(command, work, log, command_env, "Hardis deployment")
            finally:
                report["command_seconds"] = round(time.monotonic() - started, 3)
                if args.tool == "hardis":
                    # A login can partially succeed before returning an error.
                    try:
                        subprocess.run(["sf", "org", "logout", "--target-org", "comparison-org", "--no-prompt"],
                                       cwd=work, env=command_env, stdout=log, stderr=subprocess.STDOUT, timeout=60)
                    except (OSError, subprocess.TimeoutExpired):
                        pass


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--tool", required=True)
    parser.add_argument("--mode", required=True)
    parser.add_argument("--source-repo", required=True)
    parser.add_argument("--source-sha", required=True)
    parser.add_argument("--report", required=True)
    args = parser.parse_args()
    report = {"status": "failed"}
    started = time.monotonic()
    try:
        execute(args, report)
        report["status"] = "succeeded"
    except ComparisonError as error:
        report["message"] = str(error)
    except Exception:
        # Exception messages and tracebacks from third-party tools may contain credentials.
        report["message"] = "Comparison setup failed; check the source commit and runner setup."
    report["total_seconds"] = round(time.monotonic() - started, 3)
    content = json.dumps(report, indent=2) + "\n"
    Path(args.report).write_text(content)
    print(content, end="")
    if os.environ.get("GITHUB_STEP_SUMMARY"):
        with open(os.environ["GITHUB_STEP_SUMMARY"], "a") as summary:
            summary.write("### Salesforce deployment comparison\n\n```json\n" + content + "```\n")
    return 0 if report["status"] == "succeeded" else 1


if __name__ == "__main__":
    raise SystemExit(main())
