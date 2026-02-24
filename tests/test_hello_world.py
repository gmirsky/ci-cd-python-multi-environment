# Basic unit test coverage for the Hello World module.
from hello_world import get_message


def test_get_message_returns_hello_world() -> None:
    # Verify the expected greeting string is returned.
    assert get_message() == "Hello World"
