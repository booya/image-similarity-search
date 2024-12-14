FROM python:3.12-bullseye AS builder
ENV POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_IN_PROJECT=1 \
    POETRY_VIRTUALENVS_CREATE=1 \
    POETRY_CACHE_DIR=/tmp/poetry_cache
WORKDIR /app

# RUN python3 -m pip install pip setuptools && \
#     pip install poetry
RUN python3 -m pip install poetry
# TODO: maybe separate some dev/test dependencies to reduce image size?
COPY poetry.lock .
COPY pyproject.toml .
RUN poetry install --without dev --no-root

FROM python:3.12-slim-bullseye AS final
ENV VIRTUAL_ENV=/app/.venv \
    PATH="/app/.venv/bin:$PATH"
WORKDIR /app

COPY --from=builder ${VIRTUAL_ENV} ${VIRTUAL_ENV}
# RUN touch image-search.sqlite
# COPY scripts/ ./scripts/
# COPY e2e/ ./e2e/
# COPY tests/ ./tests/

COPY image_search/ ./image_search

EXPOSE 8000
# TODO: production server
ENTRYPOINT ["fastapi", "run", "image_search/app.py"]
# ENTRYPOINT ["/app/scripts/run-dev-mode.sh"]
