# Ask AI (Grok Build)

Atelier can install the [Grok Build](https://x.ai/cli) command-line tool and open it with a short description of this system. The tool is optional. The desktop does not depend on it.

## Install

The shipped installer preset sets `AI=yes`. The summary line says `AI: yes (Grok Build)`. **Edit → AI** turns it off or on before anything is erased. On an 80x24 console that value shares the Gaming line so Start, Edit, and Quit stay on screen.

When it stays on, the installer downloads the official script and runs it on the live system:

```bash
curl -fsSL https://x.ai/cli/install.sh | bash
```

The files land in the new user's home (`~/.grok`). The installer does not sign in, and it does not store an API key. If the download fails, the result screen says so and the rest of the install is kept. After reboot, with the network up, the same command is the retry.

A new terminal picks up `~/.grok/bin` from `/etc/bash/bashrc.d/atelier.sh`.

To skip it on a VM, set AI to No on the summary, or put `AI=no` in a preset file.

## First launch

```bash
grok
```

The first launch opens a browser to sign in at grok.com. In a session without a browser, set `XAI_API_KEY` in your environment instead. The key stays on the machine. It is not part of the Atelier repository.

## Ask about this system

**Super+Shift+A**, or **Super+Alt+Space → Ask AI**, runs `atelier-ask`.

That opens a terminal (ghostty, or xterm) and starts Grok Build in `~/.local/share/atelier/diagnostics`. That directory's only project file is a link to `/usr/share/atelier/AGENTS.md`, which describes runit, the elogind sleep hooks, the NVIDIA command-line options, xbps, and the logs below. Grok trusts that directory on launch so the file is loaded.

**Super+Shift+G** is still the Grok website in a browser window. It is not the CLI.

If the command is missing, `atelier-ask` prints the curl install line.

## Logs the context file names

| Path | What it is |
|------|------------|
| `/var/log/atelier-pm.log` | elogind suspend/resume snapshot (`atelier-pm-log`, `atelier-nvidia`, `atelier-wifi`) |
| `/var/log/atelier-install.log` | Installer log copied onto the new system |

The system description also points at the source repository: https://github.com/GraeWolf/atelier
