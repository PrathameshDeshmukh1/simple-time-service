from flask import Flask
import socket

app = Flask(__name__)

@app.route("/")
def home():
    host_name = socket.gethostname()
    return f"Hello from Kubernetes! Pod: {host_name}"

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000)
