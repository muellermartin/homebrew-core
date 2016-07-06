class LiquidDsp < Formula
  desc "Signal processing (DSP) library for software-defined radios"
  homepage "http://liquidsdr.org/"
  url "https://github.com/jgaeddert/liquid-dsp/archive/v1.2.0.tar.gz"
  sha256 "783854b63f5e9a9830dcd95b2c1d5c0bef7d10d22a0e27844a354b59283b6de3"

  depends_on "automake" => :build
  depends_on "autoconf" => :build
  depends_on "fftw" => :recommended

  fails_with :clang do
    cause <<-EOS.undent
      According to the troubleshooting section on the project's homepage
      http://liquidsdr.org/troubleshooting/ this "is likely a result of
      using Apple's default build of gcc (LLVM version 5.0) which by
      default uses extremely strict checking for compiling. Because the
      script generated by configure is pretty sloppy, LLVM coughs when
      trying to build it."
      EOS
  end

  def install
    # Build failed on OS X Mavericks, this might help
    # according to https://github.com/OP2/PyOP2/issues/471
    ENV.append "CFLAGS", "-Wa,-q"

    system "./reconf"
    system "./configure", "--prefix=#{prefix}"
    # Note: "make install" in one step does fail
    system "make"
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
