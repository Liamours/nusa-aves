"""Loads ../model/CustomClassifier.tflite and runs inference.

Pipeline: preprocess -> inference -> postprocess. There's no separate
feature-extraction step because this tflite graph is BirdNET's embedding
extractor and the custom classifier head merged into one model — it takes
raw audio in and gives class scores out.

Preprocessing (mono, 48kHz, padded/cropped to 3s) matches app-mobile's
AudioProcessor. Raw model output is pre-sigmoid logits (unbounded, can be
negative — verified empirically, not documented anywhere), so postprocess
applies a sigmoid to get an actual 0-1 confidence. BirdNET custom
classifiers are multi-label (independent per-class sigmoid), not softmax,
so top-k confidences don't sum to 1 and that's expected.
"""
import librosa
import numpy as np
import tensorflow as tf

from audio_utils import pad_or_crop, sigmoid, top_k_predictions

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

    def preprocess(self, audio_path: str) -> np.ndarray:
        audio, _ = librosa.load(audio_path, sr=SAMPLE_RATE, mono=True)
        return pad_or_crop(audio, TARGET_LENGTH).astype(np.float32)

    def run_inference(self, features: np.ndarray) -> np.ndarray:
        self.interpreter.set_tensor(self.input_detail["index"], features.reshape(self.input_detail["shape"]))
        self.interpreter.invoke()
        return self.interpreter.get_tensor(self.output_detail["index"]).reshape(-1)

    def postprocess(self, logits: np.ndarray, top_k: int) -> list[dict]:
        return top_k_predictions(sigmoid(logits), self.labels, top_k)

    def predict_file(self, audio_path: str, top_k: int = 5) -> list[dict]:
        features = self.preprocess(audio_path)
        logits = self.run_inference(features)
        return self.postprocess(logits, top_k)
