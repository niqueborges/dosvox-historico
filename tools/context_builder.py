import os
import json
import sys

BASE_PATH = ".." # Since script is in tools/

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

def infer_tags(path):
    p = path.lower()
    tags = []
    if "dependency" in p: tags.append("dependencies")
    if "knockout" in p: tags.append("knockout")
    if "taxonomy" in p: tags.append("taxonomy")
    if "history" in p: tags.append("history")
    if "architecture" in p: tags.append("architecture")
    if "lesson" in p: tags.append("methodology")
    return tags

def get_allowed_files():
    files = []
    # Only map specific known directories
    allowed_dirs = ["dosvox-archeology/docs", "dosvox-archeology/research", "sources"]
    
    for allowed_dir in allowed_dirs:
        dir_path = os.path.join(BASE_PATH, allowed_dir)
        if not os.path.exists(dir_path):
            continue
        for root, _, filenames in os.walk(dir_path):
            for filename in filenames:
                if not filename.endswith((".md", ".txt", ".json")):
                    continue
                full_path = os.path.normpath(os.path.join(root, filename)).replace("\\", "/")
                # Store relative to project root
                rel_path = os.path.relpath(full_path, BASE_PATH).replace("\\", "/")
                content = read_text(full_path)
                files.append({
                    "path": rel_path,
                    "title": extract_title(content, rel_path),
                    "summary": extract_summary(content),
                    "tags": infer_tags(rel_path)
                })
    return files

# The Profiles Configuration
PROFILES = {
    "core": {
        "role": "core",
        "description": "Conhecimento base para todos os agentes.",
        "load_order": [],
        "entrypoints": [
            "dosvox-archeology/docs/README.md",
            "dosvox-archeology/docs/methodology.md"
        ],
        "deep_dive": [],
        "evidence": [],
        "references": []
    },
    "architect": {
        "role": "architect",
        "description": "Foco estrutural, acoplamentos e dívida técnica histórica.",
        "load_order": ["core"],
        "entrypoints": [
            "dosvox-archeology/docs/architecture.md"
        ],
        "deep_dive": [
            "dosvox-archeology/docs/dependencies.md",
            "dosvox-archeology/docs/architectural-debt.md"
        ],
        "evidence": [
            "dosvox-archeology/research/dependency-knockout.md",
            "dosvox-archeology/research/direct-dependencies.md"
        ],
        "references": []
    },
    "historian": {
        "role": "historian",
        "description": "Foco sociotécnico, evolução e pessoas envolvidas.",
        "load_order": ["core"],
        "entrypoints": [
            "dosvox-archeology/docs/history-crosswalk.md",
            "dosvox-archeology/docs/contributors.md"
        ],
        "deep_dive": [
            "dosvox-archeology/docs/stratigraphy.md",
            "dosvox-archeology/docs/timeline.md"
        ],
        "evidence": [],
        "references": [
            "sources/site-historia/historia-antonio-borges.md"
        ]
    },
    "curator": {
        "role": "curator",
        "description": "Foco no patrimônio, binários órfãos e catálogos.",
        "load_order": ["core"],
        "entrypoints": [
            "dosvox-archeology/docs/applications-catalog.md"
        ],
        "deep_dive": [
            "dosvox-archeology/docs/orphan-binaries.md",
            "dosvox-archeology/docs/provenance.md"
        ],
        "evidence": [],
        "references": [
            "dosvox-archeology/docs/references.md"
        ]
    },
    "researcher": {
        "role": "researcher",
        "description": "Foco na taxonomia empírica e métricas do sistema.",
        "load_order": ["core"],
        "entrypoints": [
            "dosvox-archeology/docs/taxonomy.md"
        ],
        "deep_dive": [
            "dosvox-archeology/research/taxonomic-confidence.md",
            "dosvox-archeology/research/classification.md"
        ],
        "evidence": [
            "dosvox-archeology/research/taxonomy-metrics.md",
            "dosvox-archeology/research/compilation-matrix.md"
        ],
        "references": []
    },
    "debugger": {
        "role": "debugger",
        "description": "Acesso focado em resolução de anomalias arquiteturais.",
        "load_order": ["core", "architect"],
        "entrypoints": [],
        "deep_dive": [],
        "evidence": [
            "dosvox-archeology/research/criticality-matrix.md",
            "dosvox-archeology/research/dependency-knockout.md"
        ],
        "references": []
    }
}

def validate_context(all_files):
    available_paths = {f["path"] for f in all_files}
    errors = []

    # Verify profiles
    for name, profile in PROFILES.items():
        # Check load_order
        for dep in profile.get("load_order", []):
            if dep not in PROFILES:
                errors.append(f"Profile '{name}' depends on unknown profile '{dep}'")
            if dep == name:
                errors.append(f"Profile '{name}' has a circular dependency on itself")

        # Check paths
        for key in ["entrypoints", "deep_dive", "evidence", "references"]:
            for file_path in profile.get(key, []):
                if file_path not in available_paths:
                    # Ignore .pas files in the source sample for debugger for now, as they might not be parsed if we only parse md/txt
                    if not file_path.endswith(".pas"):
                        errors.append(f"Profile '{name}' references missing file: {file_path}")

    # Verify topics
    topics_file = os.path.join(BASE_PATH, "context", "topics.json")
    if os.path.exists(topics_file):
        with open(topics_file, "r", encoding="utf-8") as f:
            topics = json.load(f)
        for topic, sections in topics.items():
            for section, paths in sections.items():
                for p in paths:
                    if p not in available_paths and not p.endswith(".pas"):
                        errors.append(f"Topic '{topic}' references missing file: {p}")

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

def build_catalogs(files):
    docs = [f for f in files if f["path"].startswith("dosvox-archeology/docs/")]
    research = [f for f in files if f["path"].startswith("dosvox-archeology/research/")]
    sources = [f for f in files if f["path"].startswith("sources/")]

    save_json("context/catalogs/docs.json", {"scope": "docs", "files": docs})
    save_json("context/catalogs/research.json", {"scope": "research", "files": research})
    save_json("context/catalogs/sources.json", {"scope": "sources", "files": sources})

def build_profiles():
    for name, data in PROFILES.items():
        save_json(f"context/profiles/{name}.json", data)

def build_master():
    master = {
        "project": "DOSVOX Archeology",
        "description": "Sistema Operacional de Contexto (Context OS) para agentes de IA.",
        "components": {
            "topics_router": "context/topics.json",
            "catalogs": [
                "context/catalogs/docs.json",
                "context/catalogs/research.json",
                "context/catalogs/sources.json"
            ],
            "profiles": [f"context/profiles/{p}.json" for p in PROFILES.keys()]
        }
    }
    save_json("context/master.json", master)

if __name__ == "__main__":
    print("Collecting files...")
    files = get_allowed_files()
    
    print("Validating context graph...")
    validate_context(files)
    
    print("Building Context OS...")
    build_catalogs(files)
    build_profiles()
    build_master()
    
    print("Context OS generated successfully!")
