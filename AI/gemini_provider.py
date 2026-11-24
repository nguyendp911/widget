"""Gemini Developer API adapter. No SDK dependency or fixed model version."""
import json
import os
import re
import threading
import time
import urllib.error
import urllib.parse
import urllib.request

BASE = "https://generativelanguage.googleapis.com/v1beta"
CACHE_SECONDS = 300
LOCK = threading.Lock()
_cache = (0.0, [])
_bad = {}

def request(path, payload=None):
    key = os.environ.get("GEMINI_API_KEY") or os.environ.get("GOOGLE_API_KEY")
    if not key:
        raise RuntimeError("missing_gemini_key")
    headers = {"x-goog-api-key": key, "Accept": "application/json"}
    data = None
    if payload is not None:
        headers["Content-Type"] = "application/json"
        data = json.dumps(payload, ensure_ascii=False).encode()
    req = urllib.request.Request(BASE + path, data=data, headers=headers)
    with urllib.request.urlopen(req, timeout=20) as res:
        return json.loads(res.read(2_000_000))

def is_text_model(item):
    name = item.get("name", "")
    if not isinstance(name, str) or not re.fullmatch(r"models/gemini-[a-zA-Z0-9._-]+", name):
        return False
    if "generateContent" not in item.get("supportedGenerationMethods", []):
        return False
    # Exclude specialized media, live, tools-only and embeddings.
    return not any(re.search(r"(?:^|[-_])" + part + r"(?:$|[-_])", name.lower().split("/")[-1])
                   for part in ("image","vision","audio","tts","live","embedding","robotics","computer","video","speech","native","deep-research"))

def rank(item, mode="balanced"):
    name = item["name"].lower().split("/")[-1]
    nums = re.match(r"gemini-(\d+)(?:\.(\d+))?", name)
    version = tuple(int(x or 0) for x in nums.groups()) if nums else (0, 0)
    unstable = any(x in name for x in ("preview","experimental","-exp","latest"))
    tier = ("pro" if "-pro" in name else "lite" if "lite" in name else "flash" if "flash" in name else "other")
    prefs = {"balanced":{"flash":3,"lite":2,"pro":1,"other":0},
             "fast":{"lite":3,"flash":2,"pro":1,"other":0},
             "deep":{"pro":3,"flash":2,"lite":1,"other":0}}
    return (not unstable, prefs.get(mode,prefs["balanced"])[tier], version, name)

def list_models(force=False):
    global _cache
    with LOCK:
        if not force and _cache[1] and time.monotonic() - _cache[0] < CACHE_SECONDS:
            return list(_cache[1])
        items, token, seen = [], "", set()
        for _ in range(30):
            query = {"pageSize": 100}
            if token:
                query["pageToken"] = token
            page = request("/models?" + urllib.parse.urlencode(query))
            items.extend(x for x in page.get("models", []) if isinstance(x,dict) and is_text_model(x))
            token = page.get("nextPageToken", "")
            if not token:
                break
            if token in seen:
                raise RuntimeError("model_pagination_loop")
            seen.add(token)
        else:
            raise RuntimeError("model_pagination_limit")
        items = list({x["name"]:x for x in items}.values())
        if not items:
            raise RuntimeError("no_compatible_gemini_models")
        _cache = (time.monotonic(), items)
        return list(items)

def candidates(mode="balanced", force=False):
    items = sorted(list_models(force), key=lambda x: rank(x,mode), reverse=True)
    allowed = set(x.strip().removeprefix("models/") for x in os.environ.get("GEMINI_ALLOWED_MODELS","").split(",") if x.strip())
    if allowed:
        items = [x for x in items if x["name"].removeprefix("models/") in allowed]
    if not items:
        raise RuntimeError("no_allowed_gemini_models")
    with LOCK:
        return [x for x in items if _bad.get(x["name"],0) <= time.monotonic()]

def generate(system, prompt, mode="balanced"):
    # Only retry explicit model-not-found/overload errors. Quota/auth errors
    # are surfaced, not bypassed by rotating keys or repeatedly spending tokens.
    attempts = 0
    for refresh in (False, True):
        for item in candidates(mode, force=refresh):
            if attempts >= 2:
                raise RuntimeError("gemini_models_unavailable")
            attempts += 1
            name = item["name"]
            payload = {
                "systemInstruction":{"parts":[{"text":system}]},
                "contents":[{"role":"user","parts":[{"text":prompt}]}],
                "generationConfig":{"maxOutputTokens":2048,"candidateCount":1}
            }
            try:
                out = request("/" + name + ":generateContent", payload)
            except urllib.error.HTTPError as exc:
                if exc.code not in (404, 503):
                    raise
                with LOCK:
                    _bad[name] = time.monotonic() + 120
                continue
            rows = out.get("candidates", [])
            if not rows or rows[0].get("finishReason") not in ("STOP","MAX_TOKENS"):
                raise RuntimeError("gemini_response_blocked")
            parts = rows[0].get("content",{}).get("parts",[])
            result = "\n".join(p["text"] for p in parts if isinstance(p.get("text"),str) and not p.get("thought"))
            if not result.strip():
                raise RuntimeError("gemini_empty_response")
            return {"answer":result[:12000],"provider":"gemini","model":name.removeprefix("models/")}
    raise RuntimeError("gemini_models_unavailable")

def status():
    items = candidates()
    return {"provider":"gemini","models":[{"id":x["name"].removeprefix("models/"),"name":x.get("displayName",x["name"])} for x in items],
            "selected":items[0]["name"].removeprefix("models/") if items else None}
