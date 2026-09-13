# Hamster public-revision integration note

The project should pin a **publicly available Hamster source revision** rather than silently assuming current App Store internals.

Current public project documentation still identifies Hamster as a Rime/librime iOS frontend and its build flow as `make framework`, `make schema`, then Xcode. The maintainer stated in 2026 that code after 2.1.1 was no longer open-sourced and that Hamster would receive maintenance/Rime updates rather than new features.

For that reason V8 keeps the UI overlay independent through `WTHamsterRimeSessionProtocol`. The final concrete adapter should be written against the exact public revision checked out on the Mac build machine and should map only the seven observable operations already isolated by the bridge: composition, candidates, composing state, process key, select candidate, backspace and reset.

Do not bind the replica to guessed class names from a newer closed build.
