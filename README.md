# text-passives
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
    python -m spacy download en_core_web_md
    pytest


## Build/run locally
This build uses en_core_web_md. Its also possible to use en_core_web_lg but
note that the en_core_web_lg trained model is over 700MB, so you may need to
increase docker resource allocation for build to succeed

    docker build -t text-passives-image .
    docker run -d --name text-passives -p 1234:80 text-passives-image // (replace 1234 with the port you want the container to expose)


## Stop/destroy

    docker stop text-passives
    docker rm text-passives


## Endpoints
### passives
Get the passive voice phrases for a given body of text. Returns an array of mixed-type arrays, where each array represents an instance of passive voice. The first element is a string, the second element is the start-index of the first phrase token (inclusive) and the third element is the end-index of the last phrase token (exclusive) where indexing count is on tokens in the parsed text body (ie, words & punctuation)

    Endpoint: /passives
    Action: POST
    Example JSON body: '{"text": "The tub is filled with juice. Food ate my bear." }'
    Expected Response:
      { "passives" : [[ "tub is filled", 1, 4 ]] }

Example:

    curl -X POST -H "Content-Type: application/json" -d '{"text": "The tub is filled with juice. Food ate my bear."}' http://localhost:1234/passives

## Releasing
### \[DEV RELEASE\] Building & Releasing the text-passives image to DEV AWS Fargate
Locate the current/latest version and increment w/a new tag

      # list images to find latest version tag of image text-passives
      docker images

Make sure your local aws credentials are for a user with authorization to push images

Obtain login authorization to push to ECR

  1) Log into the AWS Console in dev or prod (depending on what kind of release)
  2) Open ECR
  3) Select 'repositories' in left and open repository for image to be released
  4) Click the 'View push commands' button in the upper right
  5) Follow step 1 to authenticate the docker client to AWS
  6) Copy the commands to tag the image for pushing to AWS ECR

Build and release the image

      # clean the repository
      git clean -xffd; \

      # build the image
      export DOCKER_BUILDKIT=1 ;
      docker build --progress plain \
                   --platform linux/amd64 \
                   --tag text-passives:<version> .

      # tag image for release to AWS using command copied in (6) above
      docker tag text-passives:<version> <aws repository string>/text-passives:<version>

      # push the image to AWS using the command copied in (6) above
      docker push <aws repository string>/text-passives:<version>

