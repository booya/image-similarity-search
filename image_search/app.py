from contextlib import asynccontextmanager

from fastapi import FastAPI
import newrelic.agent

from image_search import api
from image_search.db import create_db_and_tables, get_or_create_engine

# nrapp = newrelic.agent.application()
newrelic.agent.initialize()


@asynccontextmanager
async def lifespan(_: FastAPI):
    engine = get_or_create_engine()
    create_db_and_tables(engine)
    yield


app = FastAPI(lifespan=lifespan)

app.include_router(api.router, prefix="/api")


@newrelic.agent.function_trace(name="root")
@app.get("/")
async def root():
    return {"message": "Hello World"}
