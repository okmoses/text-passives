# text-passives
[![CircleCI](https://circleci.com/gh/MosesMendoza/text-passives.svg?style=shield)](https://circleci.com/gh/MosesMendoza/text-passives)

Goal: a simple, lightweight service for:
- Detecting the passive phrases within a body of text

This service doesn't have any logic other than to wrap logic from SpaCy to detect and return the use of passive voice within text. This runs [spacy](https://github.com/explosion/spaCy) as an API behind FastAPI in a docker container. The supported action is `passives`. Contributions are welcome. Note this doesn't do anything with certs/ssl/tls/https. Setting up a cluster for ssl termination isn't in scope here.

## Container
[temporary update]
When Python 3.9 images are released by FastAPI/tiangolo, this will be reverted to use those containers. However, as of writing this, the logic uses a series of Dockerfile modifications from those images/Dockerfiles to create a FastAPI container based on Python 3.9.

Builds on the FastAPI official container image from https://hub.docker.com/r/tiangolo/uvicorn-gunicorn-fastapi/ per the FastAPI [deployment docs](https://fastapi.tiangolo.com/deployment/docker) for Python 3.6.

Current image tag: python:3.9.4

## spaCy
SpaCy is an NLP library written in Python. See [spacy docs](https://spacy.io/usage/spacy-101). From spaCy, the library is "industrial-strength natural language processing in python."[source](https://github.com/explosion/spaCy)

Current SpaCy version: 3.0.6

## Run tests

    python -m venv env
    . env/bin/activate
    pip install -r requirements_dev.txt
    python -m spacy download en_core_web_lg
    pytest


## Build/run locally

    docker build -t text-passives-image .
    docker run -d --name text-passives -p 1234:80 text-passives-image // (replace 1234 with the port you want the container to expose)


## Stop/destroy

    docker stop text-passives
    docker rm text-passives


## Endpoints
### passives
Get the passive voice phrases for a given body of text. Returns an array of mixed-type arrays, where each array represents an instance of passive voice. The first element is a string, the second element is the start-index of the phrase (inclusive) and the third element is the end-index of the phrase (exclusive) where indexing count is on words and punctuation.

    Endpoint: /passives
    Action: POST
    Example JSON body: '{"text": "The tub is filled with juice. Food ate my bear." }'
    Expected Response:
      { "passives" : [[ "tub is filled", 1, 4 ]] }

Example:

    curl -X POST -H "Content-Type: application/json" -d '{"text": "The tub is filled with juice. Food ate my bear."}' http://localhost:1234/passives
