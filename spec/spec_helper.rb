require 'gaah'
include Gaah

SPEC_ROOT = File.dirname(__FILE__)

def fixture(name)
  File.open(File.join(SPEC_ROOT, '/fixtures/', name)).read
end
