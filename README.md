# Circle to Search for Linux

Android's *Circle to Search* for **Hyprland**. Shake your mouse hard, drag a box
around anything on screen, then:

- **Google Lens**: opens Lens in your browser with the crop and your optional text prompt, or
- **Ask AI**: sends the crop and prompt to **Groq, Gemini, ChatGPT or Claude** and shows a
  short answer in a translucent bubble next to your cursor.

## Install (1 minute)

```sh
git clone https://github.com/nevil-sanish/circle-to-search-linux
cd circle-to-search-linux
./install.sh
circle-to-search setup     # optional: API keys + model for "Ask AI"
```

`install.sh` installs the dependencies (pacman / apt / dnf / zypper), copies the script to
`~/.local/bin`, starts a systemd user service and adds two keybinds to your Hyprland config.
Run it again to update; `./install.sh uninstall` removes it.

## Use

| Action | What happens |
| --- | --- |
| Shake the mouse fast, side to side | A star follows the cursor for 3 s: drag a box |
| `Ctrl+Alt+G` | Same, without shaking. The AI answer stays **hidden** |
| Hold `Ctrl+Alt+A` | Shows the hidden answer while held |
| Type a prompt, then `Enter` / **Ask AI** | Ask the LLM about the crop |
| **Google Lens** | Lens search with the crop and the prompt as text |
| `Esc` | Cancel |

The answer bubble lets clicks through and disappears after 15 s.

## AI setup

```sh
circle-to-search setup
```

Paste keys for any of `groq`, `gemini`, `openai`, `claude` (Enter keeps the current key,
`-` removes it), pick the active provider, then pick a model from the provider's live list.
Choose a model that accepts images, e.g. Groq `meta-llama/llama-4-scout-17b-16e-instruct`,
`gemini-2.5-flash-lite`, `gpt-4.1-mini` or a Claude Haiku model.

Keys are stored in `~/.config/circle-to-search/config.json` (mode 600) and are sent only to
that provider's API.

Token use is kept low: the crop is downscaled to 768 px JPEG (OpenAI uses `detail: low`),
the model is told to answer in at most 2 sentences, and replies are capped at 200 tokens.
Tune `AI_MAX_SIDE`, `AI_MAX_TOKENS`, `POPUP_S` and the shake sensitivity at the top of
`circle-to-search`.

> Reasoning models (GPT-5, Gemini 2.5 Flash/Pro) can spend the 200 tokens thinking and return
> nothing. Use a fast non-reasoning model.

## Requirements

Hyprland (Wayland), Python 3, PyGObject + GTK 3, gtk-layer-shell, grim, python-requests,
xdg-utils. The cursor position comes from Hyprland's IPC socket, so other compositors are not
supported yet.

## Troubleshooting

```sh
systemctl --user status circle-to-search
journalctl --user -u circle-to-search -f
CTS_TEST=1 circle-to-search      # shake-detector self-test, prints "ok"
```

## License

MIT
