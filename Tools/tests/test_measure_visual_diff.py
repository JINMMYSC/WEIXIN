from pathlib import Path
import sys
import unittest
from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "Tools"))
from measure_visual_diff import compare_images, build_review


class VisualDiffTests(unittest.TestCase):
    def test_masked_pixels_are_excluded_from_metrics(self):
        reference = Image.new("RGBA", (16, 16), "white")
        replica = Image.new("RGBA", (16, 16), "white")
        for x in range(8, 12):
            for y in range(8, 12):
                replica.putpixel((x, y), (0, 0, 0, 255))
        metrics = compare_images(reference, replica, masks=[(8, 8, 4, 4)], threshold=12)
        self.assertEqual(metrics["excluded_pixel_count"], 16)
        self.assertEqual(metrics["measured_pixel_count"], 240)
        self.assertEqual(metrics["pixels_over_threshold_fraction"], 0.0)

    def test_review_is_incomplete_without_both_images(self):
        reference = Image.new("RGBA", (2, 2), "white")
        review = build_review(scene_id="01", reference=reference, replica=None, metrics=None)
        self.assertEqual(review["status"], "incomplete")
        self.assertIn("REP", review["missing"])

    def test_strict_ineligible_reference_never_reaches_review_state(self):
        image = Image.new("RGBA", (2, 2), "white")
        metrics = compare_images(image, image)
        review = build_review("01", image, image, metrics, strict_eligible=False)
        self.assertEqual(review["status"], "incomplete")
        self.assertIn("canonical-reference", review["missing"])


if __name__ == "__main__":
    unittest.main()
