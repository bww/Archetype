require 'formula'

class Archetype < Formula
  
  url 'https://bitbucket.org/bww/archetype.git'
  version '1'
  
  def install
    system "xcodebuild", "-target", "Archetype", "-configuration", "Release", "DSTROOT=/", "SYMROOT=build", "install"
  end
  
end
