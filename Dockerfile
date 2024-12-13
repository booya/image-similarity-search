FROM python:3.12-slim-bullseye
WORKDIR /app
# RUN python3 -m pip install pip setuptools && \
#     pip install poetry
RUN python3 -m pip install poetry
# TODO: maybe separate some dev/test dependencies to reduce image size?
COPY poetry.lock .
COPY pyproject.toml .
RUN poetry install

COPY scripts/ ./scripts/
COPY e2e/ ./e2e/
COPY tests/ ./tests/
COPY image_search/ ./image_search/

EXPOSE 8000
# TODO: production server
ENTRYPOINT ["/app/scripts/run-dev-mode.sh"]
