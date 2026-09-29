# The book club shelves, fetched the same way the Dockerfile does at build.
shelf:
    curl -fsS https://api.dungeonbooks.com/v1/books -o content/shelves/book-club.json
