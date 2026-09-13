from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "iOSExtensions" / "WTQuickSendShareViewController.swift"


def main() -> None:
    text = SOURCE.read_text(encoding="utf-8")
    deinit_body = text.split("deinit {", 1)[1].split("}", 1)[0]
    assert "model.stop()" not in deinit_body, "deinit must not call a main actor-isolated model"
    assert "override func viewDidDisappear" in text, "Share controller must stop discovery from a main actor lifecycle callback"
    lifecycle_body = text.split("override func viewDidDisappear", 1)[1].split("}", 1)[0]
    assert "model.stop()" in lifecycle_body, "viewDidDisappear must stop the transfer service"
    print("CI repair verifier passed")


if __name__ == "__main__":
    main()
