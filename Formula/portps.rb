class Portps < Formula
  desc "Find or kill processes listening on TCP ports"
  homepage "https://github.com/overdraft-protocol/portps"
  license "MIT"
  url "https://github.com/overdraft-protocol/portps/archive/refs/tags/v1.1.2.tar.gz"
  sha256 "87d9d7f3b553852e9805afbd20dc7440da747c2315afe4f3df06843c9295c9ce"

  head "https://github.com/overdraft-protocol/portps.git", branch: "main"


  def install
    bin.install "bin/portps"
  end

  def caveats
    <<~EOS
      Prefer shell-safe patterns (no quoting / setup needed):
        portps 91%
        portps 9___

      Optional: portps --setup-shell
      (zsh noglob alias for classic * ? globs)
    EOS
  end

  test do
    output = shell_output("#{bin}/portps 2>&1", 1)
    assert_match "usage: portps", output
  end
end
