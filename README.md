# ไทยSA (`thaisa`)

**100% Offline Cross-Platform Bilingual (Thai + English) Qualitative Data Analysis Desktop Application**

**ไทยSA** (`thaisa`) is a local-first desktop research suite for macOS and Windows designed specifically for bilingual **English (primary) and Thai (secondary)** qualitative inquiry. Built around **Braun & Clarke’s six-phase Reflexive Thematic Analysis**, the application keeps all transcripts, codebooks, participant scores, and reflexive memos stored locally in SQLite while supporting offline AI assistance via **Ollama** (plus an optional opt-in Google AI Studio API key toggle).

---

## Core Methodological & Technical Highlights

* **Strict Braun & Clarke Six-Phase Architecture:** Guides researchers sequentially from Phase 1 familiarization and Phase 2 initial coding through Phases 3–5 visual theme construction and Phase 6 manuscript export.
* **Human-in-the-Loop AI Guardrails:** AI-assisted inductive theme suggestions and deductive codebook matches are strictly rendered as `pending` dashed-border highlights until explicitly accepted, re-assigned, or rejected by the researcher.
* **Immutable Reflexive Audit Trail:** Database-level SQLite `BEFORE UPDATE` and `BEFORE DELETE` triggers enforce append-only logging of every code creation, merge, split, rename, memo edit, and AI review decision (`Accept` / `Re-assign` / `Reject`).
* **Thai Unicode Fidelity (NFC & OpenType Shaping):** Preserves Thai combining vowels, stacked tone marks, and decomposed `SARA AM` (`น้ำ`, `ก่ำ`) end-to-end across `.docx`, `.odt`, `.pdf`, `.xlsx`, and `.csv` ingestion and `.docx`, `.pdf`, and `.md` exports.
* **Unified Mixed-Methods Backbone:** Every qualitative transcript and quantitative spreadsheet row links through a canonical `participant_id`, enabling direct statistical comparisons and interactive Mixed-Methods Joint Displays.

---

## Feature Architecture

### 1. Bilingual Multi-Format Ingestion & SQLite Persistence
* **Supported Formats:** `.docx`, `.odt`, `.pdf`, `.xlsx`, and `.csv` (`parsers/`).
* **Unicode Normalization:** Normalizes text using Unicode `NFC` (never `NFKC`) via `unicode_utils.py` and repairs PDF-decomposed `SARA AM` sequences.
* **Relational Storage:** 14 relational tables in `schema.sql` running in UTF-8 WAL mode with foreign keys enabled and append-only `audit_trail` triggers.
* **Secure Desktop Shell:** Electron main/preload supervisor (`main.ts`, `sidecar.ts`, `preload.ts`) spawns the local FastAPI backend on an ephemeral `127.0.0.1` port secured with per-launch bearer token authentication.

### 2. Qualitative Studio (Braun & Clarke Phases 1–2)
* **Three-Pane Workspace:**
  * **Left Panel:** Data source folder hierarchy, format badges, participant metadata tags, and search/filtering.
  * **Center Panel (`DocumentCanvas.tsx`):**
    * *Phase 1 Familiarization:* Clean reading view paired with a per-document reflexive scratchpad (`FamiliarizationPad.tsx`).
    * *Phase 2 Coding:* Manual drag highlighting with `Intl.Segmenter('th', { granularity: 'word' })` word-boundary snapping (`thaiSelection.ts`) and `word-break: keep-all`, overlapping right-margin coding stripes, inductive **"Suggest Possible Themes"** scans, and deductive **"Apply My Codebook"** scans.
  * **Right Panel (`CodebookPane.tsx` & `MemoInspector.tsx`):** Color-coded hierarchical codebook, verbatim excerpt inspector, analytic memo editor, and **Accept / Re-assign / Reject** controls.
* **Local Verbatim Quote Offset Matcher (`quote_matcher.py`):** Never asks LLMs for character indices; resolves `[start_offset, end_offset]` locally in Python via exact substring matching (with repeated-quote disambiguation), whitespace-normalized alignment, and `rapidfuzz.fuzz.partial_ratio_alignment` fallback.
* **Offline Local AI Engine (`ai_engine.py`):** Connects to local Ollama (`http://localhost:11434`) supporting models such as `typhoon2.5-qwen3-4b`, `qwen3`, and `gemma3`, strips `<think>` reasoning blocks for clean JSON extraction, displays live offline status without interrupting manual coding, and includes an optional opt-in Google AI Studio key switch.

### 3. Visual Theme Board (Phases 3–5) & Quantitative / Mixed-Methods Lab
* **Visual Theme Board (`VisualThemeBoard.tsx`, `CoherenceDrawer.tsx`, `ThemeDefinitionForm.tsx`):**
  * *Phase 3:* Drag-and-drop clustering of Phase 2 code cards into candidate themes.
  * *Phase 4:* Side-by-side Thai and English **Coherence Check** drawer supporting transactional **Merge**, **Split**, **Promote**, and **Demote** operations.
  * *Phase 5:* Structured theme definition form capturing **Final Theme Name**, **Central Organizing Concept**, **Included vs. Excluded Scope**, and a locked master hex color.
* **Quantitative & Mixed-Methods Lab (`stats_engine.py`, `quant.py`, `QuantMixedLab.tsx`):**
  * Participant-linked `.xlsx` / `.csv` data grid with descriptive statistics ($n$, mean, SD, median, IQR, min–max).
  * 7 `scipy.stats` inferential and correlational tests: independent Student's *t*-test, Welch's *t*-test, paired *t*-test, Mann–Whitney *U*, Wilcoxon signed-rank, Pearson's $r$, and Spearman's $\rho$.
  * Interactive **Mixed-Methods Joint Display** linking quantitative score tiers/subgroups directly to participants' color-coded Thai and English verbatim quotes.

### 4. Manuscript Export Studio (Phase 6)
* **Publication-Ready Exports (`matrix_builder.py`, `docx_exporter.py`, `pdf_exporter.py`, `md_exporter.py`):**
  * **Bilingual Quote Matrix:** Organized by Final Theme $\rightarrow$ Sub-theme $\rightarrow$ Participant ID, displaying original verbatim quotes (Thai/English), inline-editable or offline-AI-drafted English glosses (explicitly flagged unverified until researcher confirmation), and analytic memos.
  * **Reflexive Audit Trail Report:** Automated methodological log summarizing Phase 1 familiarization notes, code history, AI suggestion acceptance/re-assignment/rejection rates, and Phase 3–5 theme restructuring decisions.
  * **Formats:** One-click `.docx`, `.pdf` (rendered with `fpdf2` + `uharfbuzz` OpenType Thai shaping), and `.md` downloads.

---

## Project Structure

```text
thaisa/
├── backend/
│   ├── parsers/              # UTF-8 NFC & SARA AM safe .docx, .odt, .pdf, .xlsx, .csv parsers
│   ├── schema.sql            # 14-table SQLite schema + immutable audit_trail triggers
│   ├── unicode_utils.py      # Thai NFC normalization & decomposed SARA AM repair
│   ├── quote_matcher.py      # Local exact + whitespace + rapidfuzz offset resolver
│   ├── ai_engine.py          # Ollama local client (<think> stripper) + optional Google AI toggle
│   ├── themes.py             # Phases 3–5 transactional merge/split/promote/demote logic
│   ├── stats_engine.py       # Descriptive stats & 7 scipy.stats tests
│   ├── quant.py              # Quantitative & Joint Display endpoints
│   ├── matrix_builder.py     # Bilingual Quote Matrix & Audit Trail compiler
│   ├── docx_exporter.py      # Word (.docx) manuscript table exporter
│   ├── pdf_exporter.py       # PDF (.pdf) exporter with fpdf2 + uharfbuzz Thai shaping
│   ├── md_exporter.py        # Markdown (.md) exporter
│   ├── exports.py            # Export API routes
│   ├── sidecar_entry.py      # PyInstaller / sidecar entry point
│   ├── thaisa_backend.spec   # Cross-platform Python sidecar build spec
│   └── tests/                # Pytest verification suite across Milestones 1–4
├── frontend/
│   └── src/
│       ├── components/
│       │   ├── QualitativeStudio.tsx
│       │   ├── DocumentCanvas.tsx
│       │   ├── FamiliarizationPad.tsx
│       │   ├── CodebookPane.tsx
│       │   ├── MemoInspector.tsx
│       │   ├── VisualThemeBoard.tsx
│       │   ├── CoherenceDrawer.tsx
│       │   ├── ThemeDefinitionForm.tsx
│       │   ├── QuantMixedLab.tsx
│       │   ├── ExportStudio.tsx
│       │   ├── BilingualMatrixPreview.tsx
│       │   └── AuditTrailPreview.tsx
│       └── utils/
│           └── thaiSelection.ts  # Intl.Segmenter('th') word-boundary selection helpers
├── electron/
│   ├── main.ts               # Electron window & lifecycle manager
│   ├── sidecar.ts            # Ephemeral 127.0.0.1 FastAPI sidecar supervisor + bearer auth
│   ├── preload.ts            # Context-isolated IPC bridge
│   └── electron-builder.yml  # macOS (.dmg) & Windows (.exe) packaging configuration
└── GEMINI.md                 # Project architectural & methodological rules

Getting Started (Local Development)
Prerequisites

    Python 3.11+

    Node.js 20+ (LTS)

    Ollama (optional, for 100% offline AI coding & gloss drafting):

Verification Suite,Scope,Status
pytest backend/tests -v,"23 automated tests covering schema triggers, Thai parsers, quote offset matching, AI pending-state guardrails, theme coherence transactions, scipy.stats tests, and .docx/.pdf/.md exports","23 passed, 0 failed (2.44s)"
npm --prefix frontend run typecheck,Full React + TypeScript strict typecheck,0 errors
npm --prefix frontend run build,"Vite production bundle (1,573 modules)",Built cleanly (2.37s)
npm --prefix electron run build,"Electron main, preload, and sidecar TypeScript build",0 errors

Citation & Academic Attribution

If you use ไทยSA (thaisa) in qualitative or mixed-methods research, please disclose AI-assisted coding procedures in accordance with your target journal's or institution's AI-use guidelines and include the generated Reflexive Audit Trail Report as supplementary methodological documentation.
