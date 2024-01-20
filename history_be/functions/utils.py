from openai import OpenAI
import os
from flask_socketio import emit
import json

keys = ["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", "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"]
key = keys[1]
os.environ["OPENAI_API_KEY"] = key

client = OpenAI(
    api_key=key,
)

def gen(ans):
    chat_completion = client.chat.completions.create(
        messages=[
            {
                "role": "user",
                "content": ans,
            }
        ],
        model="gpt-3.5-turbo",
    )

    return chat_completion.choices[0].message.content



def send(socketId,event,data):
    print("sending data")
    emit(event, data, room=socketId, namespace="/")
