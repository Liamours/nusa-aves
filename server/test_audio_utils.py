import numpy as np

from audio_utils import pad_or_crop, top_k_predictions


def test_pad_or_crop():
    assert list(pad_or_crop(np.array([1.0, 2.0]), 5)) == [1.0, 2.0, 0.0, 0.0, 0.0]
    assert list(pad_or_crop(np.array([1.0, 2.0, 3.0, 4.0]), 2)) == [1.0, 2.0]
    assert list(pad_or_crop(np.array([1.0, 2.0]), 2)) == [1.0, 2.0]


def test_top_k_predictions():
    scores = np.array([0.1, 0.9, 0.3, 0.05])
    labels = ["a", "b", "c", "d"]
    result = top_k_predictions(scores, labels, k=2)
    assert result == [
        {"species": "b", "confidence": 0.9},
        {"species": "c", "confidence": 0.3},
    ]


if __name__ == "__main__":
    test_pad_or_crop()
    test_top_k_predictions()
    print("ok")
