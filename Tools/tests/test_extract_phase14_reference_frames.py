from pathlib import Path
import sys
import unittest


ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "Tools"))

from extract_phase14_reference_frames import load_manifest, validate_manifest


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
