require_relative '../spec_helper'

describe 'windows_server::default' do
  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

  it 'creates the C:\tmp directory' do
    expect(chef_run).to add_windows_path('C:\tmp')
  end

  it 'creates a windows task to run chef-client' do
    expect(chef_run).to create_windows_task('chef-client')
  end
end
