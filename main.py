from flask import Flask, request as req, render_template

from gevent.pywsgi import WSGIServer

from flask_cors import CORS, cross_origin
import base64
import json

from rag import getRag 
from gen import samba
from speech import speak
import os 

# logging.basicConfig(level=logging.DEBUG)

app = Flask(__name__)
# run_with_ngrok(app)
app.config['SECRET_KEY'] = 'secret!'
app.config['CORS_HEADERS'] = 'Content-Type'

cors = CORS(app, resources={r"/static/*": {"origins": "*"}})


@app.route('/')
@cross_origin()
def index():
    return render_template('index.html')


@app.route('/file', methods=['POST'])
@cross_origin()
def handle_file():

    bytes = base64.b64decode(req.json["file"])
    with open('data/data.pdf', 'wb') as file:
        file.write(bytes)


    return {"status":200}

@app.route('/rag', methods=['POST'])
@cross_origin()
def handle_rag():

    result = getRag(req.json["query"])

    return str(result)

@app.route('/samba', methods=['POST'])
@cross_origin()
def handle_nim():

    result = samba(req.json["model"], req.json["query"])

    print((result))

    return str(result)


@app.route('/speech', methods=['POST'])
@cross_origin()
def handle_speech():

    result = speak(req.json["text"])

    with open("speech/audio.wav", 'rb') as file:
        binary_data = file.read()  # Read the entire file
        result["audio"] = base64.b64encode(binary_data).decode('utf-8')
    
    print(type(result["audio"]))

    return json.dumps(result)


# socketio.run(app, host="0.0.0.0", port=5000, debug=False)
# app.run(host="0.0.0.0", port=5000, debug=False)

http_server = WSGIServer(('0.0.0.0', 5000), app)
http_server.serve_forever()
