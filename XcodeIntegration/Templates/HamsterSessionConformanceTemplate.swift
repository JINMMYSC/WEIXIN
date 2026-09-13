// Copy this extension next to the concrete session/controller type in the
// Hamster revision you build, then replace the five marked expressions only.
//
// extension YourHamsterRimeSession: WTHamsterRimeSessionProtocol {
//     var wtComposition: String { /* session context preedit */ "" }
//     var wtCandidates: [WTCandidate] { /* map Hamster/Rime candidates */ [] }
//     var wtIsComposing: Bool { /* composition active */ false }
//     func wtProcess(_ input: String) -> Bool { /* rimeAPI.process_key(session, ...) */ false }
//     func wtDrainCommit() -> String? { /* rimeAPI.get_commit + free_commit */ nil }
//     func wtSetInputMode(_ mode: WTInputMode) { /* select schema / set ascii_mode / T9 processor state */ }
//     func wtSelectCandidate(at index: Int) -> String? { /* select + committed text */ nil }
//     func wtDeleteBackward() { /* process BackSpace */ }
//     func wtReset() { /* clear composition */ }
// }
