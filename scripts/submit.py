#!/usr/bin/env python3
"""Wait for build processing then attach to review submission."""
import os, sys, time, json, jwt, requests
from datetime import datetime, timedelta, timezone

KEY_ID = os.environ["ASC_KEY_ID"]
ISSUER = os.environ["ASC_ISSUER_ID"]
KEY_PATH = os.path.expanduser(f"~/private_keys/AuthKey_{KEY_ID}.p8")
BUNDLE_ID = "com.tokyonasu.ArcanaWeather"
BASE = "https://api.appstoreconnect.apple.com/v1"

def token():
    with open(KEY_PATH) as f:
        key = f.read()
    now = datetime.now(timezone.utc)
    payload = {"iss": ISSUER, "iat": now, "exp": now + timedelta(minutes=20), "aud": "appstoreconnect-v1"}
    return jwt.encode(payload, key, algorithm="ES256", headers={"kid": KEY_ID})

def headers():
    return {"Authorization": f"Bearer {token()}", "Content-Type": "application/json"}

def get(path):
    r = requests.get(f"{BASE}{path}", headers=headers())
    r.raise_for_status()
    return r.json()

def post(path, data):
    r = requests.post(f"{BASE}{path}", headers=headers(), json=data)
    r.raise_for_status()
    return r.json()

def patch(path, data):
    r = requests.patch(f"{BASE}{path}", headers=headers(), json=data)
    r.raise_for_status()
    return r.json()

# Find app
apps = get(f"/apps?filter[bundleId]={BUNDLE_ID}")
if not apps["data"]:
    print(f"App {BUNDLE_ID} not found in ASC. Create it manually first.")
    sys.exit(0)
app_id = apps["data"][0]["id"]
print(f"App ID: {app_id}")

# Wait for build
print("Waiting for build to process...")
build = None
for attempt in range(40):
    builds = get(f"/builds?filter[app]={app_id}&sort=-uploadedDate&limit=1&filter[processingState]=VALID")
    if builds["data"]:
        b = builds["data"][0]
        ver = b["attributes"].get("version", "?")
        print(f"Build ready: {ver}")
        build = b
        break
    print(f"  attempt {attempt+1}/40 - waiting 30s...")
    time.sleep(30)

if not build:
    print("No valid build found after waiting. Submit manually.")
    sys.exit(0)

build_id = build["id"]

# Get edit version
versions = get(f"/apps/{app_id}/appStoreVersions?filter[appStoreState]=PREPARE_FOR_SUBMISSION,READY_FOR_REVIEW")
if not versions["data"]:
    print("No editable version found.")
    sys.exit(0)

version_id = versions["data"][0]["id"]

# Attach build
try:
    patch(f"/appStoreVersions/{version_id}/relationships/build", {
        "data": {"type": "builds", "id": build_id}
    })
    print(f"Build {build_id} attached to version {version_id}")
except Exception as e:
    print(f"Build attach: {e}")

# Submit
try:
    sub = post("/reviewSubmissions", {
        "data": {
            "type": "reviewSubmissions",
            "attributes": {"platform": "IOS"},
            "relationships": {"app": {"data": {"type": "apps", "id": app_id}}}
        }
    })
    sub_id = sub["data"]["id"]

    post("/reviewSubmissionItems", {
        "data": {
            "type": "reviewSubmissionItems",
            "relationships": {
                "reviewSubmission": {"data": {"type": "reviewSubmissions", "id": sub_id}},
                "appStoreVersion": {"data": {"type": "appStoreVersions", "id": version_id}}
            }
        }
    })

    patch(f"/reviewSubmissions/{sub_id}", {
        "data": {"type": "reviewSubmissions", "id": sub_id, "attributes": {"submitted": True}}
    })
    print("Submitted for review!")
except Exception as e:
    print(f"Review submission: {e}")
