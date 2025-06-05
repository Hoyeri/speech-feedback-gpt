# whisper-service/app.py
from flask import Flask, request, jsonify
from flask_cors import CORS
import whisper
import os
import librosa
import torch
import requests

app = Flask(__name__)
CORS(app)

UPLOAD_FOLDER = "uploads"
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

device = "cuda" if torch.cuda.is_available() else "cpu"
model = whisper.load_model("small", device=device)

FEEDBACK_SERVICE_URL = "http://feedback-service:5002/feedback"

@app.route("/transcribe", methods=["POST"])
def transcribe():
    if "audio" not in request.files:
        return jsonify({"error": "No audio file provided"}), 400

    audio = request.files["audio"]
    filename = audio.filename
    file_path = os.path.join(UPLOAD_FOLDER, filename)
    audio.save(file_path)

    try:
        result = model.transcribe(file_path, fp16=False)
        transcript = result["text"]

        feedback_response = requests.post(
            FEEDBACK_SERVICE_URL,
            json={"text": transcript},
            timeout=30
        )

        if feedback_response.status_code != 200:
            return jsonify({"error": "Failed to get feedback", "detail": feedback_response.text}), 500

        feedback_data = feedback_response.json()
        return jsonify({
            "text": transcript,
            "feedback": feedback_data.get("feedback", ""),
            "audio_path": file_path
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5001)
