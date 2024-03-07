#!/usr/bin/env bash

git ls-files -z | while IFS= read -rd '' f; do if file --mime-encoding "$f" | grep -qv binary; then tail -c1 < "$f" | read -r _ || echo >> "$f"; fi; done
