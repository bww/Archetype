require 'formula'

class Archetype < Formula
  
  url 'https://github.com/bww/Archetype.git'
  version '2'
  
  def install
    # build Archetype
    system "xcodebuild", "-target", "Archetype", "-configuration", "Release", "DSTROOT=/", "INSTALL_PATH=#{prefix}", "SYMROOT=build", "install"
    # install the tool
    bin.install("#{prefix}/archetype");
    # install the manpage
    man1.install("Archetype/resources/man1/archetype.1");
  end
  
end
