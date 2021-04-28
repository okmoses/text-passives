from fastapi import Depends, FastAPI

from .routers import documents

app = FastAPI(dependencies=[])

app.include_router(documents.router)