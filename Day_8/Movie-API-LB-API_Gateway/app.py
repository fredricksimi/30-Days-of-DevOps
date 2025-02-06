import requests, os
from flask import Flask, jsonify

app = Flask(__name__)

API_KEY = "b7c76c452048ffd45da7273b7620bb43"

@app.route('/', methods=['GET'])
def get_trending_movies():
    url = f"https://api.themoviedb.org/3/trending/movie/day?api_key={API_KEY}&language=en-US"
    try:
        response = requests.get(url)
        data = response.json()
        movies = [{"title": movie['title'], "release_date": movie["release_date"]} for movie in data['results']]
        return jsonify({"message": "Trending movies fetched successfully.", "movies": movies}), 200
    
    except Exception as e:
        return jsonify({"message": "An error occurred.", "error": str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)