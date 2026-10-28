"""Credential-free contract checks using real Git snapshots and fake CLIs."""

import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest


RUNNER = Path(__file__).with_name("compare_salesforce.py")
FAKE_CLI = '''#!/usr/bin/env python3
import json, os, pathlib, stat, subprocess, sys
args = sys.argv[1:]
name = pathlib.Path(sys.argv[0]).name
stage = "login" if args[:3] == ["org", "login", "jwt"] else ("logout" if args[:2] == ["org", "logout"] else "deploy")
key_flag = "--jwt-key-file" if stage == "login" else "--privateKey"
key = pathlib.Path(args[args.index(key_flag) + 1]) if key_flag in args else None
record = {"name": name, "args": args, "stage": stage,
          "ci": os.environ.get("CI"),
          "files": sorted(str(p.relative_to(pathlib.Path.cwd())) for p in pathlib.Path.cwd().rglob("*") if p.is_file() and ".git" not in p.parts),
          "added": subprocess.check_output(["git", "diff", "--name-only", "HEAD~1...HEAD"], text=True).splitlines(),
          "key_mode": stat.S_IMODE(key.stat().st_mode) if key else None,
          "class_content": pathlib.Path("force-app/main/default/classes/Example.cls").read_text()}
with open(os.environ["TRACE_FILE"], "a") as trace:
    trace.write(json.dumps(record) + "\\n")
print("FAKE_ACCESS_TOKEN_DO_NOT_PUBLISH")
print(key.read_text() if key else os.environ.get("SF_JWT_KEY", ""))
sys.exit(1 if os.environ.get("FAKE_FAIL_STAGE") == stage else 0)
'''


class ComparisonTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.repo = self.root / "repo"
        self.repo.mkdir()
        self.git("init", "-q")
        self.git("config", "user.name", "Test")
        self.git("config", "user.email", "test@example.invalid")
        for name, content in {
            "sfdx-project.json": '{"packageDirectories":[{"path":"force-app","default":true}],"sourceApiVersion":"68.0"}',
            ".forceignore": "**/jsconfig.json\n",
            "force-app/main/default/classes/Example.cls": "public class Example {}",
            "force-app/main/default/classes/Example.cls-meta.xml": "<ApexClass/>",
            "config/server.key": "UNRELATED_COMMITTED_KEY_MUST_NOT_BE_COPIED",
        }.items():
            path = self.repo / name
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(content)
        self.git("add", ".")
        self.git("commit", "-qm", "fixture")
        self.sha = self.git("rev-parse", "HEAD").strip()
        # Local modifications and untracked files must never enter a deployment.
        (self.repo / "force-app/main/default/classes/Example.cls").write_text("LOCAL CHANGE")
        (self.repo / "force-app/main/default/classes/Local.cls").write_text("UNTRACKED")
        self.bin = self.root / "bin"
        self.bin.mkdir()
        for name in ("simpleSfCli", "sf"):
            path = self.bin / name
            path.write_text(FAKE_CLI)
            path.chmod(0o755)
        self.env = dict(os.environ, PATH=str(self.bin) + os.pathsep + os.environ["PATH"],
                        TRACE_FILE=str(self.root / "trace.jsonl"),
                        SF_USERNAME="fixture@example.invalid", SF_CLIENT_ID="fixture-client",
                        SF_JWT_KEY="PRIVATE_KEY_SENTINEL", SF_ENVIRONMENT="PRODUCTION",
                        RUNNER_TEMP=str(self.root))

    def git(self, *args):
        return subprocess.check_output(["git", "-C", str(self.repo), *args], text=True)

    def run_tool(self, tool="simplesfcli", mode="validate", sha=None, **env):
        report = self.root / (tool + "-report.json")
        result = subprocess.run(
            [sys.executable, str(RUNNER), "--tool", tool, "--source-repo", str(self.repo),
             "--source-sha", sha or self.sha, "--mode", mode, "--report", str(report)],
            env=dict(self.env, **env), text=True, capture_output=True,
        )
        data = json.loads(report.read_text()) if report.exists() else {}
        trace = self.root / "trace.jsonl"
        calls = [json.loads(line) for line in trace.read_text().splitlines()] if trace.exists() else []
        return result, data, calls

    def test_both_tools_use_same_committed_snapshot_and_validation(self):
        simple, simple_report, calls = self.run_tool()
        self.assertEqual(simple.returncode, 0, simple.stdout + simple.stderr)
        simple_call = calls[-1]
        self.assertIn("--validateOnly", simple_call["args"])
        self.assertEqual(simple_call["key_mode"], 0o600)
        hardis, hardis_report, calls = self.run_tool("hardis")
        self.assertEqual(hardis.returncode, 0, hardis.stdout + hardis.stderr)
        hardis_call = next(c for c in calls if c["args"][:1] == ["hardis:project:deploy:start"])
        self.assertIn("--dry-run", hardis_call["args"])
        self.assertEqual(simple_report["source_sha"], hardis_report["source_sha"])
        self.assertEqual(simple_report["input_sha256"], hardis_report["input_sha256"])
        self.assertEqual(simple_call["files"], hardis_call["files"])
        self.assertNotIn("config/server.key", simple_call["files"])
        self.assertNotIn("force-app/main/default/classes/Local.cls", simple_call["files"])
        self.assertEqual(simple_call["class_content"], "public class Example {}")
        self.assertEqual(hardis_call["class_content"], simple_call["class_content"])
        self.assertIn("force-app/main/default/classes/Example.cls", simple_call["added"])
        for result, report in ((simple, simple_report), (hardis, hardis_report)):
            visible = result.stdout + result.stderr + json.dumps(report)
            self.assertNotIn("PRIVATE_KEY_SENTINEL", visible)
            self.assertNotIn("FAKE_ACCESS_TOKEN_DO_NOT_PUBLISH", visible)
        self.assertEqual(list(self.root.glob("sf-compare-*")), [])
        for call in (simple_call, hardis_call):
            flag = "--testLevel" if call["name"] == "simpleSfCli" else "--test-level"
            self.assertEqual(call["args"][call["args"].index(flag) + 1], "RunLocalTests")

    def test_deploy_mode_omits_validation_flags(self):
        for tool in ("simplesfcli", "hardis"):
            result, report, calls = self.run_tool(tool, "deploy")
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertEqual(report["mode"], "deploy")
            deployment = [call for call in calls if call["stage"] == "deploy"][-1]
            self.assertNotIn("--validateOnly", deployment["args"])
            self.assertNotIn("--dry-run", deployment["args"])

    def test_hardis_uses_wrapper_compatible_noninteractive_flags(self):
        result, _, calls = self.run_tool("hardis")
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        deployment = next(c for c in calls if c["args"][:1] == ["hardis:project:deploy:start"])
        # Hardis 8.20.1 forwards --agent to the core sf command, which rejects it.
        # CI and the explicit target org avoid interactive authentication.
        self.assertNotIn("--agent", deployment["args"])
        self.assertNotIn("--skipauth", deployment["args"])
        self.assertEqual(deployment["ci"], "true")

    def test_failed_commands_fail_job_without_leaking_output_and_clean_up(self):
        for tool, stage in (("simplesfcli", "deploy"), ("hardis", "login"), ("hardis", "deploy")):
            result, report, calls = self.run_tool(tool, FAKE_FAIL_STAGE=stage)
            self.assertNotEqual(result.returncode, 0)
            self.assertEqual(report["status"], "failed")
            self.assertTrue(any(call["stage"] == stage for call in calls))
            visible = result.stdout + result.stderr + json.dumps(report)
            self.assertNotIn("PRIVATE_KEY_SENTINEL", visible)
            self.assertNotIn("FAKE_ACCESS_TOKEN_DO_NOT_PUBLISH", visible)
            self.assertEqual(list(self.root.glob("sf-compare-*")), [])

    def test_invalid_inputs_are_rejected_before_cli_execution(self):
        for kwargs in ({"sha": "master"}, {"mode": "preview"}, {"SF_ENVIRONMENT": "https://example.invalid"}, {"SF_JWT_KEY": ""}):
            result, _, calls = self.run_tool(**kwargs)
            self.assertNotEqual(result.returncode, 0)
            self.assertEqual(calls, [])

    def test_symlinks_are_rejected_before_authentication(self):
        (self.repo / "force-app/main/default/classes/link.cls").symlink_to("../../../../config/server.key")
        self.git("add", "force-app/main/default/classes/link.cls")
        self.git("commit", "-qm", "symlink")
        result, _, calls = self.run_tool(sha=self.git("rev-parse", "HEAD").strip())
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(calls, [])

    def test_missing_source_is_rejected_before_authentication(self):
        self.git("rm", "-rf", "force-app")
        self.git("commit", "-qm", "no source")
        result, _, calls = self.run_tool(sha=self.git("rev-parse", "HEAD").strip())
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(calls, [])


if __name__ == "__main__":
    unittest.main()
