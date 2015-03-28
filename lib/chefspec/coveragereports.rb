require 'chefspec'
require 'chefspec/coveragereports/version'
require 'fileutils'

module ChefSpec
  class CoverageReports
    class << self
      def method_added(name)
        # Only delegate public methods
        if method_defined?(name)
          instance_eval <<-EOH, __FILE__, __LINE__ + 1
            def #{name}(*args, &block)
              instance.public_send(:#{name}, *args, &block)
            end
          EOH
        end
      end
    end

    include Singleton

    attr_reader :reports

    def initialize
      @reports = {}
    end

    def add(type, output_file)
      reports[root.join('templates', "#{type}.erb")] = output_file
    end

    def add_custom(template, output_file)
      reports[template] = output_file
    end

    def clear_reports
      @reports = {}
    end

    def delete(type)
      reports[type] = nil
    end

    def generate_reports(data)
      @coverage             = {}
      @coverage['raw']      = data
      @coverage['coverage'] = process_report_data(data)

      reports.each do |template, output_file|
        erb = Erubis::Eruby.new(File.read(template))

        # Create the output directory if it doesnt exist
        dirname = File.dirname(output_file)
        FileUtils.mkdir_p(dirname) unless File.directory?(dirname)

        File.open(output_file, 'w') { |f| f.write(erb.evaluate(@coverage)) }
      end
    end

    private

    def root
      @root ||= Pathname.new(File.expand_path('../../../', __FILE__))
    end

    def process_report_data(data)
      results                           = {}
      results['files']                  = {}
      results['resources']              = {}
      results['resources']['all']       = {}
      results['resources']['covered']   = {}
      results['resources']['uncovered'] = {}
      results['totals']                 = {}

      # Process the report data
      data.map do |name, resource|
        resource_hash = generate_resource_hash(resource)

        # Store the file information
        results['files'][resource.source_file]        ||= {}
        results['files'][resource.source_file][name]  = resource_hash

        # Store the resources information
        results['resources']['all'][name]        = resource_hash
        results['resources']['covered'][name]    = resource_hash if resource.touched?
        results['resources']['uncovered'][name]  = resource_hash unless resource.touched?
      end

      # Sort the results
      results['files'].sort
      results['files'].each do |f, _|
        results['files'][f].sort
      end
      results['resources']['all'].sort
      results['resources']['covered'].sort
      results['resources']['uncovered'].sort

      # Calculate the derived totals
      results['totals']['resources']    = results['resources']['all'].size
      results['totals']['covered']      = results['resources']['covered'].size
      results['totals']['uncovered']    = results['resources']['uncovered'].size
      results['totals']['percent']      = ((results['totals']['covered'] / results['totals']['resources'].to_f) * 100).round(2)
      results['totals']['percent']      = 0 if results['totals']['percent'].nan?
      results['totals']['percent']      = 100 if results['totals']['percent'].infinite?

      results
    end

    def generate_resource_hash(resource)
      result = {}

      result['name']    = resource.to_s
      result['source']  = resource.source_file
      result['line']    = resource.source_line
      result['covered'] = resource.touched?

      result
    end
  end
end

require_relative 'coverage'
