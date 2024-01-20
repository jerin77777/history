from openai import OpenAI
import os
from flask_socketio import emit
import json

key = "your_key"
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
