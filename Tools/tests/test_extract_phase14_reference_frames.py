from pathlib import Path
import sys
import tempfile
import unittest
from types import SimpleNamespace
from unittest.mock import MagicMock, patch


ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "Tools"))

from extract_phase14_reference_frames import extract_capture, load_manifest, validate_manifest


MANIFEST = ROOT / "ReverseEngineering" / "Phase14" / "reference_capture_manifest.json"


class ManifestTests(unittest.TestCase):
    def test_manifest_has_exact_phase14_ids(self):
        manifest = load_manifest(MANIFEST)
        self.assertEqual(
            [capture["id"] for capture in manifest["captures"]],
            ["01", "02", "04", "06", "07", "08", "10", "14", "23", "27"],
        )

    def test_manifest_is_portable_and_valid(self):
        manifest = load_manifest(MANIFEST)
        self.assertEqual(validate_manifest(manifest), [])
        for capture in manifest["captures"]:
            self.assertFalse(Path(capture["video"]).is_absolute())
            self.assertEqual(capture["expectedPixels"], [1290, 2796])

    def test_duplicate_id_is_rejected(self):
        manifest = load_manifest(MANIFEST)
        manifest["captures"].append(dict(manifest["captures"][0]))
        self.assertIn("duplicate capture id: 01", validate_manifest(manifest))

    def test_unapproved_or_reordered_ids_are_rejected(self):
        manifest = load_manifest(MANIFEST)
        manifest["captures"][0]["id"] = "99"
        self.assertIn("unexpected Phase14 capture ids", validate_manifest(manifest)[-1])


class ExtractionTests(unittest.TestCase):
    def capture(self, **updates):
        capture = {
            "id": "01",
            "scene": "keyboard26-light",
            "video": "recording.mp4",
            "timestampSeconds": 1.0,
            "expectedPixels": [1290, 2796],
        }
        capture.update(updates)
        return capture

    def test_invalid_timestamp_is_rejected_before_media_lookup(self):
        with tempfile.TemporaryDirectory() as directory:
            with self.assertRaisesRegex(ValueError, "invalid timestamp: 01"):
                extract_capture(
                    self.capture(timestampSeconds="not-a-number"),
                    Path(directory),
                    Path(directory) / "output",
                    "ffmpeg",
                )

    def test_missing_media_is_rejected(self):
        with tempfile.TemporaryDirectory() as directory:
            with self.assertRaisesRegex(FileNotFoundError, "missing media"):
                extract_capture(self.capture(), Path(directory), Path(directory) / "output", "ffmpeg")

    def test_ffmpeg_failure_is_rejected(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "recording.mp4").touch()
            result = SimpleNamespace(returncode=1, stderr="ffmpeg broke", stdout="")
            with patch("extract_phase14_reference_frames.subprocess.run", return_value=result):
                with self.assertRaisesRegex(RuntimeError, "extraction failed: 01: ffmpeg broke"):
                    extract_capture(self.capture(), root, root / "output", "ffmpeg")

    def test_wrong_png_dimensions_are_rejected(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "recording.mp4").touch()
            result = SimpleNamespace(returncode=0, stderr="", stdout="")
            image = MagicMock()
            image.__enter__.return_value.size = (1, 2)
            with patch("extract_phase14_reference_frames.subprocess.run", return_value=result):
                with patch("PIL.Image.open", return_value=image):
                    with self.assertRaisesRegex(ValueError, "wrong dimensions: 01"):
                        extract_capture(self.capture(), root, root / "output", "ffmpeg")
