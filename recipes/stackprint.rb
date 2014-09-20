# Set private IP address
require 'aws-sdk'

gem_package "aws-sdk" do
    action :install
end

ops = AWS::OpsWorks::Client.new(:region => "us-east-1")

stackdictionary = []

# This is how you use the Opsworks attributes, example below will instantiate to the same region that the instance lives in
# ec2 = AWS::EC2.new(:region => node[:opsworks][:instance][:region])

# These are examples of the filter syntax and how to pull elements from the results
# output = ec2.client.describe_network_interfaces( { :filters => [{ "name" => "attachment.instance-id", "values" => [node[:opsworks][:instance][:aws_instance_id]]}] })[:network_interface_set]
# ec2.client.assign_private_ip_addresses({:allow_reassignment => true, :network_interface_id => eni, :private_ip_addresses => [ipconfiguration[node[:opsworks][:instance][:hostname]]]})

ruby_block "Build Stack Dictionary" do
    block do
        stacks = ops.describe_stacks()
        stacks[:stacks].each do |stack|
           hash = { :id => stack[:stack_id], :name => stack[:name], :vpc => stack[:vpc_id] }
           stackdictionary.push(hash)
        end
    end
    action :create
end 

stackdictionary.each do |result|
    puts "#{result[:id]} #{result[:name]} #{result[:vpc]}"
end
