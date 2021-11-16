#  Note: Portions of this Dockerfile were taken from repositories licensed
#  under the following license and copyright.
#  Repositories:
#     https://github.com/tiangolo/uvicorn-gunicorn-docker
#     https://github.com/tiangolo/uvicorn-gunicorn-fastapi-docker
#
#  License:
#  The MIT License (MIT)
#
#  Copyright (c) 2019 Sebastián Ramírez
#
#  Permission is hereby granted, free of charge, to any person obtaining a copy
#  of this software and associated documentation files (the "Software"), to deal
#  in the Software without restriction, including without limitation the rights
#  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#  copies of the Software, and to permit persons to whom the Software is
#  furnished to do so, subject to the following conditions:
#
#  The above copyright notice and this permission notice shall be included in
#  all copies or substantial portions of the Software.
#
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#  THE SOFTWARE.

FROM python:3.9.4

# This is used when deploying to AWS or some other system where a port other
# than 80 is needed
ARG API_LISTEN_PORT
ENV API_LISTEN_PORT=${API_LISTEN_PORT:-80}

RUN echo "Configuring service to listen on port '${API_LISTEN_PORT}'"

RUN pip install --no-cache-dir "uvicorn[standard]" gunicorn

COPY ./docker-support/start.sh /start.sh
RUN chmod +x /start.sh

COPY ./docker-support/gunicorn_conf.py /gunicorn_conf.py

COPY ./docker-support/start-reload.sh /start-reload.sh
RUN chmod +x /start-reload.sh

COPY ./docker-support/app /app
WORKDIR /app

ENV PYTHONAPP=/app

# This is not used inside the AWS task unless the container is exposed publicly
EXPOSE ${API_LISTEN_PORT}

CMD ["/start.sh"]

RUN pip install --no-cache-dir fastapi

COPY requirements.txt /

# Set up build deps
RUN pip install pip setuptools wheel

RUN pip install -r /requirements.txt

# Sorry container size
RUN python -m spacy download en_core_web_md

COPY ./app /app/app
