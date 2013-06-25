require 'yaml'

module Tangle
  module Secrets

    SECRETS_FILE = File.expand_path('../../config/secrets.yml', __dir__).freeze
    @@stash = YAML.load_file SECRETS_FILE

    def self.[](key)
      @@stash[key]
    end

  end
end
