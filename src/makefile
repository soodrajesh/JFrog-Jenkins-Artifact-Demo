.PHONY: build test clean

build:
    pip install -r src/requirements.txt
    mkdir -p build
    zip -r build/demo-app.zip src/*

test:
    pytest src/test_app.py

clean:
    rm -rf build __pycache__ src/__pycache__