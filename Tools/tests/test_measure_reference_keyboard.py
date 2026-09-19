"""Round-trip tests for the Phase 14 reference keyboard measurement tool.

The tests paint a synthetic 430 x 932 pt keyboard using the measured contract and check
that the tool recovers the same frames, so CI can verify the measurement without the
original device recordings.
"""
from unittest import TestCase

import numpy as np
from PIL import Image, ImageDraw

from Tools.measure_reference_keyboard import measure

SCALE = 3
BACKGROUND = (0xDD, 0xDE, 0xE2)
WHITE = (0xFF, 0xFF, 0xFF)
GRAY = (0xAF, 0xB4, 0xBD)

T26_ROWS = [
    (638.33, [5 + index * 42.667 for index in range(10)], 36, WHITE),
    (694.33, [26.33 + index * 42.667 for index in range(9)], 36, WHITE),
    (750.33, [5] + [69.33 + index * 42.667 for index in range(7)] + [377], 36, WHITE),
    (806.33, [5, 90.67, 133, 294, 340], 36, WHITE),
]
T26_BOTTOM_WIDTHS = [79.33, 36, 154.33, 39.67, 85.33]
T26_BOTTOM_KINDS = [GRAY, WHITE, WHITE, WHITE, GRAY]


def paint_keyboard() -> np.ndarray:
    image = Image.new("RGB", (430 * SCALE, 932 * SCALE), BACKGROUND)
    draw = ImageDraw.Draw(image)
    for y, origins, width, colour in T26_ROWS:
        for index, x in enumerate(origins):
            if y == 806.33:
                key_width = T26_BOTTOM_WIDTHS[index]
                fill = T26_BOTTOM_KINDS[index]
            elif y == 750.33 and index in (0, 8):
                key_width, fill = 48.33, GRAY
            else:
                key_width, fill = width, colour
            draw.rectangle(
                [
                    round(x * SCALE),
                    round(y * SCALE),
                    round((x + key_width) * SCALE) - 1,
                    round((y + 46) * SCALE) - 1,
                ],
                fill=fill,
            )
    return np.asarray(image, dtype=np.int16)


class MeasureReferenceKeyboardTests(TestCase):
    def setUp(self):
        self.result = measure(paint_keyboard())
        self.rows = {row["y"]: row for row in self.result["rows"]}

    def test_frame_size_is_reported_in_pixels(self):
        self.assertEqual(self.result["size"], [1290, 2796])

    def test_four_letter_rows_are_found_at_measured_offsets(self):
        found = sorted(self.rows)
        for measured, actual in zip([638.33, 694.33, 750.33, 806.33], found):
            self.assertAlmostEqual(actual, measured, delta=0.4)
        for row in self.rows.values():
            self.assertAlmostEqual(row["height"], 46, delta=1.5)

    def test_second_row_is_centred(self):
        keys = self.rows[694.33]["keys"]
        self.assertEqual(len(keys), 9)
        self.assertAlmostEqual(keys[0]["x"], 26.33, delta=1.0)
        last = keys[-1]
        self.assertAlmostEqual(last["x"] + last["width"], 403.67, delta=1.0)

    def test_26_key_bottom_row_matches_measured_widths(self):
        keys = self.rows[806.33]["keys"]
        self.assertEqual(len(keys), 5)
        for key, width in zip(keys, T26_BOTTOM_WIDTHS):
            self.assertAlmostEqual(key["width"], width, delta=1.5)
        self.assertEqual([key["kind"] for key in keys],
                         ["gray", "white", "white", "white", "gray"])
