# ~*~ encoding: utf-8 ~*~
module Enumerable

  # Freezes elements and nested containers recursively.
  def deep_freeze
    each { |o| o.respond_to?(:deep_freeze) ? o.deep_freeze : o.freeze }
    freeze
  end

end
