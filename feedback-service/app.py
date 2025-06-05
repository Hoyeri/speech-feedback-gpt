# feedback-service/app.py
from flask import Flask, request, jsonify
from flask_cors import CORS
from openai import OpenAI
import os

app = Flask(__name__)
CORS(app)

client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

@app.route("/feedback", methods=["POST"])
def get_feedback():
    data = request.get_json()
    text = data.get("text", "")

    if not text:
        return jsonify({"error": "No text provided"}), 400

    try:
        response = client.chat.completions.create(
            model="gpt-4o",
            messages=[
                {"role": "system", "content": """당신은 너는 한국어 말하기 평가 전문가입니다. 주어진 한국어 학습자의 발화 전사문을 아래 기준에 따라 평가하고, 격려해주세요.
            [내용 및 과제 수행]
            1. 적절한 내용으로 표현했는가?
            2. 과제의 내용이 풍부하고 구체적인가?
            3. 담화 구성이 잘 이루어져 있는가?
             
            [언어 사용]
            1. 적합한 어휘를 사용해 의도하는 바를 표현했는가?
            2. 어휘와 표현을 다양하게 사용하였는가?
            3. 문법이나 담화 오류가 자주 나타나는가? 단, 문장부호 오류는 평가하지 않는다. """},
                {"role": "user", "content": text}
            ]
        )
        result = response.choices[0].message.content
        return jsonify({"feedback": result})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5002)
