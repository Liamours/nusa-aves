import importlib
import os


def test_env_override():
    os.environ["NUSA_LOG_LEVEL"] = "DEBUG"
    os.environ["NUSA_MODEL_DIR"] = "/custom/path"
    import config
    importlib.reload(config)
    assert config.LOG_LEVEL == "DEBUG"
    assert config.MODEL_DIR == "/custom/path"
    del os.environ["NUSA_LOG_LEVEL"]
    del os.environ["NUSA_MODEL_DIR"]
    importlib.reload(config)
    assert config.LOG_LEVEL == "INFO"
    assert config.MODEL_DIR == "../model"


if __name__ == "__main__":
    test_env_override()
    print("ok")
