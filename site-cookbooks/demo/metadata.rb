#metadata.rb
name              "demo"
maintainer        "Lisa Hagemann"
maintainer_email  "chakram88@gmail.com"
description       "basic LAMP stack Chef provision"
version           "1.0.0"

recipe "demo", "Simple LAMP install"

depends "apt"
depends "php"
depends "apache"
depends "openssl"
depends "mysql"

%w{ debian ubuntu }.each do |os|
  supports os
end