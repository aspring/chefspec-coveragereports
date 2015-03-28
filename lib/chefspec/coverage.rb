require 'chefspec/coverage'

ChefSpec::Coverage.class_eval do
  def report!
    # Borrowed from simplecov#41
    #
    # If an exception is thrown that isn't a "SystemExit", we need to capture
    # that error and re-raise.
    if $ERROR_INFO
      exit_status = $ERROR_INFO.is_a?(SystemExit) ? $ERROR_INFO.status : ChefSpec::Coverage::EXIT_FAILURE
    else
      exit_status = ChefSpec::Coverage::EXIT_SUCCESS
    end

    report = {}.tap do |h|
      h[:total]     = @collection.size
      h[:touched]   = @collection.count { |_, resource| resource.touched? }
      h[:coverage]  = ((h[:touched] / h[:total].to_f) * 100).round(2)
    end

    report[:untouched_resources] = @collection.map do |_, resource|
      resource unless resource.touched?
    end.compact

    template = ChefSpec.root.join('templates', 'coverage', 'human.erb')
    erb = Erubis::Eruby.new(File.read(template))
    puts erb.evaluate(report)

    # Generate the coverage reports
    ChefSpec::CoverageReports.generate_reports(@collection)

    # Ensure we exit correctly (#351)
    Kernel.exit(exit_status) if exit_status && exit_status > 0
  end
end
