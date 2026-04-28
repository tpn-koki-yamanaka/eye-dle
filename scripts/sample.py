#!/usr/bin/env python3
"""Minimal sample script runnable via uvx."""

from datetime import datetime


def main() -> None:
    now = datetime.now().isoformat(timespec="seconds")
    print("Hello from Python sample script!")
    print(f"Current time: {now}")


if __name__ == "__main__":
    main()
