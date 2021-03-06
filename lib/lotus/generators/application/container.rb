require 'lotus/generators/abstract'
require 'lotus/generators/slice'

module Lotus
  module Generators
    module Application
      class Container < Abstract
        def initialize(command)
          super

          @slice_generator     = Slice.new(command)
          @lotus_head          = options.fetch(:lotus_head)
          @lotus_model_version = '~> 0.2'

          cli.class.source_root(source)
        end

        def start
          opts      = {
            app_name:            app_name,
            lotus_head:          @lotus_head,
            lotus_model_version: @lotus_model_version
          }

          templates = {
            'Gemfile.tt'                 => 'Gemfile',
            'config.ru.tt'               => 'config.ru',
            'config/environment.rb.tt'   => 'config/environment.rb',
            'config/.env.tt'             => 'config/.env',
            'config/.env.development.tt' => 'config/.env.development',
            'config/.env.test.tt'        => 'config/.env.test',
            'lib/app_name.rb.tt'         => "lib/#{ app_name }.rb",
          }

          empty_directories = [
            "db",
            "lib/#{ app_name }/entities",
            "lib/#{ app_name }/repositories"
          ]

          case options[:test]
          when 'rspec'
          else # minitest (default)
            templates.merge!(
              'Rakefile.minitest.tt'  => 'Rakefile',
              'spec_helper.rb.tt'     => 'spec/spec_helper.rb',
              'features_helper.rb.tt' => 'spec/features_helper.rb'
            )

            empty_directories << [
              "spec/#{ app_name }/entities",
              "spec/#{ app_name }/repositories"
            ]
          end

          templates.each do |src, dst|
            cli.template(source.join(src), target.join(dst), opts)
          end

          empty_directories.flatten.each do |dir|
            gitkeep = '.gitkeep'
            cli.template(source.join(gitkeep), target.join(dir, gitkeep), opts)
          end

          @slice_generator.start
        end
      end
    end
  end
end
