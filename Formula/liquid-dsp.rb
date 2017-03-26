class LiquidDsp < Formula
  desc "Signal processing (DSP) library for software-defined radios"
  homepage "http://liquidsdr.org/"
  url "https://github.com/jgaeddert/liquid-dsp/archive/v1.3.0.tar.gz"
  sha256 "b136343d644bc1441f7854f2d292bfa054e8d040c0b745879b205f6836dca0f0"
  head "https://github.com/jgaeddert/liquid-dsp.git"

  depends_on "automake" => :build
  depends_on "autoconf" => :build
  depends_on "fftw" => :recommended

  def install
    system "./bootstrap.sh"
    system "./configure", "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    # Based on examples/math_primitive_root_example.c
    (testpath/"test.c").write <<-EOS.undent
    #include <liquid/liquid.h>
    int main() {
        if (!liquid_is_prime(3))
            return 1;
        return 0;
    }
    EOS

    flags = %W[
      -I#{include}
      -L#{lib}
      -lliquid
    ]
    system ENV.cc, "-o", "test", "test.c", *flags
    system "./test"
  end
end
