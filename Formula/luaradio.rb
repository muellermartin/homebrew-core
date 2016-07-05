class Luaradio < Formula
  desc "lightweight, embeddable flow graph signal processing framework for SDR"
  homepage "http://luaradio.io/"
  url "https://github.com/vsergeev/luaradio/archive/v0.1.0.tar.gz"
  sha256 "4423f94c0bb259952eae7db11e4db4509dfa7c6e205798c35a095050c530212b"
  head "https://github.com/vsergeev/luaradio.git"

  depends_on "pkg-config" => :build
  depends_on "luajit"
  depends_on "fftw" => :recommended

  def install
    cd "embed" do
      system "make", "install", "PREFIX=#{prefix}"
    end
  end

  test do
    (testpath/"hello").write("Hello, world!")
    (testpath/"test.lua").write <<-EOS.undent
      local radio = require('radio')

      local PrintBytes = radio.block.factory("PrintBytes")

      function PrintBytes:instantiate()
          self:add_type_signature({radio.block.Input("in", radio.types.Byte)}, {})
      end

      function PrintBytes:process(c)
          for i = 0, c.length - 1 do
              io.write(string.char(c.data[i].value))
          end
      end

      local source = radio.RawFileSource("hello", radio.types.Byte, 1e6)
      local sink = PrintBytes()
      local top = radio.CompositeBlock()

      top:connect(source, sink)
      top:run()
    EOS

    assert_equal "Hello, world!", shell_output("#{bin}/luaradio test.lua")
  end
end
