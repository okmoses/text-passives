from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_post_passives_detects_passive_phrases():
  passivePhrases = [
    "Dad was taught by Jane.",
    "Food was cooked by Jane.",
    "Pumpkins were carved by Jane.",
    "Pictures were taken by Jane.",
    "That picture is being painted by Jane.",
    "Jane is being impressed by that picure.",
    "By the time we get there, the plane will not have been repaired by the mechanics.",
    "By the time 2021 is over, the vegetables will have been eaten by the Zombies.",
    "The vegetables will be eaten.",
    "The picture will be taken by Jane.",
    "The plane is being flown by the pilots.",
    "He was being watched in a certain hit song.",
    "By October 10, the Pumpkins had been carved and the scene was set."
  ]
  for phrase in passivePhrases:
    response = client.post(
      "/passives",
      json={
        "text": phrase
      }
    )
    passives = response.json()['passives']
    assert len(passives) > 0

def test_post_passives_returns_nothing_for_active_phrases():
  activePhrases = [
    "Jane taught dad.",
    "Jane cooked food.",
    "Jane carved Pumpkins.",
    "Jane took pictures.",
    "Jane is painting that picture.",
    "That picture is impressing Jane.",
    "By the time we get there, the mechanics will not have repaired the plane.",
    "By the time 2021 is over, the Zombies will not have eaten the vegetable.",
    "I will eat the vegetables.",
    "Jane will take the picture.",
    "The pilots are flying the plane.",
    "The zombies watched him in a certain hit song.",
    "By October 10, we had carved the Pumpkins and set the scene."
  ]
  for phrase in activePhrases:
    response = client.post(
      "/passives",
      json={
        "text": phrase
      }
    )
    passives = response.json()['passives']
    assert len(passives) == 0

def test_post_passives_returns_multiple_passive_phrases():
  text = "The tub is filled with water. The bear ate my drink. The tub is filled with drink."
  response = client.post(
    "/passives",
    json={
      "text": text
    }
  )
  assert response.json() == { "passives": [['tub is filled', 1, 4], ['tub is filled', 14, 17]] }

def test_post_passives_returns_200():
  text = "The tub is filled with water. The bear ate my drink. The tub is filled with drink."
  response = client.post(
    "/passives",
    json={
      "text": text
    }
  )
  assert response.status_code == 200

def test_post_tags_without_body_returns_422():
  response = client.post(
    "/passives"
  )
  assert response.status_code == 422

def test_post_tags_without_text_field_returns_422():
  response = client.post(
    "/passives",
    json={}
  )
  assert response.status_code == 422

def test_get_tags_returns_405():
  response = client.get("/passives")
  assert response.status_code == 405