import numpy as np


def pad_or_crop(audio: np.ndarray, target_length: int) -> np.ndarray:
    if len(audio) < target_length:
        return np.pad(audio, (0, target_length - len(audio)))
    return audio[:target_length]


def top_k_predictions(scores: np.ndarray, labels: list[str], k: int) -> list[dict]:
    top = np.argsort(scores)[::-1][:k]
    return [{"species": labels[i], "confidence": float(scores[i])} for i in top]
