#!/usr/bin/env python3
import sys
import tiktoken


def main():
    text = sys.stdin.read()
    enc = tiktoken.get_encoding("cl100k_base")
    tokens = enc.encode(text)
    print(len(tokens))


if __name__ == "__main__":
    main()
