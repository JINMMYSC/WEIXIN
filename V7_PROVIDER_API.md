# V7 provider API contract

The replica does not embed Tencent private endpoints. Network-backed surfaces are now functional through independently configured JSON HTTP providers.

Store configuration in the App Group container as `WeTypeReplica/provider-config.json` using `WTProviderConfiguration`.

Example:

```json
{
  "ai": {"url":"https://example.invalid/ai","headers":{},"timeoutSeconds":15},
  "translation": {"url":"https://example.invalid/translate","headers":{},"timeoutSeconds":15},
  "cloudCandidate": {"url":"https://example.invalid/candidates","headers":{},"timeoutSeconds":5},
  "hotWords": {"url":"https://example.invalid/hotwords","headers":{},"timeoutSeconds":15},
  "media": {"url":"https://example.invalid/media","headers":{},"timeoutSeconds":15}
}
```

Request/response shapes:

- AI POST request: `{ "tool": "askAI|rewrite|polish|copywriting|translate|custom", "text": "...", "instruction": null }`; response: `{ "text": "..." }`.
- Translation POST request: `{ "text":"...", "source":"中文", "target":"英文" }`; response: `{ "target":"...", "source":"...", "sourceLanguage":"中文", "targetLanguage":"英文" }` (only `target` is required).
- Cloud candidate POST request: `{ "composition":"nihao", "limit":8 }`; response: `{ "candidates":[{"text":"你好","comment":"云","score":9.2}] }`.
- Hot words POST request: `{ "locale":"zh-Hans" }`; response: `{ "items":[{"word":"...","rank":1,"tag":"热"}] }`.
- Media POST request: `{ "kind":"sticker|customSticker|gif", "query":"..." }`; response: `{ "items":[{"id":"...","title":"...","subtitle":null,"kind":"gif","remoteURL":"https://..."}] }`.

Provider headers are supported for development/integration. Production secrets should be supplied using an app-owned secure credential flow rather than committing them to source control.
