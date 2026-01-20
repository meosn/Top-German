import AVFoundation

class SpeechManager {
    static let shared = SpeechManager()
    private let synth = AVSpeechSynthesizer()
    func speak(_ text: String) {
        if synth.isSpeaking { synth.stopSpeaking(at: .immediate) }
        let u = AVSpeechUtterance(string: text)
        u.voice = AVSpeechSynthesisVoice(language: "de-DE")
        u.rate = 0.45
        synth.speak(u)
    }
}

