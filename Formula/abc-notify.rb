class AbcNotify < Formula
  desc "Desktop notifications for AI CLI tools (Claude Code, Codex)"
  homepage "https://github.com/JHSeo-git/abc-notify"
  url "https://github.com/JHSeo-git/abc-notify/archive/refs/tags/v#{version}.tar.gz"
  sha256 ""
  license "MIT"

  depends_on :macos
  depends_on "terminal-notifier"
  depends_on "jq"
  depends_on xcode: ["14.0", :build]

  def install
    bin.install "bin/abc-notify"
    pkgshare.install "VERSION"
    system "swift", "build", "-c", "release", "--disable-sandbox"
    bin.install ".build/release/abc-notify-native"
  end

  def caveats
    <<~EOS
      To register hooks for your AI CLI tools, run:
        abc-notify setup all

      To check your setup:
        abc-notify doctor
    EOS
  end
end
