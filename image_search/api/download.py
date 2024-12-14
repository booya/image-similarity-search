from fastapi import APIRouter
from fastapi.responses import FileResponse
import newrelic.agent

from image_search.services.image_service import ImageServiceDep

router = APIRouter()


# This is not async because we use blocking DB operations
@newrelic.agent.function_trace(name="get_download", group="api")
@router.get("/download/{image_id}/")
def download_image(image_id: str, image_service: ImageServiceDep):
    image = image_service.download_image(image_id)
    return FileResponse(
        path=image.path,
        filename=image.filename,
    )
