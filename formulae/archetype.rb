require 'formula'

class Archetype < Formula
  
  url 'https://bitbucket.org/bww/archetype.git'
  version '1'
  
  def install
    # build Archetype
    system "xcodebuild", "-target", "Archetype", "-configuration", "Release", "DSTROOT=/", "INSTALL_PATH=#{prefix}", "SYMROOT=build", "install"
    # install the tool
    bin.install("#{prefix}/archetype");
    # install the manpage
    man.install("Archetype/resources/man1/archetype.1");
  end
  
end
