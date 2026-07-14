# AGENTS.md

Guidance for AI coding agents (Claude Code, Cursor, etc.) working in this repository.

## What this project is

An academic topic-modeling assignment: run **Latent Dirichlet Allocation (LDA/CVB)** over the
[UCI "Bag of Words" NIPS dataset](http://archive.ics.uci.edu/ml/datasets/Bag+of+Words) using
**Apache Mahout on Hadoop**, then post-process the results into human-readable distributions.

The repository is **not a single runnable application**. It is three independent Java helper
programs that bookend a manual Mahout/Hadoop pipeline. Each `.java` file has its own `main`
method and is run on its own.

## Repository layout

| File | Role |
|------|------|
| `DocumentGenerator.java` | Reads `docword.nips.txt` + `vocab.nips.txt` and emits one `<docID>.txt` file per document (the corpus fed into Mahout). |
| `TopicTermDistribution.java` | Reads the dumped per-topic word vectors and prints the top 10 words + probabilities for each topic. |
| `TopicProbability.java` | Reads the dumped document-topic vectors and prints each topic's probability per document. |
| `MahoutCommands.txt` | The ordered Mahout/Hadoop CLI pipeline that runs between `DocumentGenerator` and the two dump-parsers. |
| `README.md` | Assignment description and dataset format. |

All three Java files declare `package org.mahout.assignment5;` but live at the repo root. This is
fine for compilation (see below); it only matters when you *run* a class (use the fully qualified
name).

## Pipeline order (end to end)

1. `DocumentGenerator` → generates `<docID>.txt` corpus files.
2. `hadoop fs -put` the corpus into HDFS.
3. Mahout: `seqdirectory` → `seq2sparse -wt TF` → `rowid` → `cvb -k 10` (10 topics).
4. Mahout `vectordump` the topic and document-topic vectors back to the local FS.
5. `TopicTermDistribution` and `TopicProbability` → parse the dumps into readable output.

The exact commands (with placeholder `/user/../` paths) are in `MahoutCommands.txt`.

## Build & verify loop

There is no Maven/Gradle project. The three files use only the JDK standard library, so:

```bash
./build.sh          # compiles all sources into ./out/
```

Equivalent to `javac -d out *.java`. A successful compile is the fastest correctness signal
available in this repo — **run it after any Java edit.** Verified with OpenJDK 11.

Running a program (example):

```bash
java -cp out org.mahout.assignment5.DocumentGenerator
```

There is no automated test suite and the Mahout/Hadoop stages cannot be exercised without a
cluster and the (large, not-checked-in) NIPS dataset. Treat "it compiles" as the CI-equivalent
gate for the Java side.

## Conventions & constraints for agents

- **Hardcoded paths.** Every program hardcodes absolute input/output paths (e.g.
  `/home/Downloads/vocab.nips.txt`, `/home/assignment5/`, `/home/../lda_dump_output/`). These are
  environment-specific and will not exist on a fresh checkout. Do **not** assume they resolve.
  A genuinely useful improvement is to accept these as `args`/env vars — but only change behavior
  when the task asks for it; keep unrelated diffs out.
- **Keep the package declaration and the run instructions in sync.** If you move files into
  `src/main/java/org/mahout/assignment5/`, update `build.sh` and this file.
- **Don't commit build output or the dataset.** `out/`, `*.class`, and the NIPS `.txt`/`.gz`
  files are git-ignored (see `.gitignore`). The dataset is downloaded separately from UCI.
- **Style.** Match the existing code: tabs for indentation, `java.io` buffered readers/writers.
  This is legacy assignment code; prefer minimal, targeted changes over sweeping rewrites unless
  the task is explicitly a refactor.

## Good first tasks for an agent here

- Parameterize the hardcoded file paths via `args[]` (removes the single biggest run blocker).
- Add basic input validation / try-with-resources around the file I/O.
- Add a small sample dataset + a smoke test so the parsers can run without a Hadoop cluster.
