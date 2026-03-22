from flask import Blueprint, jsonify, make_response

main = Blueprint('main', __name__)

def add_security_headers(response):
    response.headers['X-Content-Type-Options'] = 'nosniff'
    response.headers['Content-Security-Policy'] = "default-src 'self'"
    response.headers['Permissions-Policy'] = 'geolocation=(), microphone=(), camera=()'
    response.headers['Cross-Origin-Resource-Policy'] = 'same-origin'
    response.headers['Cache-Control'] = 'no-store'
    return response

@main.route('/', methods=['GET'])
def index():
    response = make_response(jsonify({
        "status": "ok",
        "message": "DevSecOps Pipeline Demo",
        "version": "1.0.0"
    }))
    return add_security_headers(response)

@main.route('/health', methods=['GET'])
def health():
    response = make_response(jsonify({"healthy": True}), 200)
    return add_security_headers(response)# trigger
