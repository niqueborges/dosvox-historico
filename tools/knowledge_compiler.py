import os
import json
import sys
import re
import hashlib
from datetime import datetime

BASE_PATH = ".." # Since script is in tools/

def get_hash(path):
    h = hashlib.sha256()
    with open(path, 'rb') as f:
        while chunk := f.read(8192):
            h.update(chunk)
    return h.hexdigest()

def get_modified(path):
    mtime = os.path.getmtime(path)
    return datetime.fromtimestamp(mtime).isoformat()

def read_text(path):
    try:
        with open(path, "r", encoding="utf-8") as f:
            return f.read()
    except UnicodeDecodeError:
        with open(path, "r", encoding="iso-8859-1") as f:
            return f.read()

def extract_title(content, filename):
    for line in content.splitlines():
        if line.startswith("#"):
            return line.lstrip("#").strip()
    return os.path.basename(filename)

def extract_summary(content, max_chars=350):
    text = content.replace("\n", " ").strip()
    return text if len(text) <= max_chars else text[:max_chars].rstrip() + "..."

def get_allowed_files():
    files = []
    allowed_dirs = ["dosvox-archeology/docs", "dosvox-archeology/research", "sources"]
    
    for allowed_dir in allowed_dirs:
        dir_path = os.path.join(BASE_PATH, allowed_dir)
        if not os.path.exists(dir_path):
            continue
        for root, _, filenames in os.walk(dir_path):
            for filename in filenames:
                if not filename.endswith((".md", ".txt", ".json", ".pas")):
                    continue
                full_path = os.path.normpath(os.path.join(root, filename)).replace("\\", "/")
                rel_path = os.path.relpath(full_path, BASE_PATH).replace("\\", "/")
                
                # We only extract content/metadata for text-based documentation
                content = ""
                title = os.path.basename(filename)
                summary = ""
                if filename.endswith((".md", ".txt", ".json")):
                    content = read_text(full_path)
                    title = extract_title(content, rel_path)
                    summary = extract_summary(content)

                files.append({
                    "path": rel_path,
                    "title": title,
                    "summary": summary,
                    "sha256": get_hash(full_path),
                    "modified": get_modified(full_path),
                    "content": content
                })
    return files

def generate_catalogs(files):
    docs = [f for f in files if f["path"].startswith("dosvox-archeology/docs/")]
    research = [f for f in files if f["path"].startswith("dosvox-archeology/research/")]
    sources = [f for f in files if f["path"].startswith("sources/")]

    # Remove content to keep catalogs small
    def clean(file_list):
        return [{"path": f["path"], "title": f["title"], "summary": f["summary"], "sha256": f["sha256"], "modified": f["modified"]} for f in file_list]

    save_json("context/catalogs/docs.json", {"scope": "docs", "files": clean(docs)})
    save_json("context/catalogs/research.json", {"scope": "research", "files": clean(research)})
    save_json("context/catalogs/sources.json", {"scope": "sources", "files": clean(sources)})

def generate_graph_links(files):
    graph = {}
    # Extract [text](link) markdown links
    link_pattern = re.compile(r'\[.*?\]\((.*?)\)')
    for f in files:
        if not f["path"].endswith(".md"):
            continue
        links = link_pattern.findall(f["content"])
        valid_links = []
        for link in links:
            # resolve relative to the current file
            base_dir = os.path.dirname(os.path.join(BASE_PATH, f["path"]))
            abs_target = os.path.normpath(os.path.join(base_dir, link)).replace("\\", "/")
            rel_target = os.path.relpath(abs_target, BASE_PATH).replace("\\", "/")
            valid_links.append(rel_target)
        if valid_links:
            graph[f["path"]] = valid_links
    
    save_json("context/graph-links.json", graph)
    return graph

def load_json_dir(dir_name):
    data = {}
    dir_path = os.path.join(BASE_PATH, "context", dir_name)
    if not os.path.exists(dir_path):
        return data
    for filename in os.listdir(dir_path):
        if filename.endswith(".json"):
            with open(os.path.join(dir_path, filename), "r", encoding="utf-8") as f:
                data[filename] = json.load(f)
    return data

def validate(files, graph_links):
    available_paths = {f["path"] for f in files}
    errors = []

    personas = load_json_dir("personas")
    topics = load_json_dir("topics")
    concepts = load_json_dir("concepts")
    recipes = load_json_dir("recipes")
    playbooks = load_json_dir("playbooks")
    events = load_json_dir("events")
    questions = load_json_dir("questions")

    # Validate Personas
    for name, persona in personas.items():
        for dep in persona.get("inherits", []):
            if f"{dep}.json" not in personas:
                errors.append(f"Persona '{name}' inherits missing persona '{dep}'")
        for key in ["entrypoints", "deep_dive", "evidence"]:
            for path in persona.get(key, []):
                if path not in available_paths:
                    errors.append(f"Persona '{name}' references missing document: {path}")
        for rec in persona.get("recipes", []):
            rec_basename = os.path.basename(rec)
            if rec_basename not in recipes:
                errors.append(f"Persona '{name}' references missing recipe: {rec}")

    # Validate Topics
    for name, topic in topics.items():
        for path in topic.get("documents", []):
            if path not in available_paths:
                errors.append(f"Topic '{name}' references missing document: {path}")

    # Validate Concepts
    for name, concept in concepts.items():
        for path in concept.get("see", []) + concept.get("documents", []):
            if path not in available_paths:
                errors.append(f"Concept '{name}' references missing document: {path}")

    # Validate Recipes
    for name, recipe in recipes.items():
        for path in recipe.get("steps", []):
            if path not in available_paths:
                errors.append(f"Recipe '{name}' references missing step document: {path}")

    # Validate Playbooks
    for name, playbook in playbooks.items():
        for branch, paths in playbook.get("if", {}).items():
            for path in paths:
                if path not in available_paths:
                    errors.append(f"Playbook '{name}' branch '{branch}' references missing document: {path}")

    # Validate Manual Semantic Graph
    semantic_graph_path = os.path.join(BASE_PATH, "context", "graph-semantic.json")
    if os.path.exists(semantic_graph_path):
        with open(semantic_graph_path, "r", encoding="utf-8") as f:
            semantic_graph = json.load(f)
        for node, paths in semantic_graph.items():
            for path in paths:
                if path not in available_paths:
                    errors.append(f"Semantic Graph node '{node}' references missing document: {path}")

    # Validate Events
    for name, event in events.items():
        for path in event.get("artifacts", []):
            if path not in available_paths and not path.endswith(".pas"):
                errors.append(f"Event '{name}' references missing artifact: {path}")

    # Validate Questions
    for name, question in questions.items():
        for path in question.get("known_evidence", []):
            if path not in available_paths and not path.endswith(".pas"):
                errors.append(f"Question '{name}' references missing evidence: {path}")

    if errors:
        print("CONTEXT VALIDATION FAILED:")
        for err in errors:
            print(f" - {err}")
        sys.exit(1)

def save_json(rel_path, data):
    full_path = os.path.join(BASE_PATH, rel_path)
    os.makedirs(os.path.dirname(full_path), exist_ok=True)
    with open(full_path, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

def generate_master():
    master = {
        "project": "DOSVOX Memory Architecture",
        "timestamp": datetime.now().isoformat(),
        "components": {
            "graphs": [
                "context/graph-links.json",
                "context/graph-semantic.json"
            ],
            "directories": [
                "context/catalogs",
                "context/personas",
                "context/topics",
                "context/concepts",
                "context/recipes",
                "context/playbooks",
                "context/events",
                "context/questions"
            ]
        }
    }
    save_json("context/master.json", master)

if __name__ == "__main__":
    print("1. Discovering knowledge nodes...")
    files = get_allowed_files()
    
    print("2. Generating catalogs (with hashes)...")
    generate_catalogs(files)

    print("3. Generating graphs...")
    graph_links = generate_graph_links(files)
    
    print("4. Validating context constraints...")
    validate(files, graph_links)
    
    print("5. Generating master index...")
    generate_master()
    
    print("DOSVOX Memory Architecture compiled successfully!")
