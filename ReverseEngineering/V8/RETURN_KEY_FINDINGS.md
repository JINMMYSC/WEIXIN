# WeType 3.5.3 return-key findings (V8)

The original binary exposes separate `WBReturnKeyView` and `WBNewlineKeyView` classes and selectors including `returnKeyType`, `returnKeyTypeDidChange`, `returnKeyTypeForSession:`, `returnKeyView`, `doNewlineAction`, and `actionHasNewLine`.

`style.ini` also gives `STYLE_RETURN` `RULE=1` with two visual branches: a neutral branch and a brand-green `#23C891` branch. This is strong static evidence that the key is host-context driven rather than permanently displaying one label/style.

V8 now mirrors that architecture:

- reads `textDocumentProxy.returnKeyType` from the active host text field;
- maps default/go/join/next/route/search/send/done/continue/etc. to localized return labels;
- keeps normal newline neutral;
- uses the green WeType branch for semantic action return keys;
- refreshes host traits together with IME context changes.

Actual per-app behavior still needs same-device regression testing because applications can expose unusual or changing `UITextInputTraits`.
