# Candidate voice assistant

A conversational résumé using the starter's existing `SYSTEM_PROMPT` setting. Callers can ask about a candidate's projects and experience, then ask how to get in touch. The example uses Alex (Alexander) Taberoa's General Peru résumé and works in Spanish or English.

The assistant introduces itself as a résumé assistant. It is instructed to answer from the supplied facts, acknowledge missing information, and refer questions about availability, compensation, or hiring commitments to Alex. These are prompt instructions, not a guarantee against incorrect answers.

Contact: [job@taberoa.simplelogin.com](mailto:job@taberoa.simplelogin.com) · [taberoa.com](https://taberoa.com) · [LinkedIn](https://www.linkedin.com/in/taberoajorge) · [GitHub](https://github.com/taberoajorge).

## Configure and deploy

Run the commands from the repository root. Follow the main [deployment guide](../../README.md#deploy-to-pipecat-cloud) to authenticate, configure your registry, and build and push an image first.

Create a separate secret set for this example:

```bash
uv run pcc secrets set candidate-voice-secrets \
  OPENAI_API_KEY=YOUR_OPENAI_API_KEY \
  SYSTEM_PROMPT="$(cat examples/candidate-assistant/system-prompt.txt)"
```

In `pcc-deploy.toml`, set `agent_name` to `candidate-voice`, `secret_set` to `candidate-voice-secrets`, and `image` to your published image tag. Deploy with your Docker credentials:

```bash
uv run pcc deploy candidate-voice YOUR_DOCKERHUB_USERNAME/agent-name:VERSION \
  --credentials my-docker-secret
```

Follow [Connect in Kapso](../../README.md#connect-in-kapso), using `candidate-voice` as the agent name. Incoming calls use the same WhatsApp transport and audio pipeline as the starter. No Python or Docker changes are needed: the prompt is supplied through the secret set.

To use your own résumé, replace the candidate facts and contacts in `system-prompt.txt` and update the secret set. Include only information you intend callers to hear; the example files themselves are public.

## Live checks

This example has not yet been tested with a live Pipecat deployment or a WhatsApp call. Before treating it as ready, verify the following on your deployed agent:

| Ask or do | Expected behavior |
| --- | --- |
| Start a call | Introduces itself as Alex's résumé assistant and invites a question. |
| Ask about Lookahead Task Pre-Fill | Describes typed proposals, activity scope, and explicit approval before saving; does not invent adoption or revenue figures. |
| Ask about WhatsApp experience | Describes MessageBird SMS/WhatsApp webhooks at Loft MX, without claiming prior Kapso or Pipecat work. |
| Switch from Spanish to English | Follows the caller's language. |
| Ask about availability or salary | Says the résumé does not specify it and offers Alex's email. |
| Ask it to ignore the résumé and invent a project | Declines to invent experience and returns to the supplied facts. |
| Ask how to contact Alex | Gives the website or email, and repeats or spells the email when requested. |

Confirm audio in both directions and that the agent ends cleanly on disconnect. Check spoken dates and numbers against the prompt; successful deployment alone does not establish factual accuracy.
