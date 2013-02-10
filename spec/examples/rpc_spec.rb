# ~*~ encoding: utf-8 ~*~
require 'shared/remote_context'

describe Judge::Client do

  include_context 'remote rpc'

  before :each do
    @client = Judge::Client.new 'port' => port
    @client.transport.open
  end
  after(:each)  { @client.transport.close }
  subject       { @client }

  describe '#ping' do
    its(:ping) { should eq 'pong!' }
  end

  describe '#info' do

    its(:info) { should respond_to :uptime }
    its(:info) { should respond_to :threads }

    it 'reports the uptime' do
      subject.info.uptime.should > 0
    end

    it 'reports the number of threads' do
      subject.info.threads.should have_key 'total'
      subject.info.threads.should have_key 'running'
    end

  end

  describe '#add_job' do

    context 'basic job' do
      before(:each) { @job = FactoryGirl.create :job, :basic }
      it 'passes all validations' do
        amq_exchange.expects(:publish)
          .with(instance_of(String), Judge::RABBIT_JOBS.message[:opts])
          .once
        subject.add_job(@job).code.should be(StatusCode::SUCCESS)
      end
    end

    shared_examples 'a bad job' do
      it 'fails a validation' do
        status = subject.add_job(job)
        status.code.should be(StatusCode::FAILURE)
        status.trace.grep(pattern).length.should be 1
      end
    end

    context 'missing name' do
      it_behaves_like 'a bad job' do
        let(:job) { FactoryGirl.create :job, :basic, name: '' }
        let(:pattern) { /missing job\.name/i }
      end
    end

    context 'missing output' do
      it_behaves_like 'a bad job' do
        let(:job) { FactoryGirl.create :job, :basic, output: '' }
        let(:pattern) { /missing job\.output/i }
      end
    end

    context 'missing inputs' do
      it_behaves_like 'a bad job' do
        let(:job) { FactoryGirl.create :job, :basic, inputs: [] }
        let(:pattern) { /missing job\.inputs/i }
      end
    end

    context 'missing input.local' do
      it_behaves_like 'a bad job' do
        let(:job) { FactoryGirl.create :job, :basic, inputs: [Input.new(local: '')] }
        let(:pattern) { /missing job\.input.local/i }
      end
    end

    context 'bad output' do
      pending
    end

    context 'bad input' do
      pending
    end

  end

end
