from flask import Flask, request, Response
import subprocess
import threading

app = Flask(__name__)

script_status = ""

def run_script():
    global script_status
    script_status = "running"
    subprocess.run(["wget", "https://raw.githubusercontent.com/SalehGovahi/EmperorPenguinProject/Phase3/Phase3RunScript.sh"])
    subprocess.run(["sudo", "bash", "Phase3RunScript.sh"])
    script_status = "finished"

def rollback() :
    subprocess.run(["wget", "https://raw.githubusercontent.com/SalehGovahi/EmperorPenguinProject/Phase3/Phase3RollBackAll.sh"])
    subprocess.run(["sudo", "bash", "Phase3RollBackAll.sh"])

@app.route('/run-script/', methods=['GET'])
def start_script():
    global script_status
    if script_status == "running":
        return Response("Script is running", status=102)
    elif script_status == "finished":
        return Response("Script has finished running", status=102)
    else:
        threading.Thread(target=run_script).start()
        return Response("Script started running", status=102)

@app.route('/check-script/', methods=['GET'])
def check_script():
    global script_status
    if script_status == "running":
        return Response("Script is running", status=102)
    elif script_status == "finished":
        return Response("Script has finished running", status=201)
    else:
        return Response("Script status is unknown", status=404)

@app.route('/rollback/', methods=['GET'])
def check_script():
    threading.Thread(target=run_script).start()
    return Response("Rollback all configurations started", status=200)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)
