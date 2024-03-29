# frozen_string_literal: true

require "changelog"
require "pathname"

module ChangelogFixtures
  def changelog_fixture(name)
    path = Pathname.new(File.expand_path("../fixtures/#{name}", __dir__))

    raise ArgumentError, "#{name} fixture not found" unless path.exist?

    Changelog.new(path, path.read)
  end
end
