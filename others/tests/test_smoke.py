from app.main import main

def test_smoke(capsys):
    main()
    out, _ = capsys.readouterr()
    assert "hello from trapp" in out
