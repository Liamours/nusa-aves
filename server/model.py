"""Loads ../model/CustomClassifier.tflite and runs inference.

Preprocessing matches app-mobile's AudioProcessor: mono, 48kHz, padded/
cropped to 3s. Raw model output is pre-sigmoid logits (unbounded, can be
negative — verified empirically, not documented anywhere), so a sigmoid
is applied here to get an actual 0-1 confidence. BirdNET custom classifiers
are multi-label (independent per-class sigmoid), not softmax, so top-k
confidences don't sum to 1 and that's expected.
"""
import librosa
import numpy as np
import tensorflow as tf

from audio_utils import pad_or_crop, top_k_predictions

MODEL_DIR = "../model"
SAMPLE_RATE = 48000
CLIP_SECONDS = 3.0
TARGET_LENGTH = int(SAMPLE_RATE * CLIP_SECONDS)


class Classifier:
    def __init__(self, model_dir: str = MODEL_DIR):
        self.interpreter = tf.lite.Interpreter(model_path=f"{model_dir}/CustomClassifier.tflite")
        self.interpreter.allocate_tensors()
        self.input_detail = self.interpreter.get_input_details()[0]
        self.output_detail = self.interpreter.get_output_details()[0]
        with open(f"{model_dir}/CustomClassifier_Labels.txt", encoding="utf-8") as f:
            self.labels = [line.strip() for line in f if line.strip()]

    def predict_file(self, audio_path: str, top_k: int = 5) -> list[dict]:
        audio, _ = librosa.load(audio_path, sr=SAMPLE_RATE, mono=True)
        audio = pad_or_crop(audio, TARGET_LENGTH).astype(np.float32)
        self.interpreter.set_tensor(self.input_detail["index"], audio.reshape(self.input_detail["shape"]))
        self.interpreter.invoke()
        logits = self.interpreter.get_tensor(self.output_detail["index"]).reshape(-1)
        scores = 1 / (1 + np.exp(-logits))
        return top_k_predictions(scores, self.labels, top_k)
