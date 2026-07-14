class Portps < Formula
  desc "Find or kill processes listening on TCP ports"
  homepage "https://github.com/overdraft-protocol/portps"
  license "MIT"
  head "https://github.com/overdraft-protocol/portps.git", branch: "main"

  # After publishing to npm, add a stable bottle source with:
  #   ./scripts/update-formula-sha.sh <version>
  # That command writes url + sha256 below head.

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
