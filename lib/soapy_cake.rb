require 'active_support/core_ext/string'
require 'active_support/core_ext/date'
require 'soapy_cake/version'
require 'soapy_cake/client'
require 'soapy_cake/admin'
require 'soapy_cake/advertiser'
require 'soapy_cake/affiliate'

module SoapyCake
  API_VERSIONS = YAML.load(File.read(File.expand_path('../../api_versions.yml', __FILE__)))
end
