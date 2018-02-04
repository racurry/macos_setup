class ManualTaskReporter

	attr_reader :task_list

	def initialize(task_list)
		@task_list = task_list
	end

	def report!
		puts "Now go do these things manually:"

    task_list.each_with_index do |todo, i|
      puts "  #{i+1}. - #{todo}"
    end
	end

end
