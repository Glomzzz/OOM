"""Production staging must not invalidate Typsite's output/cache ownership."""
import importlib.util
import subprocess
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[2]
spec = importlib.util.spec_from_file_location("oom_build", ROOT / "scripts/build.py")
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


class ProductionBuildTests(unittest.TestCase):
    def test_postprocessing_is_separate_and_obsolete_fragments_are_removed(self):
        with tempfile.TemporaryDirectory() as directory:
            project = Path(directory)
            pages = project / ".github/pages"
            pages.mkdir(parents=True)
            (pages / "404.html").write_text("not found")
            (pages / "_headers").write_text("/_assets/*\n  Cache-Control: public, max-age=31536000, immutable\n")
            raw = project / ".cache/site"
            raw.mkdir(parents=True)
            (raw / "index.html").write_text("raw")
            for name in (".typsite.lock", ".typsite-outputs.json"):
                (raw / name).write_text("keep")
            output = project / "publish"
            (output / "_embeds").mkdir(parents=True)
            (output / "_embeds/stale.html").write_text("stale")
            before = {p.name: (p.read_bytes(), p.stat().st_mtime_ns) for p in raw.iterdir()}

            def run(command, **kwargs):
                if "optimize-assets.py" in command[-2]:
                    (Path(command[-1]) / "index.html").write_text("optimized")
                elif "cache-bust.py" in command[-2]:
                    (Path(command[-1]) / "index.html").write_text("versioned")
                elif "lazy-embeds.py" in command[-2]:
                    (Path(command[-1]) / "index.html").write_text("lazy")
                else:
                    self.assertIn(".cache/site", command)
                return subprocess.CompletedProcess(command, 0)

            with patch.object(module.subprocess, "run", side_effect=run):
                module.build(project, "typsite")
            self.assertEqual((output / "index.html").read_text(), "lazy")
            self.assertEqual((output / "404.html").read_text(), "not found")
            self.assertEqual((output / "_headers").read_bytes(), (pages / "_headers").read_bytes())
            self.assertFalse((raw / "404.html").exists())
            self.assertFalse((raw / "_headers").exists())
            self.assertFalse((output / "_embeds/stale.html").exists())
            self.assertFalse((output / ".typsite-outputs.json").exists())
            self.assertEqual(before, {p.name: (p.read_bytes(), p.stat().st_mtime_ns) for p in raw.iterdir()})

    def test_failure_keeps_previous_deployment(self):
        for failed_stage in ("typsite", "optimize-assets.py", "cache-bust.py", "lazy-embeds.py", "host-files"):
            with self.subTest(stage=failed_stage), tempfile.TemporaryDirectory() as directory:
                project = Path(directory)
                raw = project / ".cache/site"
                raw.mkdir(parents=True)
                (raw / "index.html").write_text("new")
                output = project / "publish"
                output.mkdir()
                (output / "index.html").write_text("previous")

                def run(command, failed_stage=failed_stage, **kwargs):
                    if any(failed_stage in arg for arg in command):
                        raise subprocess.CalledProcessError(1, command)
                    return subprocess.CompletedProcess(command, 0)

                # Missing host files fail before the existing deployment is moved.
                expected = FileNotFoundError if failed_stage == "host-files" else subprocess.CalledProcessError
                with patch.object(module.subprocess, "run", side_effect=run), self.assertRaises(expected):
                    module.build(project, "typsite")
                self.assertEqual((output / "index.html").read_text(), "previous")

    def test_symlinked_build_roots_are_rejected(self):
        for name in (".cache", "publish"):
            with self.subTest(root=name), tempfile.TemporaryDirectory() as directory:
                project = Path(directory)
                target = project / "unrelated"
                target.mkdir()
                (project / name).symlink_to(target, target_is_directory=True)
                with self.assertRaises(ValueError), patch.object(module.subprocess, "run") as run:
                    module.build(project, "typsite")
                run.assert_not_called()


if __name__ == "__main__":
    unittest.main()
