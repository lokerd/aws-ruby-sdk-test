# Set private IP address
require 'aws-sdk'

gem_package "aws-sdk" do
    action :install
end

ipconfiguration = {
    "lb1" => "110.0.1.11",
    "lb2" => "110.0.1.12"
    }

ec2 = AWS::EC2.new(:region => node[:opsworks][:instance][:region])

puts node[:opsworks][:instance][:hostname]

#puts ipconfiguration[node[:opsworks][:instance][:hostname]]

ruby_block "Set Private IP" do
    block do
    output = ec2.client.describe_network_interfaces( { :filters => [{ "name" => "attachment.instance-id", "values" => [node[:opsworks][:instance][:aws_instance_id]]}] })[:network_interface_set]
    eni = output[0][:network_interface_id]
    ec2.client.assign_private_ip_addresses({:allow_reassignment => true, :network_interface_id => eni, :private_ip_addresses => [ipconfiguration[node[:opsworks][:instance][:hostname]]]})
    end
    action :create
end 
