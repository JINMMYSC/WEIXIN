# IME black-box parity harness

The largest behavioral gap is deliberate: WeType 3.5.3 ships Tencent's private `wxime`, while this clean-room project uses Hamster/librime. Static reverse engineering cannot honestly prove identical candidate ranking or learning behavior.

V8 therefore adds a repeatable **observable-behavior** harness instead of guessing internals:

- `IME_BEHAVIOR_CORPUS.json`: 30 starter probes covering ordinary pinyin, ambiguous segmentation, ranking, fuzzy-pinyin cases, long phrases and mixed English.
- `WTIMEBehaviorSnapshot`: stores only user-visible composition/candidates/commit state.
- `WTIMEBehaviorComparator`: compares reference vs replica, including exact composition/commit state and ordered candidate-prefix score.
- The same corpus can be replayed on a real iPhone against WeType 3.5.3 and the replica; resulting JSON captures can be compared without copying Tencent code.

Next device pass should expand this corpus with T9, shuangpin, Wubi, stroke, personalization/learning and correction probes. A compatibility shim should be added only where a stable observable mismatch is measured.
