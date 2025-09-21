class QuickdevSetup < Formula
  desc "Comprehensive macOS developer environment setup tool"
  homepage "https://github.com/Nagendracse1/quickdev-setup"
  url "https://github.com/Nagendracse1/quickdev-setup/archive/v1.0.0.tar.gz"
  sha256 "YOUR_SHA256_HASH_HERE"
  license "MIT"

  depends_on :macos

  def install
    bin.install "setup.sh" => "quickdev-setup"
  end

  test do
    system "#{bin}/quickdev-setup", "--help"
    system "#{bin}/quickdev-setup", "--version"
  end

  def caveats
    <<~EOS
      🚀 QuickDev Setup installed successfully!
      
      Usage:
        quickdev-setup              # Interactive setup
        quickdev-setup --auto       # Automatic setup
        quickdev-setup --help       # Show help
      
      For more information:
        https://github.com/Nagendracse1/quickdev-setup
    EOS
  end
end