"""RecompLauncher channel (RL_SESSION) end to end, against the built runtime.

Stands in for RecompLauncher's side on Windows: creates the named pipe, starts
mercenaries_recomp.exe with RL_SESSION, answers "hello" with "quiet", a list
whose rich presence script reads guest memory (the XBE header magic at
0x10000), and a "peek". Passes when the game connects as an "xbox" memory
recomp, loads the script, answers the peek with "XBEH" and sends the presence
line computed from guest memory.

Needs a built runtime and extracted retail files (USA or EU-FR):
  python tools/recomp/test_recomplauncher_channel_native.py [exe] [game_dir] [seconds]
Defaults: build/mercenaries/bin/Release/mercenaries_recomp.exe,
game_files/mercenaries-retail, 60 seconds. The game window opens meanwhile.
"""
import ctypes
import json
import os
import subprocess
import sys
import threading
import time
from ctypes import wintypes

from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
exe = sys.argv[1] if len(sys.argv) > 1 else str(ROOT / "build/mercenaries/bin/Release/mercenaries_recomp.exe")
game_dir = sys.argv[2] if len(sys.argv) > 2 else str(ROOT / "game_files/mercenaries-retail")
seconds = float(sys.argv[3]) if len(sys.argv) > 3 else 60.0
if not Path(exe).is_file() or not (Path(game_dir) / "default.xbe").is_file():
    sys.exit("Needs a built runtime and extracted retail files; see the module docstring.")
name = "RecompLauncher-fr-test"
path = "\\\\.\\pipe\\" + name

k32 = ctypes.WinDLL("kernel32", use_last_error=True)
k32.CreateNamedPipeW.restype = wintypes.HANDLE
k32.CreateNamedPipeW.argtypes = [wintypes.LPCWSTR, wintypes.DWORD, wintypes.DWORD, wintypes.DWORD,
                                 wintypes.DWORD, wintypes.DWORD, wintypes.DWORD, wintypes.LPVOID]
k32.ConnectNamedPipe.argtypes = [wintypes.HANDLE, wintypes.LPVOID]
k32.ReadFile.argtypes = [wintypes.HANDLE, wintypes.LPVOID, wintypes.DWORD,
                         ctypes.POINTER(wintypes.DWORD), wintypes.LPVOID]
k32.WriteFile.argtypes = [wintypes.HANDLE, wintypes.LPCVOID, wintypes.DWORD,
                          ctypes.POINTER(wintypes.DWORD), wintypes.LPVOID]
PIPE_ACCESS_DUPLEX, PIPE_TYPE_BYTE, PIPE_READMODE_BYTE, PIPE_WAIT = 3, 0, 0, 0
handle = k32.CreateNamedPipeW(path, PIPE_ACCESS_DUPLEX, PIPE_TYPE_BYTE | PIPE_READMODE_BYTE | PIPE_WAIT,
                              1, 65536, 65536, 0, None)
if handle in (None, wintypes.HANDLE(-1).value):
    sys.exit("CreateNamedPipe failed: %d" % ctypes.get_last_error())

got = []
connected_at = []


def write(obj):
    data = (json.dumps(obj) + "\n").encode()
    n = wintypes.DWORD()
    k32.WriteFile(handle, data, len(data), ctypes.byref(n), None)


def serve():
    k32.ConnectNamedPipe(handle, None)
    connected_at.append(time.time())
    pending = b""
    buf = ctypes.create_string_buffer(65536)
    while True:
        n = wintypes.DWORD()
        if not k32.ReadFile(handle, buf, len(buf), ctypes.byref(n), None) or n.value == 0:
            return
        pending += buf.raw[:n.value]
        while b"\n" in pending:
            line, pending = pending.split(b"\n", 1)
            m = json.loads(line)
            got.append((round(time.time() - connected_at[0], 1), m))
            if m.get("t") == "hello":
                write({"t": "quiet"})
                write({"t": "list", "achievements": [], "unlocked": [],
                       "rich_presence": "Format:Num\nFormatType=VALUE\n\nDisplay:\nXBE magic @Num(0xX10000)\n"})
                write({"t": "peek", "address": 0x10000, "size": 4, "seq": 7})


threading.Thread(target=serve, daemon=True).start()
env = dict(os.environ, RL_SESSION=name)
game = subprocess.Popen([exe, game_dir], env=env, cwd=os.path.dirname(exe),
                        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
time.sleep(seconds)
alive = game.poll() is None
subprocess.run(["taskkill", "/PID", str(game.pid), "/T", "/F"], capture_output=True)
time.sleep(1)
print("game still running at the end:", alive)
for at, m in got:
    print(f"+{at:5.1f}s", json.dumps(m))
types = [m.get("t") for _, m in got]
ok = (types[:1] == ["hello"] and got[0][1].get("console") == "xbox" and got[0][1].get("memory") is True
      and any(m.get("t") == "list_ok" and m.get("presence") is True for _, m in got)
      and any(m.get("t") == "mem" and m.get("seq") == 7 and m.get("hex") == "58424548" for _, m in got)
      and any(m.get("t") == "presence" and m.get("text") == "XBE magic {:,}".format(0x48454258) for _, m in got))
print("PASS" if ok else "FAIL")
sys.exit(0 if ok else 1)
