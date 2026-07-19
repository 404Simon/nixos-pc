#!/usr/bin/env python3

import pickle
import re
import subprocess
import sys
from pathlib import Path
from typing import List, Optional, Tuple

LYRICS_DIR = Path("/home/simon/Music/mpd/lyrics")
MUSIC_DIR = Path("/home/simon/Music")
INDEX_FILE = LYRICS_DIR / ".lyrics_index.pkl"


def extract_timestamp(line: str) -> Optional[str]:
    """Extract timestamp from a lyrics line"""
    match = re.search(r"\[(\d{2}:\d{2}\.\d{2})\]", line)
    return match.group(1) if match else None


def needs_rebuild() -> bool:
    """Check if index needs rebuilding"""
    if not INDEX_FILE.exists():
        return True

    index_mtime = INDEX_FILE.stat().st_mtime

    # Check if any .lrc file is newer than the index
    for lrc_file in LYRICS_DIR.glob("*.lrc"):
        if lrc_file.stat().st_mtime > index_mtime:
            return True

    return False


def build_index() -> List[Tuple[str, str, str]]:
    """Build the lyrics index"""
    print("Building lyrics index...")
    entries = []

    for lrc_file in LYRICS_DIR.glob("*.lrc"):
        filename = lrc_file.name

        try:
            with open(lrc_file, "r", encoding="utf-8", errors="ignore") as f:
                for line in f:
                    line = line.strip()

                    # Skip metadata lines and empty lines
                    if (
                        line.startswith("[ti:")
                        or line.startswith("[ar:")
                        or line.startswith("[al:")
                        or line.startswith("[length:")
                        or not line
                    ):
                        continue

                    # Extract timestamp if present
                    timestamp = extract_timestamp(line) or ""

                    # Remove timestamp from lyric text
                    lyric_text = re.sub(r"\[\d{2}:\d{2}\.\d{2}\]\s*", "", line)

                    if lyric_text.strip():
                        entries.append((filename, timestamp, lyric_text))

        except Exception as e:
            print(f"Warning: Could not read {lrc_file}: {e}")

    # Save index to file
    with open(INDEX_FILE, "wb") as f:
        pickle.dump(entries, f)

    print(f"Index built with {len(entries)} entries.")
    return entries


def load_index() -> List[Tuple[str, str, str]]:
    """Load or build the lyrics index"""
    if needs_rebuild():
        return build_index()

    try:
        with open(INDEX_FILE, "rb") as f:
            return pickle.load(f)
    except Exception:
        return build_index()


def find_audio_file(lrc_filename: str) -> Optional[str]:
    """Find matching audio file"""
    basename = lrc_filename.replace(".lrc", "")

    # Try exact match first
    for ext in [".mp3", ".flac", ".m4a", ".wav"]:
        for audio_file in MUSIC_DIR.rglob(f"{basename}{ext}"):
            return str(audio_file)

    # Try fuzzy matching
    # Extract artist and title from filename (format: "number - artist - title.lrc")
    clean_name = re.sub(r"^\d+\s*-\s*", "", basename)
    if " - " in clean_name:
        artist, title = clean_name.split(" - ", 1)

        # Search for files containing title
        for ext in [".mp3", ".flac", ".m4a", ".wav"]:
            for audio_file in MUSIC_DIR.rglob(f"*{title}*{ext}"):
                return str(audio_file)

        # Search for files containing artist
        for ext in [".mp3", ".flac", ".m4a", ".wav"]:
            for audio_file in MUSIC_DIR.rglob(f"*{artist}*{ext}"):
                return str(audio_file)

    return None


def timestamp_to_seconds(timestamp: str) -> int:
    """Convert timestamp to seconds"""
    if not timestamp:
        return 0

    try:
        minutes, seconds = timestamp.split(":")
        seconds_float = float(seconds)
        return int(int(minutes) * 60 + seconds_float)
    except (ValueError, IndexError):
        return 0


def main():
    # Load or build index
    entries = load_index()

    if not entries:
        print("No lyrics found!")
        sys.exit(1)

    print("Searching through lyrics... (Press Ctrl+C to cancel)")

    # Prepare data for fzf
    fzf_input = []
    for filename, timestamp, lyric_text in entries:
        fzf_input.append(f"{filename}|{timestamp}|{lyric_text}")

    # Run fzf
    try:
        result = subprocess.run(
            [
                "fzf",
                "--delimiter=|",
                "--with-nth=3",
                '--preview=echo "File: {1}"; echo "Time: {2}"; echo "Lyric: {3}"',
                "--preview-window=up:3",
                "--height=80%",
                "--prompt=Search lyrics > ",
            ],
            input="\n".join(fzf_input),
            text=True,
            capture_output=True,
        )

        if result.returncode != 0:
            print("No selection made.")
            sys.exit(0)

        selected = result.stdout.strip()

    except KeyboardInterrupt:
        print("\nCancelled.")
        sys.exit(0)

    # Parse selection
    try:
        filename, timestamp, lyric_text = selected.split("|", 2)
    except ValueError:
        print("Error parsing selection")
        sys.exit(1)

    print("Selected:")
    print(f"  File: {filename}")
    print(f"  Time: {timestamp}")
    print(f"  Lyric: {lyric_text}")

    # Find audio file
    audio_file = find_audio_file(filename)
    if not audio_file:
        print(f"Error: Could not find matching audio file for {filename}")
        print(f"Please check if the audio file exists in {MUSIC_DIR}")
        sys.exit(1)

    print(f"Found audio file: {audio_file}")

    # Play the audio
    if timestamp:
        start_time = timestamp_to_seconds(timestamp)
        print(f"Starting playback at {timestamp} ({start_time} seconds)")
        subprocess.run(["mpv", f"--start={start_time}", audio_file])
    else:
        print("No timestamp found, starting from beginning")
        subprocess.run(["mpv", audio_file])


if __name__ == "__main__":
    main()
