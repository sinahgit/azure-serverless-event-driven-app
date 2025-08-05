import os
import sys
from io import BytesIO
from unittest import mock

sys.path.append(os.path.abspath('src'))
import function_app as funcapp  # noqa: E402


class MockInputStream:
    def __init__(self, data: str, name: str = 'test.csv') -> None:
        self._stream = BytesIO(data.encode('utf-8'))
        self.name = name
        self.length = len(data)

    def read(self) -> bytes:
        return self._stream.read()


def test_main_processes_csv(monkeypatch):
    mock_container = mock.Mock()
    mock_event_client = mock.Mock()
    monkeypatch.setattr(funcapp, 'container', mock_container)
    monkeypatch.setattr(funcapp, 'event_client', mock_event_client)

    blob = MockInputStream('id,name\n1,Alice\n2,Bob')
    funcapp.main(blob)

    assert mock_container.upsert_item.call_count == 2
    mock_event_client.send.assert_called_once()
