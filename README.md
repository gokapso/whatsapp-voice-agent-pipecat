# Kapso + Pipecat voice agent starter

Answer WhatsApp voice calls with AI. This repo connects [Kapso](https://kapso.ai)'s WhatsApp infrastructure to [Pipecat](https://pipecat.daily.co/)'s voice pipeline using OpenAI for speech and text.

The demo agent speaks neutral Latin American Spanish and introduces Kapso's platform.

## Prerequisites

- Python 3.10+ with [uv](https://docs.astral.sh/uv/) installed
- [Pipecat Cloud](https://pipecat.daily.co/) account
- [Kapso](https://kapso.ai) account with a WhatsApp number (calls enabled)
- OpenAI API key
- Docker Hub account (or another registry)

## Deploy to Pipecat Cloud

### Authenticate

```bash
uv run pcc auth login
```

### Set OpenAI key

Create a Pipecat Cloud secret set:

```bash
uv run pcc secrets set kapso-voice-secrets OPENAI_API_KEY=sk-...
```

### Store Docker credentials

```bash
uv run pcc credentials docker create my-docker-secret \
  --username YOUR_DOCKERHUB_USERNAME \
  --password YOUR_DOCKER_TOKEN
```

### Build and push

Edit `pcc-deploy.toml` and update the image tag to `YOUR_DOCKERHUB_USERNAME/agent-name:VERSION`, then:

```bash
uv run pcc docker build-push
```

### Deploy

```bash
uv run pcc deploy kapso-voice YOUR_DOCKERHUB_USERNAME/agent-name:VERSION --credentials my-docker-secret
```

Update `pcc-deploy.toml` with your agent name (`kapso-voice`) and secret set name (`kapso-voice-secrets`).

## Connect in Kapso

Full setup guide: [Kapso voice agent quickstart](https://docs.kapso.ai/build-voice-agents/quickstart)

1. Sign in to [app.kapso.ai](https://app.kapso.ai)
2. Go to **Voice agents** → **New voice agent**
3. Set provider to **Pipecat**
4. Paste your Pipecat public API key and agent name (`kapso-voice`)
5. Assign a WhatsApp number and mark it **Primary** + **Enabled**
6. Call the number to test

## Customize the agent

Edit `bot.py`:

- **System prompt**: Change `SYSTEM_PROMPT_FALLBACK` or set `SYSTEM_PROMPT` env var
- **Voice models**: Swap OpenAI services in `run_voice_pipeline` for other Pipecat-supported providers
- **Idle timeout**: Adjust `idle_timeout_secs` in the `PipelineTask` constructor

For an opt-in example using `SYSTEM_PROMPT`, see the [candidate voice assistant](examples/candidate-assistant/README.md). It answers questions about a résumé and provides contact details.

## Local development

```bash
uv sync
```

Copy `.env.example` to `.env` and add your `OPENAI_API_KEY`.

## How it works

1. Kapso receives WhatsApp voice call webhook from Meta
2. Kapso forwards webhook to Pipecat Cloud with `{kind: "whatsapp_connect", webhook, whatsapp_token, phone_number_id, context}`
3. Pipecat launches `bot.py` and connects to WhatsApp via SmallWebRTC transport
4. Audio flows: caller speech → OpenAI STT → GPT-4 → OpenAI TTS → caller
5. Call ends on 30s idle timeout or disconnect

### Context payload

Kapso includes a `context` object with each call containing:

- **project**: Your Kapso project info (name, ID)
- **config**: WhatsApp number details (display name, phone number ID, mode)
- **contact**: Caller profile (name, wa_id)
- **call**: Call metadata (direction, status, timestamps)
- **call_permission**: Permission status and expiry
- **conversation**: Full message history (all messages with timestamps and content)

The agent uses this context to personalize greetings and responses. Check `build_context_prompt()` in `bot.py` to see how it's formatted.

## Troubleshooting

**No audio back**: Check `OPENAI_API_KEY` is set in Pipecat secrets and view Pipecat logs for TTS errors

**Build fails**: Verify Docker credentials with `docker login` and retry with `--debug` flag

**Call doesn't connect**: Confirm WhatsApp number has calls enabled in Kapso and voice agent assignment is marked Primary

## License

BSD 2-Clause
