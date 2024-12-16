#!venv/bin/python3

"""send-traffic.py

This script is intended to send some traffic to the application so we have something to see
in New Relic. It will initially upload the three sample images, and then will loop forever
querying the similarity API for results. Has a few bugs; it doesn't work properly if there are
already images on the running container. It needs to start with an empty uploads DB.
"""

from dataclasses import dataclass
from typing import List, Dict
import os
import random
import sys
import time

import requests

BASE_URL = "http://localhost:8000"
API_URL = f"{BASE_URL}/api"


@dataclass
class Similarity:
    image_id: str
    score: float

    @classmethod
    def from_dict(cls, data: Dict):
        return cls(data["image_id"], data["score"])


def similar(session: requests.Session, uuid: str) -> List[Similarity]:
    similarities: List[Similarity] = []
    response = session.request("GET", f"{API_URL}/similar/{uuid}/")
    if response.status_code != 200:
        # something wrong
        print(
            f"Error checking similarities for {image}: {response.status_code} {response.text}"
        )
        return similarities

    return [Similarity.from_dict(data) for data in response.json().get("images", [])]


def upload(session: requests.Session, file_path: str) -> str:
    response = session.request(
        "POST",
        f"{API_URL}/upload/",
        files={"file": (file_path, open(file_path, "rb"), "image/jpeg")},
    )
    if response.status_code != 201:
        # something wrong
        print(f"Error uploading {image}: {response.status_code} {response.text}")
        return ""

    return response.json().get("image_id", "")


if __name__ == "__main__":
    # check the script is running in the root directory
    if not os.path.basename(os.path.abspath(".")) == "image-similarity-search":
        sys.exit("Must run this from the repo root directory")

    session = requests.Session()

    uuid_map = {}
    images = [
        "sports-car.jpg",
        "orange-cat.jpg",
        "golden-dog.jpg",
    ]
    for image in images:
        print(f"Uploading image: {image}")
        uuid = upload(session, f"./{image}")
        if not uuid:
            continue
        uuid_map[uuid] = image

    # Now that they are uploaded, check for similarity scores
    # doing this forever for the sake of traffic generation
    while True:
        for uuid, image in uuid_map.items():
            # occasionally use a bad UUID so there are failures
            if int(random.random() * 5) % 5 == 1:
                uuid = "intentional-failure"
            similarities = similar(session, uuid)
            if not similarities:
                continue
            print(f"Image {image} is similar to:")
            for s in similarities:
                image_name = uuid_map[s.image_id]
                print(f"  {image_name}: similarity {s.score * 100:0.2f}%")
        time.sleep(random.random() * 5)
