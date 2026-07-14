class Portps < Formula
  desc "Find or kill processes listening on TCP ports"
  homepage "https://github.com/overdraft-protocol/portps"
  license "MIT"
  url "https://github.com/overdraft-protocol/portps/archive/refs/tags/v1.1.0.tar.gz"
  sha256 "5c7cde3b9c004c71f3363d9cc1c9e03a2e9e415f497d6efa5de3dbd833a63110"

  head "https://github.com/overdraft-protocol/portps.git", branch: "main"


  def install
    bin.install "bin/portps"
  end

  def caveats
    <<~EOS
      On zsh, add a noglob alias so unquoted globs work:
        alias portps='noglob command portps'
        portps 91*

      In bash, quote patterns (portps '91*'), or use shell-safe %/_ (portps 91%).
    EOS
  end

  test do
    output = shell_output("#{bin}/portps 2>&1", 1)
    assert_match "usage: portps", output
  end
end
