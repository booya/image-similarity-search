##
## Base build
##
FROM python:3.12-bullseye AS builder
ENV POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_IN_PROJECT=1 \
    POETRY_VIRTUALENVS_CREATE=1 \
    POETRY_CACHE_DIR=/tmp/poetry_cache
WORKDIR /app

# TODO: not root user

RUN python3 -m pip install poetry
COPY poetry.lock .
COPY pyproject.toml .
RUN poetry install --without dev --no-root

##
## Final Production Image
##
FROM python:3.12-slim-bullseye AS final
ENV VIRTUAL_ENV=/app/.venv \
    PATH="/app/.venv/bin:$PATH"
WORKDIR /app

# TODO: not root user

RUN mkdir uploads && mkdir db
COPY --from=builder ${VIRTUAL_ENV} ${VIRTUAL_ENV}
# RUN touch image-search.sqlite
COPY image_search/ ./image_search

EXPOSE 8000
ENTRYPOINT ["fastapi", "run", "image_search/app.py"]


##
## Development image
##
FROM builder AS dev
ENV VIRTUAL_ENV=/app/.venv \
    PATH="/app/.venv/bin:$PATH"
WORKDIR /app

# TODO: not root user

RUN mkdir uploads && mkdir db
COPY scripts/ ./scripts/
COPY e2e/ ./e2e/
COPY tests/ ./tests/
COPY image_search/ ./image_search

EXPOSE 8000
ENTRYPOINT ["fastapi", "dev", "image_search/app.py"]
