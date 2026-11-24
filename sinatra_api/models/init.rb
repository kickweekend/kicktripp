require_relative "../lib/model_support"
%w[user trip destination place activity expense participation].each { |name| require_relative name }
