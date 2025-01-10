import requests
from flask import Flask, render_template

app = Flask(__name__)

@app.route("/")
def get_random_quote():
    """Fetch a random quote from the API"""
    response = requests.get('https://dummyjson.com/quotes/random')
    quote = response.json()
    return render_template('index.html', quote=quote)

if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=8080)