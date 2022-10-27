# frozen_string_literal: true

require_relative "../../visitor/framework_default"

class Configuring
  module Check
    class FrameworkDefaults
      attr_reader :checker

      class NewFrameworkDefaultsFile
        attr_reader :checker, :visitor

        def initialize(checker, visitor)
          @checker = checker
          @visitor = visitor
        end

        def check
          visitor.config_map[checker.rails_version].each_key do |config|
            app_config = config.gsub(/^self/, "config")

            next if defaults_file_content.include? app_config

            checker.errors << config
          end
        end

        private

        def defaults_file_content
          @defaults_file_content ||=
            checker.read(
              NEW_FRAMEWORK_DEFAULTS_PATH %
                { version: checker.rails_version.gsub(".", "_") }
            )
        end
      end

      def initialize(checker)
        @checker = checker
      end

      def check
        header, *defaults_by_version = documented_defaults

        NewFrameworkDefaultsFile.new(checker, visitor).check

        checker.doc.versioned_defaults =
          header +
            defaults_by_version
              .map { |defaults| check_defaults(defaults) }
              .flatten
      end

      private

      def app_config_tree
        checker.parse(APPLICATION_CONFIGURATION_PATH)
      end

      def check_defaults(defaults)
        header, configs = defaults[0], defaults[2, defaults.length - 3]

        version = header.match(/\d\.\d/)[0]

        generated_doc =
          visitor.config_map[version].map do |config, value|
            full_config =
              case config
              when /^[A-Z]/
                config
              when /^self/
                config.sub("self", "config")
              else
                "config.#{config}"
              end

            # TODO: bad fallback until I have a better solution for stringifiying
            # HashLiteral ast and multiline string ast
            value_with_fallback =
              if value.nil?
                configs.find { |c| c.include?(full_config) }.match(/ `(.*)`$/)[
                  1
                ]
              else
                value
              end

            "- [`#{full_config}`](##{full_config.tr("._", "-").downcase}): `#{value_with_fallback}`"
          end

        checker.errors.concat(generated_doc.difference(configs))

        [header, "", *generated_doc.sort, ""]
      end

      def documented_defaults
        checker
          .doc
          .versioned_defaults
          .slice_before { |line| line.start_with?("####") }
          .to_a
      end

      def visitor
        @visitor ||=
          begin
            visitor = Visitor::FrameworkDefault.new
            visitor.visit(app_config_tree)
            visitor
          end
      end
    end
  end
end
