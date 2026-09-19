import XCTest
@testable import WeTypeReplicaCore

final class DeepSeekProviderTests: XCTestCase {
    func testConfigurationBuildsChatCompletionsURL() {
        let configuration = WTDeepSeekConfiguration(apiKey: "sk-test",
                                                    baseURL: "https://api.deepseek.com/")
        XCTAssertEqual(configuration.chatCompletionsURL?.absoluteString,
                       "https://api.deepseek.com/chat/completions")
        XCTAssertEqual(configuration.authorizationHeader, "Bearer sk-test")
        XCTAssertTrue(configuration.isConfigured)
    }

    func testConfigurationWithoutKeyIsNotConfigured() {
        XCTAssertFalse(WTDeepSeekConfiguration().isConfigured)
        XCTAssertFalse(WTDeepSeekConfiguration(apiKey: "   ").isConfigured)
        XCTAssertNil(WTDeepSeekConfiguration(apiKey: "").authorizationHeader)
        XCTAssertFalse(WTDeepSeekConfiguration(apiKey: "sk", isEnabled: false).isConfigured)
        XCTAssertNil(WTDeepSeekConfiguration(apiKey: "sk", baseURL: "  ").chatCompletionsURL)
    }

    func testRequestEncodesModelMessagesAndStreamFlag() throws {
        let request = WTDeepSeekChatRequest(
            model: "deepseek-chat",
            messages: [.system("system"), .user("user")],
            stream: false
        )
        let data = try JSONEncoder().encode(request)
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        XCTAssertEqual(object["model"] as? String, "deepseek-chat")
        XCTAssertEqual(object["stream"] as? Bool, false)
        let messages = try XCTUnwrap(object["messages"] as? [[String: Any]])
        XCTAssertEqual(messages.count, 2)
        XCTAssertEqual(messages[0]["role"] as? String, "system")
        XCTAssertEqual(messages[1]["content"] as? String, "user")
    }

    func testDecoderReturnsTrimmedAssistantText() throws {
        let payload = #"{"choices":[{"message":{"role":"assistant","content":"  你好  "}}]}"#
        let text = try WTDeepSeekResponseDecoder.text(from: Data(payload.utf8), statusCode: 200)
        XCTAssertEqual(text, "你好")
    }

    func testDecoderSurfacesAPIErrorPayload() {
        let payload = #"{"error":{"message":"Invalid API key","type":"authentication_error"}}"#
        XCTAssertThrowsError(try WTDeepSeekResponseDecoder.text(from: Data(payload.utf8),
                                                               statusCode: 401)) { error in
            XCTAssertEqual(error as? WTDeepSeekError, .invalidStatus(401, "Invalid API key"))
        }
    }

    func testDecoderRejectsBlankAndMalformedPayloads() {
        let blank = #"{"choices":[{"message":{"role":"assistant","content":"   "}}]}"#
        XCTAssertThrowsError(try WTDeepSeekResponseDecoder.text(from: Data(blank.utf8),
                                                                statusCode: 200)) { error in
            XCTAssertEqual(error as? WTDeepSeekError, .emptyResponse)
        }
        XCTAssertThrowsError(try WTDeepSeekResponseDecoder.text(from: Data("{}".utf8),
                                                                statusCode: 200)) { error in
            XCTAssertEqual(error as? WTDeepSeekError, .emptyResponse)
        }
    }

    func testPromptsCarryInstructionAndUserText() {
        let translation = WTDeepSeekPrompt.translate(text: "你好", from: "中文", to: "英文")
        XCTAssertEqual(translation.count, 2)
        XCTAssertEqual(translation[0].role, "system")
        XCTAssertTrue(translation[0].content.contains("英文"))
        XCTAssertEqual(translation[1], .user("你好"))

        for tool in [WTAITool.askAI, .polish, .rewrite, .copywriting, .translate, .custom] {
            let messages = WTDeepSeekPrompt.askAI(tool: tool, text: "内容")
            XCTAssertEqual(messages.count, 2, "tool \(tool) must send system + user")
            XCTAssertEqual(messages[1], .user("内容"))
        }
    }

    func testWordListParsingAcceptsChineseAndASCIISeparators() {
        XCTAssertEqual(WTDeepSeekPrompt.parseWordList("你好，世界, 测试\n新词"),
                       ["你好", "世界", "测试", "新词"])
        XCTAssertEqual(WTDeepSeekPrompt.parseWordList("顿号、分隔"), ["顿号", "分隔"])
        XCTAssertEqual(WTDeepSeekPrompt.parseWordList("   "), [])
    }
}
