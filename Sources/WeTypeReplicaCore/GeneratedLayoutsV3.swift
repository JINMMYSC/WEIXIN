import Foundation

// Generated from the effective (inheritance-resolved) WeType 3.5.3 INI layouts.
public enum WTLayouts353Resolved {
    public static let t26Pinyin = WTKeyboardLayout(
        name: "t26_pinyin",
        baseSize: WTSize(width: 414.0, height: 224.0),
        items: [
            WTKeyboardItem(
                id: "KEY_Q", rect: WTRect(x: 5.0, y: 5.0, width: 35.0, height: 46.0),
                input: "q", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "1", downInput: nil, floatList: "Qq,0,0",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_W", rect: WTRect(x: 46.0, y: 5.0, width: 35.0, height: 46.0),
                input: "w", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "2", downInput: nil, floatList: "Ww,0,1",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_E", rect: WTRect(x: 87.0, y: 5.0, width: 35.0, height: 46.0),
                input: "e", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "3", downInput: nil, floatList: "Eeēéěè,0,1",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_R", rect: WTRect(x: 128.0, y: 5.0, width: 35.0, height: 46.0),
                input: "r", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "4", downInput: nil, floatList: "Rr,0,1",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_T", rect: WTRect(x: 169.0, y: 5.0, width: 35.0, height: 46.0),
                input: "t", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "5", downInput: nil, floatList: "Tt,0,1",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_Y", rect: WTRect(x: 210.0, y: 5.0, width: 35.0, height: 46.0),
                input: "y", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "6", downInput: nil, floatList: "Yy,0,1",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_U", rect: WTRect(x: 251.0, y: 5.0, width: 35.0, height: 46.0),
                input: "u", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "7", downInput: nil, floatList: "ūúǔùUu,4,5",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_I", rect: WTRect(x: 292.0, y: 5.0, width: 35.0, height: 46.0),
                input: "i", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "8", downInput: nil, floatList: "īíǐìIi,4,5",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_O", rect: WTRect(x: 332.0, y: 5.0, width: 35.0, height: 46.0),
                input: "o", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "9", downInput: nil, floatList: "ōóǒòOo,4,5",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_P", rect: WTRect(x: 374.0, y: 5.0, width: 35.0, height: 46.0),
                input: "p", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "0", downInput: nil, floatList: "pP,1,2",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_A", rect: WTRect(x: 20.0, y: 61.0, width: 35.0, height: 46.0),
                input: "a", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "-", downInput: nil, floatList: "Aaāáǎà,0,0",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_S", rect: WTRect(x: 66.0, y: 61.0, width: 35.0, height: 46.0),
                input: "s", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "/", downInput: nil, floatList: "Ss,0,1",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_D", rect: WTRect(x: 107.0, y: 61.0, width: 35.0, height: 46.0),
                input: "d", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "：", downInput: nil, floatList: "Dd,0,1",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_F", rect: WTRect(x: 148.0, y: 61.0, width: 35.0, height: 46.0),
                input: "f", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "；", downInput: nil, floatList: "Ff,0,1",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_G", rect: WTRect(x: 189.0, y: 61.0, width: 35.0, height: 46.0),
                input: "g", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "（", downInput: nil, floatList: "Gg,0,1",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_H", rect: WTRect(x: 230.0, y: 61.0, width: 35.0, height: 46.0),
                input: "h", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "）", downInput: nil, floatList: "Hh,0,1",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_J", rect: WTRect(x: 271.0, y: 61.0, width: 35.0, height: 46.0),
                input: "j", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "～", downInput: nil, floatList: "Jj,0,1",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_K", rect: WTRect(x: 312.0, y: 61.0, width: 35.0, height: 46.0),
                input: "k", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "“", downInput: nil, floatList: "Kk,0,1",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_L", rect: WTRect(x: 353.0, y: 61.0, width: 35.0, height: 46.0),
                input: "l", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "”", downInput: nil, floatList: "lL,1,2",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_Z", rect: WTRect(x: 66.0, y: 117.0, width: 35.0, height: 46.0),
                input: "z", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "@", downInput: nil, floatList: "Zz,0,1",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_X", rect: WTRect(x: 107.0, y: 117.0, width: 35.0, height: 46.0),
                input: "x", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: ".", downInput: nil, floatList: "Xx,0,1",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_C", rect: WTRect(x: 148.0, y: 117.0, width: 35.0, height: 46.0),
                input: "c", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "#", downInput: nil, floatList: "Cc,0,1",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_V", rect: WTRect(x: 189.0, y: 117.0, width: 35.0, height: 46.0),
                input: "v", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "、", downInput: nil, floatList: "Vvüǖǘǚǜ,0,1",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_B", rect: WTRect(x: 230.0, y: 117.0, width: 35.0, height: 46.0),
                input: "b", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "？", downInput: nil, floatList: "Bb,0,1",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_N", rect: WTRect(x: 271.0, y: 117.0, width: 35.0, height: 46.0),
                input: "n", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "！", downInput: nil, floatList: "Nn,0,1",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_M", rect: WTRect(x: 312.0, y: 117.0, width: 35.0, height: 46.0),
                input: "m", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "…", downInput: nil, floatList: "Mm,0,1",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_SHIFT", rect: WTRect(x: 5.0, y: 117.0, width: 46.0, height: 46.0),
                input: nil, title: nil, function: "shift",
                style: "STYLE_SHIFT", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_123", rect: WTRect(x: 5.0, y: 173.0, width: 46.0, height: 46.0),
                input: nil, title: nil, function: "123",
                style: "STYLE_123", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: "2"
            ),
            WTKeyboardItem(
                id: "KEY_EMOTION", rect: WTRect(x: 57.0, y: 173.0, width: 46.0, height: 46.0),
                input: nil, title: nil, function: "emoji",
                style: "STYLE_GRAY", image: "icon_keys_emoji",
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_SWITCH", rect: WTRect(x: 109.0, y: 173.0, width: 46.0, height: 46.0),
                input: nil, title: nil, function: "🌐",
                style: "STYLE_GRAY", image: "icon_keys_globe",
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_,", rect: WTRect(x: 161.0, y: 173.0, width: 46.0, height: 46.0),
                input: "['，','.']", title: nil, function: "funcQuote",
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "['。',]", downInput: nil, floatList: "。？！@…,0,0",
                font: "['23','23']", upFont: "['16','16']", subtitlePosition: "1",
                rule: "9", floatStyle: "1"
            ),
            WTKeyboardItem(
                id: "KEY_At", rect: WTRect(x: 213.0, y: 173.0, width: 36.0, height: 46.0),
                input: "@", title: nil, function: "funcAt",
                style: "STYLE_T26_LETTER", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: "22", upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: "1"
            ),
            WTKeyboardItem(
                id: "KEY_SPACE", rect: WTRect(x: 255.0, y: 173.0, width: 20.0, height: 46.0),
                input: nil, title: nil, function: "space",
                style: "STYLE_SPACE,STYLE_SPACE_VOICEINPUT", image: nil,
                upInput: nil, downInput: "。", floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: "0"
            ),
            WTKeyboardItem(
                id: "KEY_CHANGE", rect: WTRect(x: 281.0, y: 173.0, width: 36.0, height: 46.0),
                input: nil, title: nil, function: nil,
                style: "STYLE_LANGSWITCH,STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: "2"
            ),
            WTKeyboardItem(
                id: "KEY_DEL", rect: WTRect(x: 363.0, y: 117.0, width: 46.0, height: 46.0),
                input: nil, title: nil, function: "delete",
                style: "STYLE_DEL", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_RETURN", rect: WTRect(x: 323.0, y: 173.0, width: 86.0, height: 46.0),
                input: nil, title: nil, function: "return",
                style: "STYLE_RETURN", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
        ]
    )

    public static let t26En = WTKeyboardLayout(
        name: "t26_en",
        baseSize: WTSize(width: 414.0, height: 224.0),
        items: [
            WTKeyboardItem(
                id: "KEY_Q", rect: WTRect(x: 5.0, y: 5.0, width: 35.0, height: 46.0),
                input: "q", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "1", downInput: nil, floatList: "Qq,0,0",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_W", rect: WTRect(x: 46.0, y: 5.0, width: 35.0, height: 46.0),
                input: "w", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "2", downInput: nil, floatList: "Ww,0,1",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_E", rect: WTRect(x: 87.0, y: 5.0, width: 35.0, height: 46.0),
                input: "e", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "3", downInput: nil, floatList: "Eeēéěè,0,1",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_R", rect: WTRect(x: 128.0, y: 5.0, width: 35.0, height: 46.0),
                input: "r", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "4", downInput: nil, floatList: "Rr,0,1",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_T", rect: WTRect(x: 169.0, y: 5.0, width: 35.0, height: 46.0),
                input: "t", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "5", downInput: nil, floatList: "Tt,0,1",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_Y", rect: WTRect(x: 210.0, y: 5.0, width: 35.0, height: 46.0),
                input: "y", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "6", downInput: nil, floatList: "Yy,0,1",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_U", rect: WTRect(x: 251.0, y: 5.0, width: 35.0, height: 46.0),
                input: "u", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "7", downInput: nil, floatList: "ūúǔùUu,4,5",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_I", rect: WTRect(x: 292.0, y: 5.0, width: 35.0, height: 46.0),
                input: "i", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "8", downInput: nil, floatList: "īíǐìIi,4,5",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_O", rect: WTRect(x: 332.0, y: 5.0, width: 35.0, height: 46.0),
                input: "o", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "9", downInput: nil, floatList: "ōóǒòOo,4,5",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_P", rect: WTRect(x: 374.0, y: 5.0, width: 35.0, height: 46.0),
                input: "p", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "0", downInput: nil, floatList: "pP,1,2",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_A", rect: WTRect(x: 20.0, y: 61.0, width: 35.0, height: 46.0),
                input: "a", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "-", downInput: nil, floatList: "Aaāáǎà,0,0",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_S", rect: WTRect(x: 66.0, y: 61.0, width: 35.0, height: 46.0),
                input: "s", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "/", downInput: nil, floatList: "Ss,0,1",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_D", rect: WTRect(x: 107.0, y: 61.0, width: 35.0, height: 46.0),
                input: "d", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: ":", downInput: nil, floatList: "Dd,0,1",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_F", rect: WTRect(x: 148.0, y: 61.0, width: 35.0, height: 46.0),
                input: "f", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: ";", downInput: nil, floatList: "Ff,0,1",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_G", rect: WTRect(x: 189.0, y: 61.0, width: 35.0, height: 46.0),
                input: "g", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "(", downInput: nil, floatList: "Gg,0,1",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_H", rect: WTRect(x: 230.0, y: 61.0, width: 35.0, height: 46.0),
                input: "h", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: ")", downInput: nil, floatList: "Hh,0,1",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_J", rect: WTRect(x: 271.0, y: 61.0, width: 35.0, height: 46.0),
                input: "j", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "~", downInput: nil, floatList: "Jj,0,1",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_K", rect: WTRect(x: 312.0, y: 61.0, width: 35.0, height: 46.0),
                input: "k", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "'", downInput: nil, floatList: "Kk,0,1",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_L", rect: WTRect(x: 353.0, y: 61.0, width: 35.0, height: 46.0),
                input: "l", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "\"", downInput: nil, floatList: "lL,1,2",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_Z", rect: WTRect(x: 66.0, y: 117.0, width: 35.0, height: 46.0),
                input: "z", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "@", downInput: nil, floatList: "Zz,0,1",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_X", rect: WTRect(x: 107.0, y: 117.0, width: 35.0, height: 46.0),
                input: "x", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "_", downInput: nil, floatList: "Xx,0,1",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_C", rect: WTRect(x: 148.0, y: 117.0, width: 35.0, height: 46.0),
                input: "c", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "#", downInput: nil, floatList: "Cc,0,1",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_V", rect: WTRect(x: 189.0, y: 117.0, width: 35.0, height: 46.0),
                input: "v", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "&", downInput: nil, floatList: "Vvüǖǘǚǜ,0,1",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_B", rect: WTRect(x: 230.0, y: 117.0, width: 35.0, height: 46.0),
                input: "b", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "?", downInput: nil, floatList: "Bb,0,1",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_N", rect: WTRect(x: 271.0, y: 117.0, width: 35.0, height: 46.0),
                input: "n", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "!", downInput: nil, floatList: "Nn,0,1",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_M", rect: WTRect(x: 312.0, y: 117.0, width: 35.0, height: 46.0),
                input: "m", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "…", downInput: nil, floatList: "Mm,0,1",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_SHIFT", rect: WTRect(x: 5.0, y: 117.0, width: 46.0, height: 46.0),
                input: nil, title: nil, function: "shift",
                style: "STYLE_SHIFT", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_123", rect: WTRect(x: 5.0, y: 173.0, width: 46.0, height: 46.0),
                input: nil, title: nil, function: "123",
                style: "STYLE_123", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: "2"
            ),
            WTKeyboardItem(
                id: "KEY_EMOTION", rect: WTRect(x: 57.0, y: 173.0, width: 46.0, height: 46.0),
                input: nil, title: nil, function: "emoji",
                style: "STYLE_GRAY", image: "icon_keys_emoji",
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_SWITCH", rect: WTRect(x: 109.0, y: 173.0, width: 46.0, height: 46.0),
                input: nil, title: nil, function: "🌐",
                style: "STYLE_GRAY", image: "icon_keys_globe",
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_,", rect: WTRect(x: 161.0, y: 173.0, width: 46.0, height: 46.0),
                input: ".", title: nil, function: "funcQuote",
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "[',',]", downInput: nil, floatList: ",?!@,0,0",
                font: "['23','23']", upFont: "['16','16']", subtitlePosition: "1",
                rule: "9", floatStyle: "1"
            ),
            WTKeyboardItem(
                id: "KEY_At", rect: WTRect(x: 213.0, y: 173.0, width: 36.0, height: 46.0),
                input: "@", title: nil, function: "funcAt",
                style: "STYLE_T26_LETTER", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: "22", upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: "1"
            ),
            WTKeyboardItem(
                id: "KEY_SPACE", rect: WTRect(x: 255.0, y: 173.0, width: 20.0, height: 46.0),
                input: nil, title: nil, function: "space",
                style: "STYLE_SPACE,STYLE_SPACE_VOICEINPUT", image: nil,
                upInput: nil, downInput: "'. '", floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: "0"
            ),
            WTKeyboardItem(
                id: "KEY_CHANGE", rect: WTRect(x: 281.0, y: 173.0, width: 36.0, height: 46.0),
                input: nil, title: nil, function: nil,
                style: "STYLE_LANGSWITCH", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: "2"
            ),
            WTKeyboardItem(
                id: "KEY_DEL", rect: WTRect(x: 363.0, y: 117.0, width: 46.0, height: 46.0),
                input: nil, title: nil, function: "delete",
                style: "STYLE_DEL", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_RETURN", rect: WTRect(x: 323.0, y: 173.0, width: 86.0, height: 46.0),
                input: nil, title: nil, function: "return",
                style: "STYLE_RETURN", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
        ]
    )

    public static let t26Wubi = WTKeyboardLayout(
        name: "t26_wubi",
        baseSize: WTSize(width: 414.0, height: 224.0),
        items: [
            WTKeyboardItem(
                id: "KEY_Q", rect: WTRect(x: 5.0, y: 5.0, width: 35.0, height: 46.0),
                input: "q", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "1", downInput: nil, floatList: "Qq,0,0",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_W", rect: WTRect(x: 46.0, y: 5.0, width: 35.0, height: 46.0),
                input: "w", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "2", downInput: nil, floatList: "Ww,0,1",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_E", rect: WTRect(x: 87.0, y: 5.0, width: 35.0, height: 46.0),
                input: "e", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "3", downInput: nil, floatList: "Eeēéěè,0,1",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_R", rect: WTRect(x: 128.0, y: 5.0, width: 35.0, height: 46.0),
                input: "r", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "4", downInput: nil, floatList: "Rr,0,1",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_T", rect: WTRect(x: 169.0, y: 5.0, width: 35.0, height: 46.0),
                input: "t", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "5", downInput: nil, floatList: "Tt,0,1",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_Y", rect: WTRect(x: 210.0, y: 5.0, width: 35.0, height: 46.0),
                input: "y", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "6", downInput: nil, floatList: "Yy,0,1",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_U", rect: WTRect(x: 251.0, y: 5.0, width: 35.0, height: 46.0),
                input: "u", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "7", downInput: nil, floatList: "ūúǔùUu,4,5",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_I", rect: WTRect(x: 292.0, y: 5.0, width: 35.0, height: 46.0),
                input: "i", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "8", downInput: nil, floatList: "īíǐìIi,4,5",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_O", rect: WTRect(x: 332.0, y: 5.0, width: 35.0, height: 46.0),
                input: "o", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "9", downInput: nil, floatList: "ōóǒòOo,4,5",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_P", rect: WTRect(x: 374.0, y: 5.0, width: 35.0, height: 46.0),
                input: "p", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "0", downInput: nil, floatList: "pP,1,2",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_A", rect: WTRect(x: 20.0, y: 61.0, width: 35.0, height: 46.0),
                input: "a", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "-", downInput: nil, floatList: "Aaāáǎà,0,0",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_S", rect: WTRect(x: 66.0, y: 61.0, width: 35.0, height: 46.0),
                input: "s", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "/", downInput: nil, floatList: "Ss,0,1",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_D", rect: WTRect(x: 107.0, y: 61.0, width: 35.0, height: 46.0),
                input: "d", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "：", downInput: nil, floatList: "Dd,0,1",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_F", rect: WTRect(x: 148.0, y: 61.0, width: 35.0, height: 46.0),
                input: "f", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "；", downInput: nil, floatList: "Ff,0,1",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_G", rect: WTRect(x: 189.0, y: 61.0, width: 35.0, height: 46.0),
                input: "g", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "（", downInput: nil, floatList: "Gg,0,1",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_H", rect: WTRect(x: 230.0, y: 61.0, width: 35.0, height: 46.0),
                input: "h", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "）", downInput: nil, floatList: "Hh,0,1",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_J", rect: WTRect(x: 271.0, y: 61.0, width: 35.0, height: 46.0),
                input: "j", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "～", downInput: nil, floatList: "Jj,0,1",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_K", rect: WTRect(x: 312.0, y: 61.0, width: 35.0, height: 46.0),
                input: "k", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "“", downInput: nil, floatList: "Kk,0,1",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_L", rect: WTRect(x: 353.0, y: 61.0, width: 35.0, height: 46.0),
                input: "l", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "”", downInput: nil, floatList: "lL,1,2",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_Z", rect: WTRect(x: 66.0, y: 117.0, width: 35.0, height: 46.0),
                input: "z", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "@", downInput: nil, floatList: "Zz,0,1",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_X", rect: WTRect(x: 107.0, y: 117.0, width: 35.0, height: 46.0),
                input: "x", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: ".", downInput: nil, floatList: "Xx,0,1",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_C", rect: WTRect(x: 148.0, y: 117.0, width: 35.0, height: 46.0),
                input: "c", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "#", downInput: nil, floatList: "Cc,0,1",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_V", rect: WTRect(x: 189.0, y: 117.0, width: 35.0, height: 46.0),
                input: "v", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "、", downInput: nil, floatList: "Vvüǖǘǚǜ,0,1",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_B", rect: WTRect(x: 230.0, y: 117.0, width: 35.0, height: 46.0),
                input: "b", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "？", downInput: nil, floatList: "Bb,0,1",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_N", rect: WTRect(x: 271.0, y: 117.0, width: 35.0, height: 46.0),
                input: "n", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "！", downInput: nil, floatList: "Nn,0,1",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_M", rect: WTRect(x: 312.0, y: 117.0, width: 35.0, height: 46.0),
                input: "m", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "…", downInput: nil, floatList: "Mm,0,1",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_SHIFT", rect: WTRect(x: 5.0, y: 117.0, width: 46.0, height: 46.0),
                input: "", title: nil, function: "shiftWubi",
                style: "STYLE_SHIFT_WUBI", image: "",
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_123", rect: WTRect(x: 5.0, y: 173.0, width: 46.0, height: 46.0),
                input: nil, title: nil, function: "123",
                style: "STYLE_123", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: "2"
            ),
            WTKeyboardItem(
                id: "KEY_EMOTION", rect: WTRect(x: 57.0, y: 173.0, width: 46.0, height: 46.0),
                input: nil, title: nil, function: "emoji",
                style: "STYLE_GRAY", image: "icon_keys_emoji",
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_SWITCH", rect: WTRect(x: 109.0, y: 173.0, width: 46.0, height: 46.0),
                input: nil, title: nil, function: "🌐",
                style: "STYLE_GRAY", image: "icon_keys_globe",
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_,", rect: WTRect(x: 161.0, y: 173.0, width: 46.0, height: 46.0),
                input: "['，','.']", title: nil, function: "funcQuote",
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "['。',]", downInput: nil, floatList: "。？！@…,0,0",
                font: "['23','23']", upFont: "['16','16']", subtitlePosition: "1",
                rule: "9", floatStyle: "1"
            ),
            WTKeyboardItem(
                id: "KEY_At", rect: WTRect(x: 213.0, y: 173.0, width: 36.0, height: 46.0),
                input: "@", title: nil, function: "funcAt",
                style: "STYLE_T26_LETTER", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: "22", upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: "1"
            ),
            WTKeyboardItem(
                id: "KEY_SPACE", rect: WTRect(x: 255.0, y: 173.0, width: 20.0, height: 46.0),
                input: nil, title: nil, function: "space",
                style: "STYLE_SPACE,STYLE_SPACE_VOICEINPUT", image: nil,
                upInput: nil, downInput: "。", floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: "0"
            ),
            WTKeyboardItem(
                id: "KEY_CHANGE", rect: WTRect(x: 281.0, y: 173.0, width: 36.0, height: 46.0),
                input: nil, title: nil, function: nil,
                style: "STYLE_LANGSWITCH,STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: "2"
            ),
            WTKeyboardItem(
                id: "KEY_DEL", rect: WTRect(x: 363.0, y: 117.0, width: 46.0, height: 46.0),
                input: nil, title: nil, function: "delete",
                style: "STYLE_DEL", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_RETURN", rect: WTRect(x: 323.0, y: 173.0, width: 86.0, height: 46.0),
                input: nil, title: nil, function: "return",
                style: "STYLE_RETURN", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
        ]
    )

    public static let t26InnerHw = WTKeyboardLayout(
        name: "t26_inner_hw",
        baseSize: WTSize(width: 414.0, height: 224.0),
        items: [
            WTKeyboardItem(
                id: "KEY_Q", rect: WTRect(x: 5.0, y: 5.0, width: 35.0, height: 46.0),
                input: "q", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "1", downInput: nil, floatList: "Qq,0,0",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_W", rect: WTRect(x: 46.0, y: 5.0, width: 35.0, height: 46.0),
                input: "w", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "2", downInput: nil, floatList: "Ww,0,1",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_E", rect: WTRect(x: 87.0, y: 5.0, width: 35.0, height: 46.0),
                input: "e", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "3", downInput: nil, floatList: "Eeēéěè,0,1",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_R", rect: WTRect(x: 128.0, y: 5.0, width: 35.0, height: 46.0),
                input: "r", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "4", downInput: nil, floatList: "Rr,0,1",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_T", rect: WTRect(x: 169.0, y: 5.0, width: 35.0, height: 46.0),
                input: "t", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "5", downInput: nil, floatList: "Tt,0,1",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_Y", rect: WTRect(x: 210.0, y: 5.0, width: 35.0, height: 46.0),
                input: "y", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "6", downInput: nil, floatList: "Yy,0,1",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_U", rect: WTRect(x: 251.0, y: 5.0, width: 35.0, height: 46.0),
                input: "u", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "7", downInput: nil, floatList: "ūúǔùUu,4,5",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_I", rect: WTRect(x: 292.0, y: 5.0, width: 35.0, height: 46.0),
                input: "i", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "8", downInput: nil, floatList: "īíǐìIi,4,5",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_O", rect: WTRect(x: 332.0, y: 5.0, width: 35.0, height: 46.0),
                input: "o", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "9", downInput: nil, floatList: "ōóǒòOo,4,5",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_P", rect: WTRect(x: 374.0, y: 5.0, width: 35.0, height: 46.0),
                input: "p", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "0", downInput: nil, floatList: "pP,1,2",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_A", rect: WTRect(x: 20.0, y: 61.0, width: 35.0, height: 46.0),
                input: "a", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "-", downInput: nil, floatList: "Aaāáǎà,0,0",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_S", rect: WTRect(x: 66.0, y: 61.0, width: 35.0, height: 46.0),
                input: "s", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "/", downInput: nil, floatList: "Ss,0,1",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_D", rect: WTRect(x: 107.0, y: 61.0, width: 35.0, height: 46.0),
                input: "d", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "：", downInput: nil, floatList: "Dd,0,1",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_F", rect: WTRect(x: 148.0, y: 61.0, width: 35.0, height: 46.0),
                input: "f", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "；", downInput: nil, floatList: "Ff,0,1",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_G", rect: WTRect(x: 189.0, y: 61.0, width: 35.0, height: 46.0),
                input: "g", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "（", downInput: nil, floatList: "Gg,0,1",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_H", rect: WTRect(x: 230.0, y: 61.0, width: 35.0, height: 46.0),
                input: "h", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "）", downInput: nil, floatList: "Hh,0,1",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_J", rect: WTRect(x: 271.0, y: 61.0, width: 35.0, height: 46.0),
                input: "j", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "～", downInput: nil, floatList: "Jj,0,1",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_K", rect: WTRect(x: 312.0, y: 61.0, width: 35.0, height: 46.0),
                input: "k", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "“", downInput: nil, floatList: "Kk,0,1",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_L", rect: WTRect(x: 353.0, y: 61.0, width: 35.0, height: 46.0),
                input: "l", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "”", downInput: nil, floatList: "lL,1,2",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_Z", rect: WTRect(x: 66.0, y: 117.0, width: 35.0, height: 46.0),
                input: "z", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "@", downInput: nil, floatList: "Zz,0,1",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_X", rect: WTRect(x: 107.0, y: 117.0, width: 35.0, height: 46.0),
                input: "x", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: ".", downInput: nil, floatList: "Xx,0,1",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_C", rect: WTRect(x: 148.0, y: 117.0, width: 35.0, height: 46.0),
                input: "c", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "#", downInput: nil, floatList: "Cc,0,1",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_V", rect: WTRect(x: 189.0, y: 117.0, width: 35.0, height: 46.0),
                input: "v", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "、", downInput: nil, floatList: "Vvüǖǘǚǜ,0,1",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_B", rect: WTRect(x: 230.0, y: 117.0, width: 35.0, height: 46.0),
                input: "b", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "？", downInput: nil, floatList: "Bb,0,1",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_N", rect: WTRect(x: 271.0, y: 117.0, width: 35.0, height: 46.0),
                input: "n", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "！", downInput: nil, floatList: "Nn,0,1",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_M", rect: WTRect(x: 312.0, y: 117.0, width: 35.0, height: 46.0),
                input: "m", title: nil, function: nil,
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "…", downInput: nil, floatList: "Mm,0,1",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_SHIFT", rect: WTRect(x: 5.0, y: 117.0, width: 46.0, height: 46.0),
                input: nil, title: nil, function: "shift",
                style: "STYLE_SHIFT", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_123", rect: WTRect(x: 5.0, y: 173.0, width: 46.0, height: 46.0),
                input: nil, title: "", function: "123",
                style: "STYLE_BACK_GREEN", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: "2"
            ),
            WTKeyboardItem(
                id: "KEY_EMOTION", rect: WTRect(x: 57.0, y: 173.0, width: 46.0, height: 46.0),
                input: nil, title: nil, function: "emoji",
                style: "STYLE_GRAY", image: "icon_keys_emoji",
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_SWITCH", rect: WTRect(x: 109.0, y: 173.0, width: 46.0, height: 46.0),
                input: nil, title: nil, function: "🌐",
                style: "STYLE_GRAY", image: "icon_keys_globe",
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_,", rect: WTRect(x: 161.0, y: 173.0, width: 46.0, height: 46.0),
                input: "['，','.']", title: nil, function: "funcQuote",
                style: "STYLE_T26_LETTER", image: nil,
                upInput: "['。',]", downInput: nil, floatList: "。？！@…,0,0",
                font: "['23','23']", upFont: "['16','16']", subtitlePosition: "1",
                rule: "9", floatStyle: "1"
            ),
            WTKeyboardItem(
                id: "KEY_At", rect: WTRect(x: 213.0, y: 173.0, width: 36.0, height: 46.0),
                input: "@", title: nil, function: "funcAt",
                style: "STYLE_T26_LETTER", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: "22", upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: "1"
            ),
            WTKeyboardItem(
                id: "KEY_SPACE", rect: WTRect(x: 255.0, y: 173.0, width: 20.0, height: 46.0),
                input: nil, title: nil, function: "space",
                style: "STYLE_SPACE,STYLE_SPACE_VOICEINPUT", image: nil,
                upInput: nil, downInput: "。", floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: "0"
            ),
            WTKeyboardItem(
                id: "KEY_CHANGE", rect: WTRect(x: 281.0, y: 173.0, width: 36.0, height: 46.0),
                input: nil, title: nil, function: nil,
                style: "STYLE_LANGSWITCH,STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: "2"
            ),
            WTKeyboardItem(
                id: "KEY_DEL", rect: WTRect(x: 363.0, y: 117.0, width: 46.0, height: 46.0),
                input: nil, title: nil, function: "delete",
                style: "STYLE_DEL", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_RETURN", rect: WTRect(x: 323.0, y: 173.0, width: 86.0, height: 46.0),
                input: nil, title: nil, function: "return",
                style: "STYLE_RETURN", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
        ]
    )

    public static let t9Pinyin = WTKeyboardLayout(
        name: "t9_pinyin",
        baseSize: WTSize(width: 414.0, height: 224.0),
        items: [
            WTKeyboardItem(
                id: "VIEW_LIST", rect: WTRect(x: 5.0, y: 3.0, width: 69.0, height: 162.0),
                input: nil, title: nil, function: "symbols",
                style: "STYLE_GRAY", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_1", rect: WTRect(x: 79.0, y: 3.0, width: 81.0, height: 50.0),
                input: nil, title: nil, function: nil,
                style: "STYLE_T9_NUM0", image: nil,
                upInput: "1", downInput: nil, floatList: "/-_@#.,3,3",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_2", rect: WTRect(x: 166.0, y: 3.0, width: 81.0, height: 50.0),
                input: "ABC", title: nil, function: nil,
                style: "STYLE_T9_ABC", image: nil,
                upInput: "2", downInput: nil, floatList: "abcABC,3,3",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_3", rect: WTRect(x: 253.0, y: 3.0, width: 81.0, height: 50.0),
                input: "DEF", title: nil, function: nil,
                style: "STYLE_T9_ABC", image: nil,
                upInput: "3", downInput: nil, floatList: "defDEF,3,3",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_4", rect: WTRect(x: 79.0, y: 59.0, width: 81.0, height: 50.0),
                input: "GHI", title: nil, function: nil,
                style: "STYLE_T9_ABC", image: nil,
                upInput: "4", downInput: nil, floatList: "ghiGHI,3,3",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_5", rect: WTRect(x: 166.0, y: 59.0, width: 81.0, height: 50.0),
                input: "JKL", title: nil, function: nil,
                style: "STYLE_T9_ABC", image: nil,
                upInput: "5", downInput: nil, floatList: "jklJKL,3,3",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_6", rect: WTRect(x: 253.0, y: 59.0, width: 81.0, height: 50.0),
                input: "MNO", title: nil, function: nil,
                style: "STYLE_T9_ABC", image: nil,
                upInput: "6", downInput: nil, floatList: "mnoMNO,3,3",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_7", rect: WTRect(x: 79.0, y: 115.0, width: 81.0, height: 50.0),
                input: "PQRS", title: nil, function: nil,
                style: "STYLE_T9_ABC", image: nil,
                upInput: "7", downInput: nil, floatList: "pqrsPQRS,4,4",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_8", rect: WTRect(x: 166.0, y: 115.0, width: 81.0, height: 50.0),
                input: "TUV", title: nil, function: nil,
                style: "STYLE_T9_ABC", image: nil,
                upInput: "8", downInput: nil, floatList: "tuvTUV,3,3",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_9", rect: WTRect(x: 253.0, y: 115.0, width: 81.0, height: 50.0),
                input: "WXYZ", title: nil, function: nil,
                style: "STYLE_T9_ABC", image: nil,
                upInput: "9", downInput: nil, floatList: "wxyzWXYZ,4,4",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_SYMB", rect: WTRect(x: 5.0, y: 171.0, width: 48.0, height: 50.0),
                input: nil, title: "符号", function: "fullSymbol",
                style: "STYLE_SYM", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_SWITCH", rect: WTRect(x: 59.0, y: 171.0, width: 48.0, height: 50.0),
                input: nil, title: nil, function: "🌐",
                style: "STYLE_GRAY", image: "icon_keys_globe",
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_EMOTION", rect: WTRect(x: 341.0, y: 115.0, width: 69.0, height: 50.0),
                input: nil, title: nil, function: "emoji",
                style: "STYLE_GRAY", image: "icon_keys_emoji",
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_123", rect: WTRect(x: 166.0, y: 171.0, width: 47.0, height: 50.0),
                input: nil, title: nil, function: "123",
                style: "STYLE_123_T9", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_SPACE", rect: WTRect(x: 219.0, y: 171.0, width: 59.0, height: 50.0),
                input: nil, title: nil, function: "space",
                style: "STYLE_SPACE,STYLE_SPACE_VOICEINPUT", image: nil,
                upInput: "0", downInput: "。", floatList: nil,
                font: nil, upFont: "9", subtitlePosition: "3",
                rule: nil, floatStyle: "2"
            ),
            WTKeyboardItem(
                id: "KEY_ABC", rect: WTRect(x: 284.0, y: 171.0, width: 50.0, height: 50.0),
                input: nil, title: nil, function: nil,
                style: "STYLE_LANGSWITCH,STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: "2"
            ),
            WTKeyboardItem(
                id: "KEY_RETURN", rect: WTRect(x: 341.0, y: 171.0, width: 69.0, height: 50.0),
                input: nil, title: nil, function: "return",
                style: "STYLE_RETURN", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_DEL", rect: WTRect(x: 340.0, y: 3.0, width: 69.0, height: 50.0),
                input: nil, title: nil, function: "delete",
                style: "STYLE_DEL", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_ENTER", rect: WTRect(x: 340.0, y: 59.0, width: 69.0, height: 50.0),
                input: nil, title: "['换行','重输']", function: "newline",
                style: "STYLE_RETYPE", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
        ]
    )

    public static let t9Stroke = WTKeyboardLayout(
        name: "t9_stroke",
        baseSize: WTSize(width: 414.0, height: 224.0),
        items: [
            WTKeyboardItem(
                id: "VIEW_LIST", rect: WTRect(x: 5.0, y: 3.0, width: 69.0, height: 162.0),
                input: nil, title: nil, function: "symbols",
                style: "STYLE_GRAY", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_1", rect: WTRect(x: 79.0, y: 3.0, width: 81.0, height: 50.0),
                input: "(b)", title: "一", function: nil,
                style: "STYLE_T9_ABC", image: nil,
                upInput: "1", downInput: nil, floatList: "",
                font: "22", upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_2", rect: WTRect(x: 166.0, y: 3.0, width: 81.0, height: 50.0),
                input: "(c)", title: "丨", function: nil,
                style: "STYLE_T9_ABC", image: nil,
                upInput: "2", downInput: nil, floatList: "",
                font: "22", upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_3", rect: WTRect(x: 253.0, y: 3.0, width: 81.0, height: 50.0),
                input: "(d)", title: "丿", function: nil,
                style: "STYLE_T9_ABC", image: nil,
                upInput: "3", downInput: nil, floatList: "",
                font: "22", upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_4", rect: WTRect(x: 79.0, y: 59.0, width: 81.0, height: 50.0),
                input: "(e)", title: "丶", function: nil,
                style: "STYLE_T9_ABC", image: nil,
                upInput: "4", downInput: nil, floatList: "",
                font: "22", upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_5", rect: WTRect(x: 166.0, y: 59.0, width: 81.0, height: 50.0),
                input: "(f)", title: "ㄥ", function: nil,
                style: "STYLE_T9_ABC", image: nil,
                upInput: "5", downInput: nil, floatList: "",
                font: "22", upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_6", rect: WTRect(x: 253.0, y: 59.0, width: 81.0, height: 50.0),
                input: "(*)", title: "*", function: nil,
                style: "STYLE_T9_ABC", image: nil,
                upInput: "6", downInput: nil, floatList: "",
                font: "20", upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_7", rect: WTRect(x: 79.0, y: 115.0, width: 81.0, height: 50.0),
                input: "PQRS", title: nil, function: nil,
                style: "STYLE_T9_NUM0", image: nil,
                upInput: "7", downInput: nil, floatList: "/-_@#.,3,3",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_8", rect: WTRect(x: 166.0, y: 115.0, width: 81.0, height: 50.0),
                input: "，", title: "，", function: nil,
                style: "STYLE_T9_ABC", image: nil,
                upInput: "8", downInput: nil, floatList: "",
                font: "20", upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_9", rect: WTRect(x: 253.0, y: 115.0, width: 81.0, height: 50.0),
                input: "null", title: nil, function: nil,
                style: "STYLE_ENKB", image: nil,
                upInput: "9", downInput: nil, floatList: "",
                font: "16", upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_SYMB", rect: WTRect(x: 5.0, y: 171.0, width: 48.0, height: 50.0),
                input: nil, title: "符号", function: "fullSymbol",
                style: "STYLE_SYM", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_SWITCH", rect: WTRect(x: 59.0, y: 171.0, width: 48.0, height: 50.0),
                input: nil, title: nil, function: "🌐",
                style: "STYLE_GRAY", image: "icon_keys_globe",
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_EMOTION", rect: WTRect(x: 341.0, y: 115.0, width: 69.0, height: 50.0),
                input: nil, title: nil, function: "emoji",
                style: "STYLE_GRAY", image: "icon_keys_emoji",
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_123", rect: WTRect(x: 166.0, y: 171.0, width: 47.0, height: 50.0),
                input: nil, title: nil, function: "123",
                style: "STYLE_123_T9", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_SPACE", rect: WTRect(x: 219.0, y: 171.0, width: 59.0, height: 50.0),
                input: nil, title: nil, function: "space",
                style: "STYLE_SPACE,STYLE_SPACE_VOICEINPUT", image: nil,
                upInput: "0", downInput: "。", floatList: nil,
                font: nil, upFont: "9", subtitlePosition: "3",
                rule: nil, floatStyle: "2"
            ),
            WTKeyboardItem(
                id: "KEY_ABC", rect: WTRect(x: 284.0, y: 171.0, width: 50.0, height: 50.0),
                input: nil, title: nil, function: nil,
                style: "STYLE_LANGSWITCH,STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: "2"
            ),
            WTKeyboardItem(
                id: "KEY_RETURN", rect: WTRect(x: 341.0, y: 171.0, width: 69.0, height: 50.0),
                input: nil, title: nil, function: "return",
                style: "STYLE_RETURN", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_DEL", rect: WTRect(x: 340.0, y: 3.0, width: 69.0, height: 50.0),
                input: nil, title: nil, function: "delete",
                style: "STYLE_DEL", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_ENTER", rect: WTRect(x: 340.0, y: 59.0, width: 69.0, height: 50.0),
                input: nil, title: "['换行','重输']", function: "newline",
                style: "STYLE_RETYPE", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
        ]
    )

    public static let t9Number = WTKeyboardLayout(
        name: "t9_number",
        baseSize: WTSize(width: 414.0, height: 224.0),
        items: [
            WTKeyboardItem(
                id: "VIEW_LIST", rect: WTRect(x: 5.0, y: 3.0, width: 69.0, height: 162.0),
                input: nil, title: nil, function: "symbols",
                style: "STYLE_GRAY", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_1", rect: WTRect(x: 79.0, y: 3.0, width: 81.0, height: 50.0),
                input: "1", title: nil, function: nil,
                style: "STYLE_T9_1", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_BACK", rect: WTRect(x: 79.0, y: 171.0, width: 81.0, height: 50.0),
                input: nil, title: "返回", function: "backToInput",
                style: "STYLE_BACK_WHITE", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_2", rect: WTRect(x: 166.0, y: 3.0, width: 81.0, height: 50.0),
                input: "2", title: nil, function: nil,
                style: "STYLE_T9_1", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_3", rect: WTRect(x: 253.0, y: 3.0, width: 81.0, height: 50.0),
                input: "3", title: nil, function: nil,
                style: "STYLE_T9_1", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_4", rect: WTRect(x: 79.0, y: 59.0, width: 81.0, height: 50.0),
                input: "4", title: nil, function: nil,
                style: "STYLE_T9_1", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_5", rect: WTRect(x: 166.0, y: 59.0, width: 81.0, height: 50.0),
                input: "5", title: nil, function: nil,
                style: "STYLE_T9_1", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_6", rect: WTRect(x: 253.0, y: 59.0, width: 81.0, height: 50.0),
                input: "6", title: nil, function: nil,
                style: "STYLE_T9_1", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_7", rect: WTRect(x: 79.0, y: 115.0, width: 81.0, height: 50.0),
                input: "7", title: nil, function: nil,
                style: "STYLE_T9_1", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_8", rect: WTRect(x: 166.0, y: 115.0, width: 81.0, height: 50.0),
                input: "8", title: nil, function: nil,
                style: "STYLE_T9_1", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_9", rect: WTRect(x: 253.0, y: 115.0, width: 81.0, height: 50.0),
                input: "9", title: nil, function: nil,
                style: "STYLE_T9_1", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_0", rect: WTRect(x: 166.0, y: 171.0, width: 81.0, height: 50.0),
                input: "0", title: nil, function: nil,
                style: "STYLE_T9_1", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_EMOTION", rect: WTRect(x: 341.0, y: 115.0, width: 69.0, height: 50.0),
                input: nil, title: nil, function: "emoji",
                style: "STYLE_GRAY", image: "icon_keys_emoji",
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_RETURN", rect: WTRect(x: 341.0, y: 171.0, width: 69.0, height: 50.0),
                input: nil, title: nil, function: "return",
                style: "STYLE_RETURN", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_DEL", rect: WTRect(x: 340.0, y: 3.0, width: 69.0, height: 50.0),
                input: nil, title: nil, function: "delete",
                style: "STYLE_DEL", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_SYMB", rect: WTRect(x: 5.0, y: 171.0, width: 69.0, height: 50.0),
                input: nil, title: "符号", function: "fullSymbol",
                style: "STYLE_SYM", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_SPACE", rect: WTRect(x: 340.0, y: 59.0, width: 69.0, height: 50.0),
                input: "' '", title: "空格", function: "space",
                style: "STYLE_GRAY", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_.", rect: WTRect(x: 253.0, y: 171.0, width: 81.0, height: 50.0),
                input: ".", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: "19", upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
        ]
    )

    public static let t9Number26 = WTKeyboardLayout(
        name: "t9_number_26",
        baseSize: WTSize(width: 414.0, height: 224.0),
        items: [
            WTKeyboardItem(
                id: "VIEW_LIST", rect: WTRect(x: 5.0, y: 3.0, width: 69.0, height: 162.0),
                input: nil, title: nil, function: "symbols",
                style: "STYLE_GRAY", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_1", rect: WTRect(x: 79.0, y: 3.0, width: 81.0, height: 50.0),
                input: "1", title: nil, function: nil,
                style: "STYLE_T9_1", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_BACK", rect: WTRect(x: 5.0, y: 171.0, width: 69.0, height: 50.0),
                input: nil, title: "", function: "backToInput",
                style: "STYLE_BACK_GREEN", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_2", rect: WTRect(x: 166.0, y: 3.0, width: 81.0, height: 50.0),
                input: "2", title: nil, function: nil,
                style: "STYLE_T9_1", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_3", rect: WTRect(x: 253.0, y: 3.0, width: 81.0, height: 50.0),
                input: "3", title: nil, function: nil,
                style: "STYLE_T9_1", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_4", rect: WTRect(x: 79.0, y: 59.0, width: 81.0, height: 50.0),
                input: "4", title: nil, function: nil,
                style: "STYLE_T9_1", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_5", rect: WTRect(x: 166.0, y: 59.0, width: 81.0, height: 50.0),
                input: "5", title: nil, function: nil,
                style: "STYLE_T9_1", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_6", rect: WTRect(x: 253.0, y: 59.0, width: 81.0, height: 50.0),
                input: "6", title: nil, function: nil,
                style: "STYLE_T9_1", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_7", rect: WTRect(x: 79.0, y: 115.0, width: 81.0, height: 50.0),
                input: "7", title: nil, function: nil,
                style: "STYLE_T9_1", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_8", rect: WTRect(x: 166.0, y: 115.0, width: 81.0, height: 50.0),
                input: "8", title: nil, function: nil,
                style: "STYLE_T9_1", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_9", rect: WTRect(x: 253.0, y: 115.0, width: 81.0, height: 50.0),
                input: "9", title: nil, function: nil,
                style: "STYLE_T9_1", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_0", rect: WTRect(x: 166.0, y: 171.0, width: 81.0, height: 50.0),
                input: "0", title: nil, function: nil,
                style: "STYLE_T9_1", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_EMOTION", rect: WTRect(x: 341.0, y: 115.0, width: 69.0, height: 50.0),
                input: nil, title: nil, function: "emoji",
                style: "STYLE_GRAY", image: "icon_keys_emoji",
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_RETURN", rect: WTRect(x: 341.0, y: 171.0, width: 69.0, height: 50.0),
                input: nil, title: nil, function: "return",
                style: "STYLE_RETURN", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_DEL", rect: WTRect(x: 340.0, y: 3.0, width: 69.0, height: 50.0),
                input: nil, title: nil, function: "delete",
                style: "STYLE_DEL", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_SYMB", rect: WTRect(x: 79.0, y: 171.0, width: 81.0, height: 50.0),
                input: nil, title: "符号", function: "fullSymbol",
                style: "STYLE_BACK_WHITE", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_SPACE", rect: WTRect(x: 340.0, y: 59.0, width: 69.0, height: 50.0),
                input: "' '", title: "空格", function: "space",
                style: "STYLE_GRAY", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_.", rect: WTRect(x: 253.0, y: 171.0, width: 81.0, height: 50.0),
                input: ".", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: "19", upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
        ]
    )

    public static let t9InnerHw = WTKeyboardLayout(
        name: "t9_inner_hw",
        baseSize: WTSize(width: 414.0, height: 224.0),
        items: [
            WTKeyboardItem(
                id: "VIEW_LIST", rect: WTRect(x: 5.0, y: 3.0, width: 69.0, height: 162.0),
                input: nil, title: nil, function: "symbols",
                style: "STYLE_GRAY", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_1", rect: WTRect(x: 79.0, y: 3.0, width: 81.0, height: 50.0),
                input: nil, title: nil, function: nil,
                style: "STYLE_T9_NUM0", image: nil,
                upInput: "1", downInput: nil, floatList: "/-_@#.,3,3",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_2", rect: WTRect(x: 166.0, y: 3.0, width: 81.0, height: 50.0),
                input: "ABC", title: nil, function: nil,
                style: "STYLE_T9_ABC", image: nil,
                upInput: "2", downInput: nil, floatList: "abcABC,3,3",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_3", rect: WTRect(x: 253.0, y: 3.0, width: 81.0, height: 50.0),
                input: "DEF", title: nil, function: nil,
                style: "STYLE_T9_ABC", image: nil,
                upInput: "3", downInput: nil, floatList: "defDEF,3,3",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_4", rect: WTRect(x: 79.0, y: 59.0, width: 81.0, height: 50.0),
                input: "GHI", title: nil, function: nil,
                style: "STYLE_T9_ABC", image: nil,
                upInput: "4", downInput: nil, floatList: "ghiGHI,3,3",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_5", rect: WTRect(x: 166.0, y: 59.0, width: 81.0, height: 50.0),
                input: "JKL", title: nil, function: nil,
                style: "STYLE_T9_ABC", image: nil,
                upInput: "5", downInput: nil, floatList: "jklJKL,3,3",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_6", rect: WTRect(x: 253.0, y: 59.0, width: 81.0, height: 50.0),
                input: "MNO", title: nil, function: nil,
                style: "STYLE_T9_ABC", image: nil,
                upInput: "6", downInput: nil, floatList: "mnoMNO,3,3",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_7", rect: WTRect(x: 79.0, y: 115.0, width: 81.0, height: 50.0),
                input: "PQRS", title: nil, function: nil,
                style: "STYLE_T9_ABC", image: nil,
                upInput: "7", downInput: nil, floatList: "pqrsPQRS,4,4",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_8", rect: WTRect(x: 166.0, y: 115.0, width: 81.0, height: 50.0),
                input: "TUV", title: nil, function: nil,
                style: "STYLE_T9_ABC", image: nil,
                upInput: "8", downInput: nil, floatList: "tuvTUV,3,3",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_9", rect: WTRect(x: 253.0, y: 115.0, width: 81.0, height: 50.0),
                input: "WXYZ", title: nil, function: nil,
                style: "STYLE_T9_ABC", image: nil,
                upInput: "9", downInput: nil, floatList: "wxyzWXYZ,4,4",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_SYMB", rect: WTRect(x: 5.0, y: 171.0, width: 48.0, height: 50.0),
                input: nil, title: "", function: "fullSymbol",
                style: "STYLE_BACK_GREEN", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_SWITCH", rect: WTRect(x: 59.0, y: 171.0, width: 48.0, height: 50.0),
                input: nil, title: nil, function: "🌐",
                style: "STYLE_GRAY", image: "icon_keys_globe",
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_EMOTION", rect: WTRect(x: 341.0, y: 115.0, width: 69.0, height: 50.0),
                input: nil, title: nil, function: "emoji",
                style: "STYLE_GRAY", image: "icon_keys_emoji",
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_123", rect: WTRect(x: 166.0, y: 171.0, width: 47.0, height: 50.0),
                input: nil, title: nil, function: "123",
                style: "STYLE_123_T9", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_SPACE", rect: WTRect(x: 219.0, y: 171.0, width: 59.0, height: 50.0),
                input: nil, title: nil, function: "space",
                style: "STYLE_SPACE,STYLE_SPACE_VOICEINPUT", image: nil,
                upInput: "0", downInput: "。", floatList: nil,
                font: nil, upFont: "9", subtitlePosition: "3",
                rule: nil, floatStyle: "2"
            ),
            WTKeyboardItem(
                id: "KEY_ABC", rect: WTRect(x: 284.0, y: 171.0, width: 50.0, height: 50.0),
                input: nil, title: nil, function: "delete",
                style: "STYLE_DEL", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: "0"
            ),
            WTKeyboardItem(
                id: "KEY_RETURN", rect: WTRect(x: 341.0, y: 171.0, width: 69.0, height: 50.0),
                input: nil, title: nil, function: "return",
                style: "STYLE_RETURN", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_DEL", rect: WTRect(x: 340.0, y: 3.0, width: 69.0, height: 50.0),
                input: nil, title: nil, function: "flex",
                style: "STYLE_GRAY", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_ENTER", rect: WTRect(x: 340.0, y: 59.0, width: 69.0, height: 50.0),
                input: nil, title: "['换行','重输']", function: "newline",
                style: "STYLE_RETYPE", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
        ]
    )

    public static let t26CnSymbol = WTKeyboardLayout(
        name: "t26_cn_symbol",
        baseSize: WTSize(width: 414.0, height: 224.0),
        items: [
            WTKeyboardItem(
                id: "KEY_11", rect: WTRect(x: 5.0, y: 5.0, width: 35.0, height: 46.0),
                input: "1", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: "1①❶壹,0,0",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: "1"
            ),
            WTKeyboardItem(
                id: "KEY_12", rect: WTRect(x: 46.0, y: 5.0, width: 35.0, height: 46.0),
                input: "2", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: "2②❷贰,0,0",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: "1"
            ),
            WTKeyboardItem(
                id: "KEY_13", rect: WTRect(x: 87.0, y: 5.0, width: 35.0, height: 46.0),
                input: "3", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: "3③❸叁,0,0",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: "1"
            ),
            WTKeyboardItem(
                id: "KEY_14", rect: WTRect(x: 128.0, y: 5.0, width: 35.0, height: 46.0),
                input: "4", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: "4④❹肆,0,0",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: "1"
            ),
            WTKeyboardItem(
                id: "KEY_15", rect: WTRect(x: 169.0, y: 5.0, width: 35.0, height: 46.0),
                input: "5", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: "5⑤❺伍,0,0",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: "1"
            ),
            WTKeyboardItem(
                id: "KEY_16", rect: WTRect(x: 210.0, y: 5.0, width: 35.0, height: 46.0),
                input: "6", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: "陆❻⑥6,3,3",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: "1"
            ),
            WTKeyboardItem(
                id: "KEY_17", rect: WTRect(x: 251.0, y: 5.0, width: 35.0, height: 46.0),
                input: "7", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: "柒❼⑦7,3,3",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: "1"
            ),
            WTKeyboardItem(
                id: "KEY_18", rect: WTRect(x: 292.0, y: 5.0, width: 35.0, height: 46.0),
                input: "8", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: "捌❽⑧8,3,3",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: "1"
            ),
            WTKeyboardItem(
                id: "KEY_19", rect: WTRect(x: 333.0, y: 5.0, width: 35.0, height: 46.0),
                input: "9", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: "玖❾⑨9,3,3",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: "1"
            ),
            WTKeyboardItem(
                id: "KEY_10", rect: WTRect(x: 374.0, y: 5.0, width: 35.0, height: 46.0),
                input: "0", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: "零⓿⓪0,3,3",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: "1"
            ),
            WTKeyboardItem(
                id: "KEY_21", rect: WTRect(x: 5.0, y: 62.0, width: 35.0, height: 46.0),
                input: "-", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: "-_+×÷=,0,0",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: "1"
            ),
            WTKeyboardItem(
                id: "KEY_22", rect: WTRect(x: 46.0, y: 62.0, width: 35.0, height: 46.0),
                input: "/", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: "/／|｜\\＼,0,0,／｜＼",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: "1"
            ),
            WTKeyboardItem(
                id: "KEY_23", rect: WTRect(x: 87.0, y: 62.0, width: 35.0, height: 46.0),
                input: "：", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: "：:,0,0,:",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: "1"
            ),
            WTKeyboardItem(
                id: "KEY_24", rect: WTRect(x: 128.0, y: 62.0, width: 35.0, height: 46.0),
                input: "～", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: "～~—,0,0,~",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: "1"
            ),
            WTKeyboardItem(
                id: "KEY_25", rect: WTRect(x: 169.0, y: 62.0, width: 35.0, height: 46.0),
                input: "（", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: "<《【（([｛,3,3,(",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: "1"
            ),
            WTKeyboardItem(
                id: "KEY_26", rect: WTRect(x: 210.0, y: 62.0, width: 35.0, height: 46.0),
                input: "）", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: ">》】）)]｝,3,3,)",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: "1"
            ),
            WTKeyboardItem(
                id: "KEY_27", rect: WTRect(x: 251.0, y: 62.0, width: 35.0, height: 46.0),
                input: "…", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: "⋯…,1,1",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: "1"
            ),
            WTKeyboardItem(
                id: "KEY_28", rect: WTRect(x: 292.0, y: 62.0, width: 35.0, height: 46.0),
                input: "@", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: "",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: "1"
            ),
            WTKeyboardItem(
                id: "KEY_29", rect: WTRect(x: 333.0, y: 62.0, width: 35.0, height: 46.0),
                input: "“", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: "『「'\"‘“,5,5",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: "1"
            ),
            WTKeyboardItem(
                id: "KEY_20", rect: WTRect(x: 374.0, y: 62.0, width: 35.0, height: 46.0),
                input: "”", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: "』」'\"’”,5,5",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: "1"
            ),
            WTKeyboardItem(
                id: "KEY_33", rect: WTRect(x: 66.0, y: 117.0, width: 42.0, height: 46.0),
                input: "。", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: "。°,0,0",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: "1"
            ),
            WTKeyboardItem(
                id: "KEY_34", rect: WTRect(x: 114.0, y: 117.0, width: 42.0, height: 46.0),
                input: "，", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: "，,,0,0,,",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: "1"
            ),
            WTKeyboardItem(
                id: "KEY_35", rect: WTRect(x: 162.0, y: 117.0, width: 42.0, height: 46.0),
                input: "、", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: "、`,0,0",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: "1"
            ),
            WTKeyboardItem(
                id: "KEY_36", rect: WTRect(x: 210.0, y: 117.0, width: 42.0, height: 46.0),
                input: "？", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: "¿?？,2,2,?",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: "1"
            ),
            WTKeyboardItem(
                id: "KEY_37", rect: WTRect(x: 258.0, y: 117.0, width: 42.0, height: 46.0),
                input: "！", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: "¡!！,2,2,!",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: "1"
            ),
            WTKeyboardItem(
                id: "KEY_38", rect: WTRect(x: 306.0, y: 117.0, width: 42.0, height: 46.0),
                input: ".", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: "·.,1,1",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: "1"
            ),
            WTKeyboardItem(
                id: "KEY_SYMB", rect: WTRect(x: 5.0, y: 117.0, width: 46.0, height: 46.0),
                input: nil, title: "符号", function: "fullSymbol",
                style: "STYLE_SYM", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_DEL", rect: WTRect(x: 363.0, y: 117.0, width: 46.0, height: 46.0),
                input: nil, title: nil, function: "delete",
                style: "STYLE_DEL", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_BACK", rect: WTRect(x: 5.0, y: 173.0, width: 46.0, height: 46.0),
                input: nil, title: nil, function: "backToInput",
                style: "STYLE_BACK_GREEN", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: "2"
            ),
            WTKeyboardItem(
                id: "KEY_EMOTION", rect: WTRect(x: 57.0, y: 173.0, width: 46.0, height: 46.0),
                input: nil, title: nil, function: "emoji",
                style: "STYLE_GRAY", image: "icon_keys_emoji",
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_T9_123", rect: WTRect(x: 109.0, y: 173.0, width: 46.0, height: 46.0),
                input: nil, title: nil, function: "123",
                style: "STYLE_NORMAL", image: "icon_keys_number9",
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_SPACE", rect: WTRect(x: 161.0, y: 173.0, width: 46.0, height: 46.0),
                input: "' '", title: nil, function: "space",
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_NEWLINE", rect: WTRect(x: 213.0, y: 173.0, width: 46.0, height: 46.0),
                input: nil, title: "换行", function: "newline",
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: "14", upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_ENTER", rect: WTRect(x: 317.0, y: 173.0, width: 86.0, height: 46.0),
                input: nil, title: nil, function: "return",
                style: "STYLE_RETURN", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
        ]
    )

    public static let t26EnSymbol = WTKeyboardLayout(
        name: "t26_en_symbol",
        baseSize: WTSize(width: 414.0, height: 224.0),
        items: [
            WTKeyboardItem(
                id: "KEY_11", rect: WTRect(x: 5.0, y: 5.0, width: 35.0, height: 46.0),
                input: "1", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: "1①❶,0,0",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: "1"
            ),
            WTKeyboardItem(
                id: "KEY_12", rect: WTRect(x: 46.0, y: 5.0, width: 35.0, height: 46.0),
                input: "2", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: "2②❷,0,0",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: "1"
            ),
            WTKeyboardItem(
                id: "KEY_13", rect: WTRect(x: 87.0, y: 5.0, width: 35.0, height: 46.0),
                input: "3", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: "3③❸,0,0",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: "1"
            ),
            WTKeyboardItem(
                id: "KEY_14", rect: WTRect(x: 128.0, y: 5.0, width: 35.0, height: 46.0),
                input: "4", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: "4④❹,0,0",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: "1"
            ),
            WTKeyboardItem(
                id: "KEY_15", rect: WTRect(x: 169.0, y: 5.0, width: 35.0, height: 46.0),
                input: "5", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: "5⑤❺,0,0",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: "1"
            ),
            WTKeyboardItem(
                id: "KEY_16", rect: WTRect(x: 210.0, y: 5.0, width: 35.0, height: 46.0),
                input: "6", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: "❻⑥6,2,2",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: "1"
            ),
            WTKeyboardItem(
                id: "KEY_17", rect: WTRect(x: 251.0, y: 5.0, width: 35.0, height: 46.0),
                input: "7", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: "❼⑦7,2,2",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: "1"
            ),
            WTKeyboardItem(
                id: "KEY_18", rect: WTRect(x: 292.0, y: 5.0, width: 35.0, height: 46.0),
                input: "8", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: "❽⑧8,2,2",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: "1"
            ),
            WTKeyboardItem(
                id: "KEY_19", rect: WTRect(x: 333.0, y: 5.0, width: 35.0, height: 46.0),
                input: "9", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: "❾⑨9,2,2",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: "1"
            ),
            WTKeyboardItem(
                id: "KEY_10", rect: WTRect(x: 374.0, y: 5.0, width: 35.0, height: 46.0),
                input: "0", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: "⓿⓪0,2,2",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: "1"
            ),
            WTKeyboardItem(
                id: "KEY_21", rect: WTRect(x: 5.0, y: 62.0, width: 35.0, height: 46.0),
                input: "-", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: "-+×÷=•,0,0",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: "1"
            ),
            WTKeyboardItem(
                id: "KEY_22", rect: WTRect(x: 46.0, y: 62.0, width: 35.0, height: 46.0),
                input: "/", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: "/／|｜\\＼,0,0,／｜＼",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: "1"
            ),
            WTKeyboardItem(
                id: "KEY_23", rect: WTRect(x: 87.0, y: 62.0, width: 35.0, height: 46.0),
                input: ":", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: ":：,0,0,：",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: "1"
            ),
            WTKeyboardItem(
                id: "KEY_24", rect: WTRect(x: 128.0, y: 62.0, width: 35.0, height: 46.0),
                input: "_", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: "_＿,0,0,＿",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: "1"
            ),
            WTKeyboardItem(
                id: "KEY_25", rect: WTRect(x: 169.0, y: 62.0, width: 35.0, height: 46.0),
                input: "(", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: "<«(（[{,2,2,(",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: "1"
            ),
            WTKeyboardItem(
                id: "KEY_26", rect: WTRect(x: 210.0, y: 62.0, width: 35.0, height: 46.0),
                input: ")", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: ">»)）]},2,2,）",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: "1"
            ),
            WTKeyboardItem(
                id: "KEY_27", rect: WTRect(x: 251.0, y: 62.0, width: 35.0, height: 46.0),
                input: "#", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: "＃#,1,1,＃",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: "1"
            ),
            WTKeyboardItem(
                id: "KEY_28", rect: WTRect(x: 292.0, y: 62.0, width: 35.0, height: 46.0),
                input: "&", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: "§＆&,2,2,＃",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: "1"
            ),
            WTKeyboardItem(
                id: "KEY_29", rect: WTRect(x: 333.0, y: 62.0, width: 35.0, height: 46.0),
                input: "@", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: "",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: "1"
            ),
            WTKeyboardItem(
                id: "KEY_20", rect: WTRect(x: 374.0, y: 62.0, width: 35.0, height: 46.0),
                input: "\"", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: "„“”\",3,3",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: "1"
            ),
            WTKeyboardItem(
                id: "KEY_33", rect: WTRect(x: 66.0, y: 117.0, width: 42.0, height: 46.0),
                input: ".", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: ".。·,0,0,。",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: "1"
            ),
            WTKeyboardItem(
                id: "KEY_34", rect: WTRect(x: 114.0, y: 117.0, width: 42.0, height: 46.0),
                input: ",", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: ",，,0,0,，",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: "1"
            ),
            WTKeyboardItem(
                id: "KEY_35", rect: WTRect(x: 162.0, y: 117.0, width: 42.0, height: 46.0),
                input: "?", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: "¿？?,2,2,？",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: "1"
            ),
            WTKeyboardItem(
                id: "KEY_36", rect: WTRect(x: 210.0, y: 117.0, width: 42.0, height: 46.0),
                input: "!", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: "¡！!,2,2,！",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: "1"
            ),
            WTKeyboardItem(
                id: "KEY_37", rect: WTRect(x: 258.0, y: 117.0, width: 42.0, height: 46.0),
                input: "…", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: "⋯…,1,1",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: "1"
            ),
            WTKeyboardItem(
                id: "KEY_38", rect: WTRect(x: 306.0, y: 117.0, width: 42.0, height: 46.0),
                input: "'", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: "`‘’',3,3",
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: "1"
            ),
            WTKeyboardItem(
                id: "KEY_SYMB", rect: WTRect(x: 5.0, y: 117.0, width: 46.0, height: 46.0),
                input: nil, title: "符号", function: "fullSymbol",
                style: "STYLE_SYM", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_DEL", rect: WTRect(x: 363.0, y: 117.0, width: 46.0, height: 46.0),
                input: nil, title: nil, function: "delete",
                style: "STYLE_DEL", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_BACK", rect: WTRect(x: 5.0, y: 173.0, width: 46.0, height: 46.0),
                input: nil, title: nil, function: "backToInput",
                style: "STYLE_BACK_GREEN", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: "2"
            ),
            WTKeyboardItem(
                id: "KEY_EMOTION", rect: WTRect(x: 57.0, y: 173.0, width: 46.0, height: 46.0),
                input: nil, title: nil, function: "emoji",
                style: "STYLE_GRAY", image: "icon_keys_emoji",
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_T9_123", rect: WTRect(x: 109.0, y: 173.0, width: 46.0, height: 46.0),
                input: nil, title: nil, function: "123",
                style: "STYLE_NORMAL", image: "icon_keys_number9",
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_SPACE", rect: WTRect(x: 161.0, y: 173.0, width: 46.0, height: 46.0),
                input: "' '", title: nil, function: "space",
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_NEWLINE", rect: WTRect(x: 213.0, y: 173.0, width: 46.0, height: 46.0),
                input: nil, title: "换行", function: "newline",
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: "14", upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_ENTER", rect: WTRect(x: 317.0, y: 173.0, width: 86.0, height: 46.0),
                input: nil, title: nil, function: "return",
                style: "STYLE_RETURN", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
        ]
    )

    public static let fullSymbol = WTKeyboardLayout(
        name: "full_symbol",
        baseSize: WTSize(width: 375.0, height: 224.0),
        items: [
            WTKeyboardItem(
                id: "KEY_BACK", rect: WTRect(x: 3.0, y: 174.0, width: 50.0, height: 44.0),
                input: nil, title: "返回", function: "back",
                style: "STYLE_BACK", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_DEL", rect: WTRect(x: 322.0, y: 174.0, width: 50.0, height: 44.0),
                input: nil, title: nil, function: "delete",
                style: "STYLE_DEL", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
        ]
    )

    public static let fullSymbol2 = WTKeyboardLayout(
        name: "full_symbol2",
        baseSize: WTSize(width: 414.0, height: 224.0),
        items: [
            WTKeyboardItem(
                id: "KEY_00", rect: WTRect(x: 5.0, y: 5.0, width: 35.0, height: 46.0),
                input: "dynamic", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_01", rect: WTRect(x: 46.0, y: 5.0, width: 35.0, height: 46.0),
                input: "dynamic", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_02", rect: WTRect(x: 87.0, y: 5.0, width: 35.0, height: 46.0),
                input: "dynamic", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_03", rect: WTRect(x: 128.0, y: 5.0, width: 35.0, height: 46.0),
                input: "dynamic", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_04", rect: WTRect(x: 169.0, y: 5.0, width: 35.0, height: 46.0),
                input: "dynamic", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_05", rect: WTRect(x: 210.0, y: 5.0, width: 35.0, height: 46.0),
                input: "dynamic", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_06", rect: WTRect(x: 251.0, y: 5.0, width: 35.0, height: 46.0),
                input: "dynamic", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_07", rect: WTRect(x: 292.0, y: 5.0, width: 35.0, height: 46.0),
                input: "dynamic", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_08", rect: WTRect(x: 333.0, y: 5.0, width: 35.0, height: 46.0),
                input: "dynamic", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_09", rect: WTRect(x: 374.0, y: 5.0, width: 35.0, height: 46.0),
                input: "dynamic", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_10", rect: WTRect(x: 5.0, y: 62.0, width: 35.0, height: 46.0),
                input: "dynamic", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_11", rect: WTRect(x: 46.0, y: 62.0, width: 35.0, height: 46.0),
                input: "dynamic", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_12", rect: WTRect(x: 87.0, y: 62.0, width: 35.0, height: 46.0),
                input: "dynamic", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_13", rect: WTRect(x: 128.0, y: 62.0, width: 35.0, height: 46.0),
                input: "dynamic", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_14", rect: WTRect(x: 169.0, y: 62.0, width: 35.0, height: 46.0),
                input: "dynamic", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_15", rect: WTRect(x: 210.0, y: 62.0, width: 35.0, height: 46.0),
                input: "dynamic", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_16", rect: WTRect(x: 251.0, y: 62.0, width: 35.0, height: 46.0),
                input: "dynamic", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_17", rect: WTRect(x: 292.0, y: 62.0, width: 35.0, height: 46.0),
                input: "dynamic", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_18", rect: WTRect(x: 333.0, y: 62.0, width: 35.0, height: 46.0),
                input: "dynamic", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_19", rect: WTRect(x: 374.0, y: 62.0, width: 35.0, height: 46.0),
                input: "dynamic", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_20", rect: WTRect(x: 66.0, y: 117.0, width: 42.0, height: 46.0),
                input: "dynamic", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_21", rect: WTRect(x: 114.0, y: 117.0, width: 42.0, height: 46.0),
                input: "dynamic", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_22", rect: WTRect(x: 162.0, y: 117.0, width: 42.0, height: 46.0),
                input: "dynamic", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_23", rect: WTRect(x: 210.0, y: 117.0, width: 42.0, height: 46.0),
                input: "dynamic", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_24", rect: WTRect(x: 258.0, y: 117.0, width: 42.0, height: 46.0),
                input: "dynamic", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_25", rect: WTRect(x: 306.0, y: 117.0, width: 42.0, height: 46.0),
                input: "dynamic", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_26", rect: WTRect(x: 354.0, y: 117.0, width: 42.0, height: 46.0),
                input: "dynamic", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_27", rect: WTRect(x: 402.0, y: 117.0, width: 42.0, height: 46.0),
                input: "dynamic", title: nil, function: nil,
                style: "STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_123", rect: WTRect(x: 5.0, y: 117.0, width: 46.0, height: 46.0),
                input: nil, title: nil, function: "123",
                style: "STYLE_123", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_DEL", rect: WTRect(x: 450.0, y: 117.0, width: 46.0, height: 46.0),
                input: nil, title: nil, function: "delete",
                style: "STYLE_DEL", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_BACK", rect: WTRect(x: 5.0, y: 173.0, width: 46.0, height: 46.0),
                input: nil, title: nil, function: "backToInput",
                style: "STYLE_BACK_GREEN", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "VIEW_CATEGORYBAR", rect: WTRect(x: 57.0, y: 173.0, width: 46.0, height: 46.0),
                input: nil, title: nil, function: nil,
                style: nil, image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
        ]
    )

    public static let handwriting = WTKeyboardLayout(
        name: "handwriting",
        baseSize: WTSize(width: 375.0, height: 204.0),
        items: [
            WTKeyboardItem(
                id: "KEY_DEL", rect: WTRect(x: 330.0, y: 0.0, width: 42.0, height: 40.0),
                input: nil, title: nil, function: "delete",
                style: "STYLE_DEL", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "VIEW_LIST", rect: WTRect(x: 330.0, y: 43.0, width: 365.0, height: 60.0),
                input: nil, title: nil, function: "symbols",
                style: "STYLE_GRAY", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_SYMB", rect: WTRect(x: 3.0, y: 160.0, width: 42.0, height: 40.0),
                input: nil, title: "符号", function: "fullSymbol",
                style: "STYLE_SYM", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_123", rect: WTRect(x: 50.0, y: 160.0, width: 42.0, height: 40.0),
                input: nil, title: nil, function: "123",
                style: "STYLE_123", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_EMOTION", rect: WTRect(x: 97.0, y: 160.0, width: 42.0, height: 40.0),
                input: nil, title: nil, function: "emoji",
                style: "STYLE_GRAY", image: "icon_keys_emoji",
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_SWITCH", rect: WTRect(x: 144.0, y: 160.0, width: 42.0, height: 40.0),
                input: nil, title: nil, function: "🌐",
                style: "STYLE_GRAY", image: "icon_keys_globe",
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_ENKB", rect: WTRect(x: 193.0, y: 160.0, width: 42.0, height: 40.0),
                input: nil, title: nil, function: nil,
                style: "STYLE_NORMAL,STYLE_ENKB", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: "15", upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_SPACE", rect: WTRect(x: 242.0, y: 160.0, width: 92.0, height: 40.0),
                input: "' '", title: nil, function: "space",
                style: "STYLE_SPACE,STYLE_SPACE_VOICEINPUT", image: nil,
                upInput: nil, downInput: "。", floatList: nil,
                font: nil, upFont: "9", subtitlePosition: "3",
                rule: nil, floatStyle: "0"
            ),
            WTKeyboardItem(
                id: "KEY_ABC", rect: WTRect(x: 334.0, y: 160.0, width: 42.0, height: 40.0),
                input: nil, title: nil, function: nil,
                style: "STYLE_LANGSWITCH,STYLE_NORMAL", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: "2"
            ),
            WTKeyboardItem(
                id: "KEY_RETURN", rect: WTRect(x: 383.0, y: 160.0, width: 84.0, height: 40.0),
                input: nil, title: nil, function: "return",
                style: "STYLE_RETURN", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
        ]
    )

    public static let numpad = WTKeyboardLayout(
        name: "numpad",
        baseSize: WTSize(width: 375.0, height: 214.0),
        items: [
            WTKeyboardItem(
                id: "KEY_1", rect: WTRect(x: 3.0, y: 5.0, width: 119.0, height: 46.0),
                input: "1", title: nil, function: nil,
                style: "STYLE_NUMPAD", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_2", rect: WTRect(x: 128.0, y: 5.0, width: 119.0, height: 46.0),
                input: "2", title: nil, function: nil,
                style: "STYLE_NUMPAD", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_3", rect: WTRect(x: 253.0, y: 5.0, width: 119.0, height: 46.0),
                input: "3", title: nil, function: nil,
                style: "STYLE_NUMPAD", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_4", rect: WTRect(x: 3.0, y: 58.0, width: 119.0, height: 46.0),
                input: "4", title: nil, function: nil,
                style: "STYLE_NUMPAD", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_5", rect: WTRect(x: 128.0, y: 58.0, width: 119.0, height: 46.0),
                input: "5", title: nil, function: nil,
                style: "STYLE_NUMPAD", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_6", rect: WTRect(x: 253.0, y: 58.0, width: 119.0, height: 46.0),
                input: "6", title: nil, function: nil,
                style: "STYLE_NUMPAD", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_7", rect: WTRect(x: 3.0, y: 111.0, width: 119.0, height: 46.0),
                input: "7", title: nil, function: nil,
                style: "STYLE_NUMPAD", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_8", rect: WTRect(x: 128.0, y: 111.0, width: 119.0, height: 46.0),
                input: "8", title: nil, function: nil,
                style: "STYLE_NUMPAD", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_9", rect: WTRect(x: 253.0, y: 111.0, width: 119.0, height: 46.0),
                input: "9", title: nil, function: nil,
                style: "STYLE_NUMPAD", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_.", rect: WTRect(x: 3.0, y: 164.0, width: 119.0, height: 46.0),
                input: ".", title: nil, function: nil,
                style: "STYLE_GRAY", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: "Medium,20", upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_0", rect: WTRect(x: 128.0, y: 164.0, width: 119.0, height: 46.0),
                input: "0", title: nil, function: nil,
                style: "STYLE_NUMPAD", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
            WTKeyboardItem(
                id: "KEY_DEL", rect: WTRect(x: 253.0, y: 164.0, width: 119.0, height: 46.0),
                input: nil, title: nil, function: "delete",
                style: "STYLE_DEL", image: nil,
                upInput: nil, downInput: nil, floatList: nil,
                font: nil, upFont: nil, subtitlePosition: nil,
                rule: nil, floatStyle: nil
            ),
        ]
    )

}
