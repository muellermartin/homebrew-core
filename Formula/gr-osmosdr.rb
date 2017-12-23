class GrOsmosdr < Formula
  desc "Osmocom GNU Radio Blocks"
  homepage "https://osmocom.org/projects/sdr/wiki/GrOsmoSDR"
  url "https://cgit.osmocom.org/gr-osmosdr/snapshot/gr-osmosdr-0.1.4.tar.xz"
  sha256 "1945d0d98fd4b600cb082970267ec2041528f13150422419cbd7febe2b622721"

  head do
    url "git://git.osmocom.org/gr-osmosdr"
    patch :DATA
  end

  depends_on "cmake" => :build
  depends_on "boost"
  depends_on "gnuradio"
  depends_on "librtlsdr" => :optional
  depends_on "hackrf" => :optional
  depends_on "libbladerf" => :optional
  depends_on "uhd" => :optional
  depends_on "airspy" => :optional
  depends_on "python" => :optional

  if build.head? && build.with?("librtlsdr")
    opoo "Building --HEAD --with-librtlsdr requires `brew install librtlsdr --HEAD`"
  end

  if build.with?("python")
    depends_on "swig" => :build

    resource "Cheetah" do
      url "https://files.pythonhosted.org/packages/source/C/Cheetah/Cheetah-2.4.4.tar.gz"
      sha256 "be308229f0c1e5e5af4f27d7ee06d90bb19e6af3059794e5fd536a6f29a9b550"
    end
  end

  def install
    cmake_args = std_cmake_args

    if build.with?("python")
      ENV.prepend_create_path "PYTHONPATH", libexec/"vendor/lib/python2.7/site-packages"

      resource("Cheetah").stage do
        system "python", *Language::Python.setup_install_args(libexec/"vendor")
      end
    else
      ohai "Building without Python support"
      cmake_args << "-DENABLE_PYTHON=OFF"
    end

    system "cmake", ".", *cmake_args
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include <osmosdr/device.h>
      int main() {
        osmosdr::device_t device();
        return 0;
      }
    EOS
    system ENV.cc, "test.cpp", "-L#{lib}", "-lgnuradio-osmosdr", "-o", "test"
    system "./test"
  end
end

__END__
diff --git a/lib/rtl_tcp/rtl_tcp_source_c.cc b/lib/rtl_tcp/rtl_tcp_source_c.cc
index ecdeee0..c962dd8 100644
--- a/lib/rtl_tcp/rtl_tcp_source_c.cc
+++ b/lib/rtl_tcp/rtl_tcp_source_c.cc
@@ -298,17 +298,17 @@ rtl_tcp_source_c::rtl_tcp_source_c(const std::string &args) :
   // set direct sampling
   struct command cmd;
 
-  cmd = { 0x09, htonl(direct_samp) };
+  cmd = (struct command){ 0x09, htonl(direct_samp) };
   send(d_socket, (const char*)&cmd, sizeof(cmd), 0);
   if (direct_samp)
     _no_tuner = true;
 
   // set offset tuning
-  cmd = { 0x0a, htonl(offset_tune) };
+  cmd = (struct command){ 0x0a, htonl(offset_tune) };
   send(d_socket, (const char*)&cmd, sizeof(cmd), 0);
 
   // set bias tee
-  cmd = { 0x0e, htonl(bias_tee) };
+  cmd = (struct command){ 0x0e, htonl(bias_tee) };
   send(d_socket, (const char*)&cmd, sizeof(cmd), 0);
 }
 
@@ -567,7 +567,7 @@ bool rtl_tcp_source_c::set_gain_mode( bool automatic, size_t chan )
   send(d_socket, (const char*)&cmd, sizeof(cmd), 0);
 
   // AGC mode
-  cmd = { 0x08, htonl(automatic) };
+  cmd = (struct command){ 0x08, htonl(automatic) };
   send(d_socket, (const char*)&cmd, sizeof(cmd), 0);
 
   _auto_gain = automatic;
