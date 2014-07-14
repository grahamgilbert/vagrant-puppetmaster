require 'spec_helper'
require 'puppet'
require 'puppet/face'
describe Puppet::Face[:dashboard, :current] do
  let :dashboard_options do
    {:enc_server => 'enc_server', :enc_port => '3001', :enc_auth_user => 'user', :enc_auth_passwd => 'pw'}
  end
  let :connection do
    mock('Puppet::Dashboard::Classifier')
  end

  describe 'action list' do
    it 'should default enc_server to Puppet[:server] and port to 3000' do
      defaults = {:enc_server =>'master', :enc_port => 3000, :enc_auth_user => nil, :enc_auth_passwd => nil}
      Puppet.expects(:[]).with(:server).returns('master')
      Puppet::Dashboard::Classifier.expects(:connection).with(defaults).returns connection
      connection.expects(:list).with('node_classes', 'Listing classes')
      subject.list('classes', {})
    end
    {'classes' => 'node_classes', 'nodes' => 'nodes', 'groups' => 'node_groups'}.each do |k,v|
      it "should convert the types into their dashboard names" do
        Puppet::Dashboard::Classifier.expects(:connection).with(dashboard_options).returns connection
        connection.expects(:list).with(v, "Listing #{k}")
        subject.list(k, dashboard_options)
      end
    end
    it 'should fail when an invalid type is specified' do
      expect { subject.list('foo', {} ) }.should raise_error(Puppet::Error, /Invalid type specified/)
    end
  end
  #describe 'actions create_class and create_node' do
  #  {'node' => 'node', 'class' => 'node_class'}.each do |type,dash_type|
  it "should require the name option for class" do
    expect { subject.send("create_class", {}) }.should raise_error(ArgumentError)
  end
  it "should accept name option for class" do
    munged_options = dashboard_options.merge(:name => 'dan')
    Puppet::Dashboard::Classifier.expects(:connection).with(munged_options).returns connection
    connection.expects(:create_classes).with(['dan'])
    subject.send("create_class", munged_options)
  end
  #  end
  #end
  describe 'action register_module' do

  end
  describe 'action add_module' do

  end
end
