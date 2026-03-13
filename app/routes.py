from flask import Blueprint, jsonify

main = Blueprint('main', __name__)

@main.route('/', methods=['GET'])
def index():
    return jsonify({
        "status": "ok",
        "message": "DevSecOps Pipeline Demo",
        "version": "1.0.0"
    })

@main.route('/health', methods=['GET'])
def health():
    return jsonify({"healthy": True}), 200