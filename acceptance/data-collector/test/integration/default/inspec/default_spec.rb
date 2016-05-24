#
# Helpers
#
def reset_counters
  describe command("curl http://localhost:9292/reset-counters") do
    its("exit_status") { should eq 0 }
  end
end

def check_counter_values(counters_to_check)
  counters_cmd = command("curl http://localhost:9292/counters")

  counters_to_check.each do |counter, value|
    describe "counter value check for #{counter}" do
      it "should be #{value}" do
        expect(JSON.load(counters_cmd.stdout)[counter]).to eq(value)
      end
    end
  end
end

#
# CCR with no data collector URL configured
#

# reset the API counters
reset_counters

# Run CCR
describe command("chef-client -z -c /etc/chef/no-endpoint.rb") do
  its("exit_status") { should eq 0 }
end

# There should be no counters
check_counter_values("run_start" => nil, "run_converge.success" => nil, "run_converge.failure" => nil)

#
# CCR, local mode, config in solo mode
#

# reset the API counters
reset_counters

# Run CCR
describe command("chef-client -z -c /etc/chef/solo-mode.rb") do
  its("exit_status") { should eq 0 }
end

# Check the counters
check_counter_values("run_start" => 1, "run_converge.success" => 1, "run_converge.failure" => nil)

#
# CCR, local mode, config in client mode
#

# reset the API counters
reset_counters

# Run CCR
describe command("chef-client -z -c /etc/chef/client-mode.rb") do
  its("exit_status") { should eq 0 }
end

# There should be no counters
check_counter_values("run_start" => nil, "run_converge.success" => nil, "run_converge.failure" => nil)

#
# CCR, local mode, config in both mode
#

# reset the API counters
reset_counters

# Run CCR
describe command("chef-client -z -c /etc/chef/both-mode.rb") do
  its("exit_status") { should eq 0 }
end

# Check the counters
check_counter_values("run_start" => 1, "run_converge.success" => 1, "run_converge.failure" => nil)

#
# CCR, local mode, config in solo mode, failed run
#

# reset the API counters
reset_counters

# Run CCR
describe command("chef-client -z -c /etc/chef/solo-mode.rb -r 'recipe[cookbook-that-does-not-exist::default]'") do
  its("exit_status") { should_not eq 0 }
end

# Check the counters
check_counter_values("run_start" => 1, "run_converge.success" => nil, "run_converge.failure" => 1)

