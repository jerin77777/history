import json

from flask import Flask, request as req, render_template,make_response
from flask_socketio import SocketIO, emit
from functions.history import *
from db_models import  *
import os
from werkzeug.utils import secure_filename
from flask_cors import CORS, cross_origin
import time
import base64
import logging
import threading


# logging.basicConfig(level=logging.DEBUG)

app = Flask(__name__, static_url_path='/static')
# run_with_ngrok(app)
app.config['SECRET_KEY'] = 'secret!'
app.config['CORS_HEADERS'] = 'Content-Type'

# cors = CORS(app, resources={r"/static/*": {"origins": "*"}})

# cors = CORS(app, resources={r"/api/*": {"origins": "*"}})
cors = CORS(app, resources={r"/static/*": {"origins": "*"}})

socketio = SocketIO(app, cors_allowed_origins="*", async_mode='threading')


@app.route('/')
@cross_origin()
def index():
    return render_template('index.html')


@app.route('/file', methods=['POST'])
@cross_origin()
def handle_form():
    print("file api")
    file = req.files['file']
    fileName = json.loads(file.filename)["name"]
    sessionId = json.loads(file.filename)["id"]
    fileName = str(time.time())  + ".." + fileName
    print(fileName)

    path = os.path.join(os.getcwd(), 'data', secure_filename(fileName))
    file.save(path)
    print("saved")

    file_size = os.path.getsize('./data/'+secure_filename(fileName))

    Files.insert(fileName=json.loads(file.filename)["name"],fileSize=file_size,url="/data/" + secure_filename(fileName),sessionId=sessionId).execute()

    result = make_response("/data/" + secure_filename(fileName))
    result.headers['Content-type'] = 'text/xml'

    # result =
    return result

@app.route('/get_files', methods=['POST'])
@cross_origin()
def handle_get_files():
    query = Files.select(Files.fileId,Files.fileName,Files.fileSize,Files.url).where(Files.sessionId == req.json["sessionId"])
    files = list(query.dicts())

    return files
@app.route('/prompt', methods=['POST'])
@cross_origin()
def handle_prompt():
    result = {"status":404}

    gotAns = False

    fileId = Files.select(Files.fileId).where(Files.url == req.json["file"]).namedtuples().first()[0]
    # query = Questions.select(Questions.ans).where(Questions.question == req.json["query"]).namedtuples().first()
    query = Questions.select(Questions.ans).where(fn.Lower(Questions.question) == str(req.json["query"]).lower()).where(Questions.fileId == fileId).namedtuples().first()
    if query is not None:
        return query[0]
    print("querying for")
    print(req.json["socket_id"])
    result = get_history(req.json["socket_id"],req.json["file"],req.json["query"])
    gotAns = True


    if gotAns:
        Questions.insert(question=req.json["query"],ans=result, fileId=fileId).execute()

    return result


@socketio.on('disconnect')
def test_disconnect():
    print('Client disconnected new')
    # delete_socket(req.sid)
    print(req.sid)

def startServer():
    socketio.run(app, host="0.0.0.0", port=5000, debug=False,allow_unsafe_werkzeug=True )

if __name__ == '__main__':
    # startServer()
    t1 = threading.Thread(target=startServer)
    t2 = threading.Thread(target=load)

    t1.start()
    t2.start()

    t1.join()
    t2.join()

